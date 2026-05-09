'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { colors, typography, variantColor } from './theme'

// ─── Run types ───────────────────────────────────────────────────────────────

interface NsPerOp {
  median: number
  min: number
  iqr: number
  p99?: number
}

// Branch-prediction (legacy) format
export interface LegacyRun {
  variant: string
  n: number
  ns_per_op: NsPerOp
  ops_per_sec: number
  branch_misses_per_op: number
  instructions_per_cycle: number
  threads?: never
}

// False-sharing format
export interface ThreadRun {
  variant: string
  threads: number
  padded: boolean
  placement: string
  ns_per_op: NsPerOp
  ops_per_sec: number
  counters: {
    cache_misses_per_op: number
    cache_miss_ratio: number
    instructions_per_cycle: number
  }
  notes?: string
  n?: never
}

export type Run = LegacyRun | ThreadRun

function isThreadRun(r: Run): r is ThreadRun {
  return typeof (r as ThreadRun).threads === 'number'
}

// ─── Component ───────────────────────────────────────────────────────────────

interface Props {
  runs: Run[]
  stat?: 'median' | 'min' | 'p99'
  targetN?: number
  title?: string
}

export function ThroughputBarsChart({ runs, stat = 'median', targetN, title }: Props) {
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    d3.select(ref.current).selectAll('*').remove()
    if (isThreadRun(runs[0])) {
      renderGrouped(ref.current, runs as ThreadRun[], stat)
    } else {
      renderLegacy(ref.current, runs as LegacyRun[], stat, targetN)
    }
  }, [runs, stat, targetN])

  return (
    <figure className="my-8">
      {title && (
        <figcaption className="text-xs mb-3 font-mono" style={{ color: colors.textMuted }}>
          {title}
        </figcaption>
      )}
      <div
        className="rounded-xl border overflow-hidden"
        style={{ background: colors.bg, borderColor: colors.border }}
      >
        <svg ref={ref} className="w-full" style={{ display: 'block' }} />
      </div>
    </figure>
  )
}

// ─── Legacy renderer (branch prediction) ─────────────────────────────────────

function renderLegacy(
  el: SVGSVGElement,
  runs: LegacyRun[],
  stat: 'median' | 'min' | 'p99',
  targetN?: number,
) {
  const ns = Array.from(new Set(runs.map((r) => r.n))).sort((a, b) => a - b)
  const n = targetN ?? ns[ns.length - 1]
  const data = runs.filter((r) => r.n === n)
  if (data.length === 0) return

  const W = el.clientWidth || 600
  const H = 260
  const margin = { top: 24, right: 16, bottom: 64, left: 64 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const x = d3.scaleBand().domain(data.map((d) => d.variant)).range([0, inner.w]).padding(0.45)
  const vals = data.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const y = d3.scaleLinear().domain([0, d3.max(vals)! * 1.25]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner)

  g.selectAll('.bar')
    .data(data)
    .join('rect')
    .attr('class', 'bar')
    .attr('x', (d) => x(d.variant)!)
    .attr('y', (d) => y(d.ns_per_op[stat] ?? d.ns_per_op.median))
    .attr('width', x.bandwidth())
    .attr('height', (d) => inner.h - y(d.ns_per_op[stat] ?? d.ns_per_op.median))
    .attr('fill', (d) => variantColor(d.variant))
    .attr('rx', 4)
    .attr('opacity', 0.9)

  g.selectAll('.bar-label')
    .data(data)
    .join('text')
    .attr('class', 'bar-label')
    .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
    .attr('y', (d) => y(d.ns_per_op[stat] ?? d.ns_per_op.median) - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.labelSize)
    .attr('fill', colors.textPrimary)
    .text((d) => `${(d.ns_per_op[stat] ?? d.ns_per_op.median).toFixed(2)} ns/op`)

  g.selectAll('.miss-label')
    .data(data)
    .join('text')
    .attr('class', 'miss-label')
    .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
    .attr('y', (d) => y(d.ns_per_op[stat] ?? d.ns_per_op.median) - 26)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .text((d) => `${(d.branch_misses_per_op * 100).toFixed(1)}% miss`)

  appendAxesLegacy(g, svg, x, y, inner, W, H, margin, stat, n)
}

// ─── Grouped renderer (false sharing) ────────────────────────────────────────

function renderGrouped(
  el: SVGSVGElement,
  runs: ThreadRun[],
  stat: 'median' | 'min' | 'p99',
) {
  const W = el.clientWidth || 600
  const H = 280
  const margin = { top: 32, right: 96, bottom: 64, left: 72 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const threadCounts = Array.from(new Set(runs.map((r) => r.threads))).sort((a, b) => a - b)
  const variants = ['unpadded', 'padded']

  const x0 = d3
    .scaleBand()
    .domain(threadCounts.map((t) => `${t}t`))
    .range([0, inner.w])
    .paddingInner(0.3)
    .paddingOuter(0.1)

  const x1 = d3
    .scaleBand()
    .domain(variants)
    .range([0, x0.bandwidth()])
    .padding(0.06)

  const vals = runs.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const y = d3.scaleLinear().domain([0, d3.max(vals)! * 1.3]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner)

  const grouped = d3.group(runs, (d) => d.threads)
  grouped.forEach((threadRuns, threads) => {
    const gx = x0(`${threads}t`)!
    threadRuns.forEach((run) => {
      const bx = gx + x1(run.variant)!
      const bw = x1.bandwidth()
      const nsVal = run.ns_per_op[stat] ?? run.ns_per_op.median
      const by = y(nsVal)
      const bh = inner.h - by

      g.append('rect')
        .attr('x', bx)
        .attr('y', by)
        .attr('width', bw)
        .attr('height', bh)
        .attr('fill', variantColor(run.variant))
        .attr('rx', 4)
        .attr('opacity', 0.9)

      // Value label above bar
      g.append('text')
        .attr('x', bx + bw / 2)
        .attr('y', by - 6)
        .attr('text-anchor', 'middle')
        .attr('font-size', 10)
        .attr('fill', colors.textPrimary)
        .text(`${nsVal.toFixed(1)}`)

      // Cache-miss annotation inside/below value label
      if (run.counters) {
        g.append('text')
          .attr('x', bx + bw / 2)
          .attr('y', by - 18)
          .attr('text-anchor', 'middle')
          .attr('font-size', 9)
          .attr('fill', colors.textMuted)
          .text(`${(run.counters.cache_misses_per_op).toFixed(2)}m/op`)
      }
    })
  })

  // X axis: thread counts
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(d3.axisBottom(x0).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .attr('dy', '1.4em')
    )

  // X axis label
  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(`threads  ·  ${stat} ns/op`)

  // Y axis
  g.append('g')
    .call(d3.axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((sel) => sel.selectAll('line').remove())

  // Legend (top-right)
  const legendX = margin.left + inner.w + 8
  const legendItems = [
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ]
  legendItems.forEach(({ label, color }, i) => {
    svg.append('rect')
      .attr('x', legendX)
      .attr('y', margin.top + i * 18)
      .attr('width', 10)
      .attr('height', 10)
      .attr('fill', color)
      .attr('rx', 2)
    svg.append('text')
      .attr('x', legendX + 14)
      .attr('y', margin.top + i * 18 + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(label)
  })
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

function appendGrid(
  g: d3.Selection<SVGGElement, unknown, null, undefined>,
  y: d3.ScaleLinear<number, number>,
  inner: { w: number; h: number },
) {
  g.append('g')
    .attr('class', 'grid')
    .call(
      d3.axisLeft(y)
        .ticks(5)
        .tickSize(-inner.w)
        .tickFormat(() => '')
    )
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('line')
        .attr('stroke', colors.border)
        .attr('stroke-dasharray', '3,3')
    )
}

function appendAxesLegacy(
  g: d3.Selection<SVGGElement, unknown, null, undefined>,
  svg: d3.Selection<SVGSVGElement, unknown, null, undefined>,
  x: d3.ScaleBand<string>,
  y: d3.ScaleLinear<number, number>,
  inner: { w: number; h: number },
  W: number,
  H: number,
  margin: { top: number; right: number; bottom: number; left: number },
  stat: string,
  n: number,
) {
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(d3.axisBottom(x).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .attr('dy', '1.4em')
        .text((d) => (d as string).charAt(0).toUpperCase() + (d as string).slice(1))
    )

  g.append('g')
    .call(d3.axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((sel) => sel.selectAll('line').remove())

  svg.append('text')
    .attr('x', margin.left)
    .attr('y', H - 10)
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(`${stat} ns/op · N = ${n.toLocaleString()}`)
}
