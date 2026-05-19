'use client'

import { useEffect, useRef } from 'react'
import { select } from 'd3-selection'
import { scaleBand, scaleLinear } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import type { NumberValue } from 'd3-scale'
import { max, group } from 'd3-array'
import { getColors, typography, variantColor } from './theme'
import { appendGrid, appendLegendRects } from './d3helpers'
import { useTheme } from '@/hooks/useTheme'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'

export interface CounterRun {
  variant: string
  threads: number
  counters: {
    cache_misses_per_op: number
    cache_miss_ratio: number
    instructions_per_cycle: number
  }
}

export interface BranchMissRun {
  variant: string
  branch_misses_per_op: number
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
  const theme = useTheme()

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    select(ref.current).selectAll('*').remove()
    render(ref.current, runs, metric, title)
  }, [runs, metric, title, theme])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? METRIC_LABELS[metric]} />
    </ChartZoom>
  )
}

const DEFAULT_TITLE_COUNTER    = 'CPU counter metric bar chart'
const DEFAULT_TITLE_BRANCHMISS = 'Branch miss rate bar chart'

function render(el: SVGSVGElement, runs: CounterRun[], metric: Metric, title?: string) {
  const colors = getColors()
  const W = el.clientWidth || 600
  const H = 240
  const margin = { top: 32, right: 96, bottom: 64, left: 72 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_COUNTER)

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

  const vals = runs.map((r) => r.counters[metric])
  const y = scaleLinear().domain([0, max(vals)! * 1.3]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  const grouped = group(runs, (d) => d.threads)
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

      g.append('text')
        .attr('x', bx + bw / 2)
        .attr('y', by - 6)
        .attr('text-anchor', 'middle')
        .attr('font-size', 10)
        .attr('fill', colors.textPrimary)
        .text(val.toFixed(metric === 'instructions_per_cycle' ? 2 : 3))
    })
  })

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
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('threads')

  const yFormat = metric === 'cache_miss_ratio'
    ? (v: NumberValue) => `${(+v * 100).toFixed(0)}%`
    : (v: NumberValue) => `${v}`
  g.append('g')
    .call(axisLeft(y).ticks(5).tickFormat(yFormat))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((sel) => sel.selectAll('line').remove())

  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 12)
    .attr('text-anchor', 'middle')
    .attr('font-size', 9)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(METRIC_LABELS[metric])

  svg.append('text')
    .attr('x', margin.left)
    .attr('y', margin.top - 10)
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(METRIC_LABELS[metric])

  appendLegendRects(svg, [
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ], { x: margin.left + inner.w + 8, y: margin.top }, { textSecondary: colors.textSecondary })
}

// ─── Branch-miss overlay (branch-prediction demo) ────────────────────────────

export function BranchMissOverlayChart({ runs, title }: { runs: BranchMissRun[]; title?: string }) {
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    select(ref.current).selectAll('*').remove()
    renderBranchMiss(ref.current, runs, title)
  }, [runs, title, theme])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Branch miss rate'} />
    </ChartZoom>
  )
}

function renderBranchMiss(el: SVGSVGElement, runs: BranchMissRun[], title?: string) {
  const colors = getColors()
  const W = el.clientWidth || 600
  const H = 220
  const margin = { top: 32, right: 24, bottom: 56, left: 72 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_BRANCHMISS)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const x = scaleBand().domain(runs.map((r) => r.variant)).range([0, inner.w]).padding(0.45)
  const y = scaleLinear().domain([0, 0.55]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  g.selectAll('.bar')
    .data(runs)
    .join('rect')
    .attr('class', 'bar')
    .attr('x', (d) => x(d.variant)!)
    .attr('y', (d) => y(d.branch_misses_per_op))
    .attr('width', x.bandwidth())
    .attr('height', (d) => inner.h - y(d.branch_misses_per_op))
    .attr('fill', (d) => variantColor(d.variant))
    .attr('rx', 4)
    .attr('opacity', 0.9)

  g.selectAll('.bar-label')
    .data(runs)
    .join('text')
    .attr('class', 'bar-label')
    .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
    .attr('y', (d) => y(d.branch_misses_per_op) - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.labelSize)
    .attr('fill', colors.textPrimary)
    .text((d) => `${(d.branch_misses_per_op * 100).toFixed(1)}%`)

  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .attr('dy', '1.4em')
        .text((d) => (d as string).charAt(0).toUpperCase() + (d as string).slice(1))
    )

  g.append('g')
    .call(axisLeft(y).ticks(5).tickFormat((v) => `${(+v * 100).toFixed(0)}%`))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) => sel.selectAll('text').attr('font-size', typography.axisSize).attr('fill', colors.textMuted))
    .call((sel) => sel.selectAll('line').remove())

  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 14)
    .attr('text-anchor', 'middle')
    .attr('font-size', 9)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('branch misses / op')

  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('branch misses / op  ·  N = 32 M')
}
