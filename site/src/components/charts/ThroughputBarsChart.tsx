'use client'

import type { Selection } from 'd3-selection'
import { scaleBand, scaleLinear } from 'd3-scale'
import type { ScaleBand, ScaleLinear } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { max, group } from 'd3-array'
import { typography, variantColor } from './theme'
import {
  appendGrid, appendLegendRects,
  setupSVG, appendXAxis, appendYAxis, appendXLabel,
} from './d3helpers'
import { tokens } from '@/lib/design-tokens'
import { capitalize, uniqueSortedNs } from '@/lib/format'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import { getColors } from './theme'

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
  k?: number
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
  kFilter?: number | number[]
}

export function ThroughputBarsChart({ runs, stat = 'median', targetN, title, metric, kFilter }: Props) {
  const ref = useChartEffect((el) => {
    if (runs.length === 0) return
    if (isThreadRun(runs[0])) {
      renderGrouped(el, runs as ThreadRun[], stat, title)
    } else if (Array.isArray(kFilter)) {
      renderKGrouped(el, runs as LegacyRun[], stat, kFilter, targetN, title)
    } else {
      renderLegacy(el, runs as LegacyRun[], stat, targetN, title, metric, kFilter)
    }
  }, [runs, stat, targetN, title, metric, kFilter])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Throughput benchmark'} />
    </ChartZoom>
  )
}

// ─── Legacy renderer (branch prediction) ─────────────────────────────────────

const DEFAULT_TITLE_LEGACY   = 'Throughput comparison bar chart'
const DEFAULT_TITLE_GROUPED  = 'Throughput by thread count (padded vs unpadded)'
const DEFAULT_TITLE_K        = 'Throughput comparison by K value'

function fmtCount(v: number, suffix = ''): string {
  if (v >= 1_000_000) return `${(v / 1_000_000).toFixed(1)} M${suffix}`
  if (v >= 1_000)     return `${(v / 1_000).toFixed(1)} K${suffix}`
  return `${v}${suffix}`
}

const fmtOps     = (v: number) => fmtCount(v, '/s')
const fmtOpsTick = (v: number | { valueOf(): number }) => fmtCount(+v)

function renderLegacy(
  el: SVGSVGElement,
  runs: LegacyRun[],
  stat: 'median' | 'min' | 'p99',
  targetN?: number,
  title?: string,
  metric?: 'ops_per_sec',
  kFilter?: number,
) {
  const ns = uniqueSortedNs(runs)
  const n = targetN ?? ns[ns.length - 1]
  let data = runs.filter((r) => r.n === n)
  if (typeof kFilter === 'number') {
    data = data.filter((r) => r.k === kFilter)
  }
  if (data.length === 0) return

  const H = 260
  const W = el.clientWidth || 600
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = { top: 24, right: 16, bottom: isNarrow ? 60 : 40, left: 64 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE_LEGACY)

  const useOps = metric === 'ops_per_sec'

  svg.append('desc').text(
    useOps
      ? data.map((d) => `${d.variant}: ${fmtOps(d.ops_per_sec)}`).join('. ')
      : data.map((d) => `${d.variant}: ${(d.ns_per_op[stat] ?? d.ns_per_op.median).toFixed(2)} ns/op`).join('. ')
  )

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

  appendAxesLegacy(g, svg, x, y, inner, H, margin, stat, n, colors, isNarrow, useOps)
}

// ─── K-grouped renderer (demo 6: bar groups per K value) ──────────────────────

function renderKGrouped(
  el: SVGSVGElement,
  runs: LegacyRun[],
  stat: 'median' | 'min' | 'p99',
  kFilter: number[],
  targetN?: number,
  title?: string,
) {
  const ns = uniqueSortedNs(runs)
  const n = targetN ?? ns[ns.length - 1]
  const kValues = [...kFilter].sort((a, b) => a - b)
  const data = runs.filter((r) => r.n === n && kValues.includes(r.k ?? -1))
  if (data.length === 0) return

  const variants = Array.from(new Set(data.map((r) => r.variant)))
  const vals = data.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const { H, margin, svg, g, inner, colors, x0, x1, y } = setupGroupChart(
    el, kValues.map((k) => `K=${k}`), variants, max(vals)!, title ?? DEFAULT_TITLE_K,
  )

  const grouped = group(data, (d) => d.k ?? 0)
  grouped.forEach((kRuns, k) => {
    const gx = x0(`K=${k}`)!
    kRuns.forEach((run) => {
      const bx = gx + x1(run.variant)!
      const nsVal = run.ns_per_op[stat] ?? run.ns_per_op.median
      appendBarRect(g, bx, y(nsVal), x1.bandwidth(), inner.h - y(nsVal), nsVal, variantColor(run.variant), 2, colors)
    })
  })

  appendXAxis(g, inner, colors, axisBottom(x0).tickSize(0), true)
  appendXLabel(svg, `K value  ·  ${stat} ns/element  ·  N = ${n.toLocaleString()}`, margin.left + inner.w / 2, H - 8, colors)
  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
  appendLegendRects(svg, variants.map((v) => ({
    label: capitalize(v),
    color: variantColor(v),
  })), { x: margin.left + inner.w + 8, y: margin.top }, { textSecondary: colors.textSecondary })
}

// ─── Grouped renderer (false sharing) ────────────────────────────────────────

function renderGrouped(
  el: SVGSVGElement,
  runs: ThreadRun[],
  stat: 'median' | 'min' | 'p99',
  title?: string,
) {
  const threadCounts = Array.from(new Set(runs.map((r) => r.threads))).sort((a, b) => a - b)
  const variants = ['unpadded', 'padded']
  const vals = runs.map((d) => d.ns_per_op[stat] ?? d.ns_per_op.median)
  const { H, margin, svg, g, inner, colors, x0, x1, y } = setupGroupChart(
    el, threadCounts.map((t) => `${t}t`), variants, max(vals)!, title ?? DEFAULT_TITLE_GROUPED,
  )

  const grouped = group(runs, (d) => d.threads)
  grouped.forEach((threadRuns, threads) => {
    const gx = x0(`${threads}t`)!
    threadRuns.forEach((run) => {
      const bx = gx + x1(run.variant)!
      const nsVal = run.ns_per_op[stat] ?? run.ns_per_op.median
      const annotation = run.counters ? `${run.counters.cache_misses_per_op.toFixed(2)}m/op` : undefined
      appendBarRect(g, bx, y(nsVal), x1.bandwidth(), inner.h - y(nsVal), nsVal, variantColor(run.variant), 1, colors, annotation)
    })
  })

  appendXAxis(g, inner, colors, axisBottom(x0).tickSize(0), true)
  appendXLabel(svg, `threads  ·  ${stat} ns/op`, margin.left + inner.w / 2, H - 8, colors)
  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
  appendLegendRects(svg, [
    { label: 'Unpadded', color: variantColor('unpadded') },
    { label: 'Padded',   color: variantColor('padded') },
  ], { x: margin.left + inner.w + 8, y: margin.top }, { textSecondary: colors.textSecondary })
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

type Colors = ReturnType<typeof getColors>

// Common SVG + scale setup for both grouped bar renderers.
function setupGroupChart(
  el: SVGSVGElement,
  x0Domain: string[],
  variants: string[],
  maxVal: number,
  title: string,
) {
  const H = 280
  const W = el.clientWidth || 600
  const margin = { top: 32, right: 96, bottom: 64, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title)

  const x0 = scaleBand()
    .domain(x0Domain)
    .range([0, inner.w])
    .paddingInner(0.3)
    .paddingOuter(0.1)

  const x1 = scaleBand()
    .domain(variants)
    .range([0, x0.bandwidth()])
    .padding(0.06)

  const y = scaleLinear().domain([0, maxVal * 1.3]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  return { H, margin, svg, g, inner, colors, x0, x1, y }
}

// Renders a single bar rect + value label, with an optional secondary annotation above.
function appendBarRect(
  g: Selection<SVGGElement, unknown, null, undefined>,
  bx: number, by: number, bw: number, bh: number,
  nsVal: number, color: string, decimals: number,
  colors: Colors,
  annotation?: string,
) {
  g.append('rect')
    .attr('x', bx).attr('y', by)
    .attr('width', bw).attr('height', bh)
    .attr('fill', color).attr('rx', 4).attr('opacity', 0.9)

  g.append('text')
    .attr('x', bx + bw / 2).attr('y', by - 6)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textPrimary)
    .text(`${nsVal.toFixed(decimals)}`)

  if (annotation != null) {
    g.append('text')
      .attr('x', bx + bw / 2).attr('y', by - 18)
      .attr('text-anchor', 'middle')
      .attr('font-size', typography.captionSize)
      .attr('fill', colors.textMuted)
      .text(annotation)
  }
}

function appendAxesLegacy(
  g: Selection<SVGGElement, unknown, null, undefined>,
  svg: Selection<SVGSVGElement, unknown, null, undefined>,
  x: ScaleBand<string>,
  y: ScaleLinear<number, number>,
  inner: { w: number; h: number },
  H: number,
  margin: { top: number; right: number; bottom: number; left: number },
  stat: string,
  n: number,
  colors: Colors,
  isNarrow = false,
  useOps = false,
) {
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x).tickSize(0))
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) => {
      const labels = sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .text((d) => capitalize(d as string))
      if (isNarrow) {
        labels
          .style('text-anchor', 'end')
          .attr('transform', 'rotate(-30) translate(-6, 0)')
          .attr('dy', '0.3em')
      } else {
        labels.attr('dy', '1.4em')
      }
    })

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat(useOps ? fmtOpsTick : (v) => `${v} ns`))

  svg.append('text')
    .attr('x', margin.left)
    .attr('y', H - 10)
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(useOps ? `ops/sec · N = ${n.toLocaleString()}` : `${stat} ns/op · N = ${n.toLocaleString()}`)
}
