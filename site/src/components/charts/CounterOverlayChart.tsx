'use client'

import { scaleBand, scaleLinear } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import type { NumberValue } from 'd3-scale'
import { max, group } from 'd3-array'
import { typography, variantColor } from './theme'
import {
  appendGrid, appendLegendRects,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel,
} from './d3helpers'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import { formatSI } from '@/lib/format'

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
  const ref = useChartEffect((el) => {
    if (runs.length === 0) return
    render(el, runs, metric, title)
  }, [runs, metric, title])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? METRIC_LABELS[metric]} />
    </ChartZoom>
  )
}

const DEFAULT_TITLE_COUNTER    = 'CPU counter metric bar chart'
const DEFAULT_TITLE_BRANCHMISS = 'Branch miss rate bar chart'

function render(el: SVGSVGElement, runs: CounterRun[], metric: Metric, title?: string) {
  const H = 240
  const W = el.clientWidth || 600
  const margin = { top: 32, right: 96, bottom: 64, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE_COUNTER)

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
        .attr('font-size', typography.annotationSize)
        .attr('fill', colors.textPrimary)
        .text(val.toFixed(metric === 'instructions_per_cycle' ? 2 : 3))
    })
  })

  appendXAxis(g, inner, colors, axisBottom(x0).tickSize(0), true)
  appendXLabel(svg, 'threads', margin.left + inner.w / 2, H - 8, colors)

  const yFormat = metric === 'cache_miss_ratio'
    ? (v: NumberValue) => `${(+v * 100).toFixed(0)}%`
    : (v: NumberValue) => `${v}`
  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat(yFormat))
  appendYLabel(svg, METRIC_LABELS[metric], -(margin.top + inner.h / 2), 12, colors, typography.captionSize)

  svg.append('text')
    .attr('x', margin.left)
    .attr('y', margin.top - 10)
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(METRIC_LABELS[metric])

  appendLegendRects(svg, [
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ], { x: margin.left + inner.w + 8, y: margin.top }, { textSecondary: colors.textSecondary })
}

// ─── Branch-miss overlay (branch-prediction demo) ────────────────────────────

export function BranchMissOverlayChart({ runs, title, maxN }: { runs: BranchMissRun[]; title?: string; maxN?: number }) {
  const ref = useChartEffect((el) => {
    if (runs.length === 0) return
    renderBranchMiss(el, runs, title, maxN)
  }, [runs, title, maxN])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Branch miss rate'} />
    </ChartZoom>
  )
}

function renderBranchMiss(el: SVGSVGElement, runs: BranchMissRun[], title?: string, maxN?: number) {
  const H = 220
  const W = el.clientWidth || 600
  const margin = { top: 32, right: 24, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE_BRANCHMISS)

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

  appendXAxis(g, inner, colors, axisBottom(x).tickSize(0), true)

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${(+v * 100).toFixed(0)}%`))
  appendYLabel(svg, 'branch misses / op', -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

  appendXLabel(svg,
    maxN != null ? `branch misses / op  ·  N = ${formatSI(maxN)}` : 'branch misses / op',
    margin.left + inner.w / 2, H - 8, colors,
  )
}
