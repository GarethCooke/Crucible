'use client'

import { useEffect, useRef } from 'react'
import { select } from 'd3-selection'
import type { Selection } from 'd3-selection'
import { scaleBand, scaleLinear } from 'd3-scale'
import type { ScaleBand, ScaleLinear } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { max, group } from 'd3-array'
import { getColors, typography, variantColor } from './theme'
import { appendGrid, appendLegendRects } from './d3helpers'
import { tokens } from '@/lib/design-tokens'
import { useTheme } from '@/hooks/useTheme'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'

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
  branch_misses_per_op?: number
  instructions_per_cycle?: number
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
  metric?: 'ops_per_sec'
}

export function ThroughputBarsChart({ runs, stat = 'median', targetN, title, metric }: Props) {
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    select(ref.current).selectAll('*').remove()
    if (isThreadRun(runs[0])) {
      renderGrouped(ref.current, runs as ThreadRun[], stat, title)
    } else {
      renderLegacy(ref.current, runs as LegacyRun[], stat, targetN, title, metric)
    }
  }, [runs, stat, targetN, title, metric, theme])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Throughput benchmark'} />
    </ChartZoom>
  )
}

// ─── Legacy renderer (branch prediction) ─────────────────────────────────────

const DEFAULT_TITLE_LEGACY   = 'Throughput comparison bar chart'
const DEFAULT_TITLE_GROUPED  = 'Throughput by thread count (padded vs unpadded)'

function fmtOps(v: number): string {
  if (v >= 1_000_000) return `${(v / 1_000_000).toFixed(1)} M/s`
  if (v >= 1_000) return `${(v / 1_000).toFixed(1)} K/s`
  return `${v}/s`
}

function fmtOpsTick(v: number | { valueOf(): number }): string {
  const n = +v
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(0)} M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(0)} K`
  return `${n}`
}

function renderLegacy(
  el: SVGSVGElement,
  runs: LegacyRun[],
  stat: 'median' | 'min' | 'p99',
  targetN?: number,
  title?: string,
  metric?: 'ops_per_sec',
) {
  const colors = getColors()
  const ns = Array.from(new Set(runs.map((r) => r.n))).sort((a, b) => a - b)
  const n = targetN ?? ns[ns.length - 1]
  const data = runs.filter((r) => r.n === n)
  if (data.length === 0) return

  const W = el.clientWidth || 600
  const H = 260
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = { top: 24, right: 16, bottom: isNarrow ? 60 : 40, left: 64 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const useOps = metric === 'ops_per_sec'

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_LEGACY)
  svg.append('desc').text(
    useOps
      ? data.map((d) => `${d.variant}: ${fmtOps(d.ops_per_sec)}`).join('. ')
      : data.map((d) => `${d.variant}: ${(d.ns_per_op[stat] ?? d.ns_per_op.median).toFixed(2)} ns/op`).join('. ')
  )

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const x = scaleBand().domain(data.map((d) => d.variant)).range([0, inner.w]).padding(0.45)
  const vals = useOps
    ? data.map((d) => d.ops_per_sec)
    : data.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const y = scaleLinear().domain([0, max(vals)! * 1.25]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  g.selectAll('.bar')
    .data(data)
    .join('rect')
    .attr('class', 'bar')
    .attr('x', (d) => x(d.variant)!)
    .attr('y', (d) => y(useOps ? d.ops_per_sec : (d.ns_per_op[stat] ?? d.ns_per_op.median)))
    .attr('width', x.bandwidth())
    .attr('height', (d) => inner.h - y(useOps ? d.ops_per_sec : (d.ns_per_op[stat] ?? d.ns_per_op.median)))
    .attr('fill', (d) => variantColor(d.variant))
    .attr('rx', 4)
    .attr('opacity', 0.9)

  g.selectAll('.bar-label')
    .data(data)
    .join('text')
    .attr('class', 'bar-label')
    .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
    .attr('y', (d) => y(useOps ? d.ops_per_sec : (d.ns_per_op[stat] ?? d.ns_per_op.median)) - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.labelSize)
    .attr('fill', colors.textPrimary)
    .text((d) => useOps
      ? fmtOps(d.ops_per_sec)
      : `${(d.ns_per_op[stat] ?? d.ns_per_op.median).toFixed(2)} ns/op`
    )

  g.selectAll('.miss-label')
    .data(data.filter((d) => d.branch_misses_per_op != null))
    .join('text')
    .attr('class', 'miss-label')
    .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
    .attr('y', (d) => y(d.ns_per_op[stat] ?? d.ns_per_op.median) - 26)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .text((d) => `${((d.branch_misses_per_op ?? 0) * 100).toFixed(1)}% miss`)

  appendAxesLegacy(g, svg, x, y, inner, W, H, margin, stat, n, isNarrow, useOps)
}

// ─── Grouped renderer (false sharing) ────────────────────────────────────────

function renderGrouped(
  el: SVGSVGElement,
  runs: ThreadRun[],
  stat: 'median' | 'min' | 'p99',
  title?: string,
) {
  const colors = getColors()
  const W = el.clientWidth || 600
  const H = 280
  const margin = { top: 32, right: 96, bottom: 64, left: 72 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_GROUPED)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const threadCounts = Array.from(new Set(runs.map((r) => r.threads))).sort((a, b) => a - b)
  const variants = ['unpadded', 'padded']

  const x0 = scaleBand()
    .domain(threadCounts.map((t) => `${t}t`))
    .range([0, inner.w])
    .paddingInner(0.3)
    .paddingOuter(0.1)

  const x1 = scaleBand()
    .domain(variants)
    .range([0, x0.bandwidth()])
    .padding(0.06)

  const vals = runs.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const y = scaleLinear().domain([0, max(vals)! * 1.3]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  const grouped = group(runs, (d) => d.threads)
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

      g.append('text')
        .attr('x', bx + bw / 2)
        .attr('y', by - 6)
        .attr('text-anchor', 'middle')
        .attr('font-size', typography.annotationSize)
        .attr('fill', colors.textPrimary)
        .text(`${nsVal.toFixed(1)}`)

      if (run.counters) {
        g.append('text')
          .attr('x', bx + bw / 2)
          .attr('y', by - 18)
          .attr('text-anchor', 'middle')
          .attr('font-size', typography.captionSize)
          .attr('fill', colors.textMuted)
          .text(`${(run.counters.cache_misses_per_op).toFixed(2)}m/op`)
      }
    })
  })

  // X axis: thread counts
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x0).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .attr('dy', '1.4em')
    )

  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(`threads  ·  ${stat} ns/op`)

  g.append('g')
    .call(axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((sel) => sel.selectAll('line').remove())

  appendLegendRects(svg, [
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ], { x: margin.left + inner.w + 8, y: margin.top }, { textSecondary: colors.textSecondary })
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

function appendAxesLegacy(
  g: Selection<SVGGElement, unknown, null, undefined>,
  svg: Selection<SVGSVGElement, unknown, null, undefined>,
  x: ScaleBand<string>,
  y: ScaleLinear<number, number>,
  inner: { w: number; h: number },
  W: number,
  H: number,
  margin: { top: number; right: number; bottom: number; left: number },
  stat: string,
  n: number,
  isNarrow = false,
  useOps = false,
) {
  const colors = getColors()
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) => {
      const labels = sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .text((d) => (d as string).charAt(0).toUpperCase() + (d as string).slice(1))
      if (isNarrow) {
        labels
          .style('text-anchor', 'end')
          .attr('transform', 'rotate(-30) translate(-6, 0)')
          .attr('dy', '0.3em')
      } else {
        labels.attr('dy', '1.4em')
      }
    })

  g.append('g')
    .call(axisLeft(y).ticks(5).tickFormat(useOps ? fmtOpsTick : (v) => `${v} ns`))
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
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(useOps ? `ops/sec · N = ${n.toLocaleString()}` : `${stat} ns/op · N = ${n.toLocaleString()}`)
}
