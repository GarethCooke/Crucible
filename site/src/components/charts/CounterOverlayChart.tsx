'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { colors, typography, variantColor } from './theme'

export interface CounterRun {
  variant: string
  threads: number
  counters: {
    cache_misses_per_op: number
    cache_miss_ratio: number
    instructions_per_cycle: number
  }
}

type Metric = 'cache_misses_per_op' | 'cache_miss_ratio' | 'instructions_per_cycle'

const METRIC_LABELS: Record<Metric, string> = {
  cache_misses_per_op:    'cache misses / op',
  cache_miss_ratio:       'cache miss ratio',
  instructions_per_cycle: 'instructions / cycle (IPC)',
}

interface Props {
  runs: CounterRun[]
  metric: Metric
  title?: string
}

export function CounterOverlayChart({ runs, metric, title }: Props) {
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    d3.select(ref.current).selectAll('*').remove()
    render(ref.current, runs, metric)
  }, [runs, metric])

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

function render(el: SVGSVGElement, runs: CounterRun[], metric: Metric) {
  const W = el.clientWidth || 600
  const H = 240
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

  const vals = runs.map((r) => r.counters[metric])
  const y = d3.scaleLinear().domain([0, d3.max(vals)! * 1.3]).range([inner.h, 0]).nice()

  // Grid
  g.append('g')
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

  // Bars
  const grouped = d3.group(runs, (d) => d.threads)
  grouped.forEach((threadRuns, threads) => {
    const gx = x0(`${threads}t`)!
    threadRuns.forEach((run) => {
      const bx = gx + x1(run.variant)!
      const bw = x1.bandwidth()
      const val = run.counters[metric]
      const by = y(val)
      const bh = inner.h - by

      g.append('rect')
        .attr('x', bx)
        .attr('y', by)
        .attr('width', bw)
        .attr('height', bh)
        .attr('fill', variantColor(run.variant))
        .attr('rx', 4)
        .attr('opacity', 0.9)

      // Value label
      g.append('text')
        .attr('x', bx + bw / 2)
        .attr('y', by - 6)
        .attr('text-anchor', 'middle')
        .attr('font-size', 10)
        .attr('fill', colors.textPrimary)
        .text(val.toFixed(metric === 'instructions_per_cycle' ? 2 : 3))
    })
  })

  // X axis
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
    .text('threads')

  // Y axis
  const yFormat = metric === 'cache_miss_ratio'
    ? (v: d3.NumberValue) => `${(+v * 100).toFixed(0)}%`
    : (v: d3.NumberValue) => `${v}`
  g.append('g')
    .call(d3.axisLeft(y).ticks(5).tickFormat(yFormat))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((sel) => sel.selectAll('line').remove())

  // Y axis label
  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 12)
    .attr('text-anchor', 'middle')
    .attr('font-size', 9)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(METRIC_LABELS[metric])

  // Tooltip title
  svg.append('text')
    .attr('x', margin.left)
    .attr('y', margin.top - 10)
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(METRIC_LABELS[metric])

  // Legend
  const legendX = margin.left + inner.w + 8
  ;[
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ].forEach(({ label, color }, i) => {
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
