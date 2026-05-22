'use client'

import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line, area } from 'd3-shape'
import { typography, variantColorByIndex } from './theme'
import { tokens } from '@/lib/design-tokens'
import {
  appendGrid, appendLegendLines, appendLegendRects,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel, legendPosition,
} from './d3helpers'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import type { LatencyHistogramData } from '@/lib/perf-types'

// ─── Bucket boundary reconstruction ──────────────────────────────────────────
// Matches histogram_bucket_lower() in bench/common/histogram.h.

function bucketLowerNs(i: number): number {
  if (i < 16) return i
  const idx = i - 16
  const hb  = Math.floor(idx / 16) + 4
  const sub = idx % 16
  return (1 << hb) | (sub << (hb - 4))
}

// ─── Props ────────────────────────────────────────────────────────────────────

export interface LatencyRun {
  variant: string
  latency_ns?: LatencyHistogramData
  ns_per_op?: { median: number; min: number; p99: number; iqr: number }
  ops_per_sec?: number
}

interface Props {
  runs: LatencyRun[]
  variants?: string[]
  view?: 'ccdf' | 'pdf'
  markers?: Array<'p50' | 'p99' | 'p99_9'>
  title?: string
}

const DEFAULT_TITLE_CCDF = 'Latency CCDF chart'
const DEFAULT_TITLE_PDF  = 'Latency distribution chart'

// ─── Component ────────────────────────────────────────────────────────────────

export function LatencyHistogramChart({
  runs,
  variants,
  view = 'ccdf',
  markers = ['p50', 'p99', 'p99_9'],
  title,
}: Props) {
  const ref = useChartEffect((el) => {
    const ordered = variants
      ? variants.map((v) => runs.find((r) => r.variant === v)).filter(Boolean) as LatencyRun[]
      : runs
    const valid = ordered.filter((r) => r.latency_ns && r.latency_ns.counts.length > 0)
    if (valid.length === 0) return

    if (view === 'ccdf') {
      renderCCDF(el, valid, markers, ordered, title)
    } else {
      renderPDF(el, valid, ordered, title)
    }
  }, [runs, variants, view, markers, title])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Latency histogram'} />
    </ChartZoom>
  )
}

// ─── CCDF renderer ────────────────────────────────────────────────────────────

function renderCCDF(
  el: SVGSVGElement,
  runs: LatencyRun[],
  markers: Array<'p50' | 'p99' | 'p99_9'>,
  allVariants: LatencyRun[],
  title?: string,
) {
  const H = 360
  const W = el.clientWidth || 640
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 80, left: 56 }
    : { top: 32, right: 120, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE_CCDF)

  type Point = { x: number; y: number }
  const series: Array<{ variant: string; color: string; points: Point[] }> = []

  let globalMinX = Infinity, globalMaxX = 0
  let globalMinY = 1

  for (const run of runs) {
    const h = run.latency_ns!
    const total = h.stats.count
    if (total === 0) continue

    const color = variantColorByIndex(allVariants.findIndex((r) => r.variant === run.variant))
    const points: Point[] = []
    let cumulative = 0

    for (let i = 0; i < h.bucket_count; ++i) {
      const cnt = h.counts[i] ?? 0
      if (cnt === 0) continue
      cumulative += cnt
      const x = bucketLowerNs(i)
      const y = 1 - (cumulative - cnt) / total
      if (x > 0) {
        points.push({ x, y })
        if (x < globalMinX) globalMinX = x
        if (x > globalMaxX) globalMaxX = x
        if (y < globalMinY && y > 0) globalMinY = y
      }
    }
    points.push({ x: h.stats.max, y: 1 / total })
    series.push({ variant: run.variant, color, points })
  }

  if (series.length === 0) return

  const yFloor = Math.max(1e-6, Math.pow(10, Math.floor(Math.log10(globalMinY))))

  const x = scaleLog()
    .domain([Math.max(1, globalMinX * 0.9), globalMaxX * 1.5])
    .range([0, inner.w])
    .nice()

  const y = scaleLog()
    .domain([yFloor, 2])
    .range([inner.h, 0])
    .clamp(true)

  appendGrid(g, y, inner, { gridline: colors.border })

  const lineGen = line<{ x: number; y: number }>()
    .x((d) => x(d.x))
    .y((d) => y(Math.max(yFloor, d.y)))
    .defined((d) => d.x > 0 && d.y > 0)

  series.forEach(({ points, color }) => {
    g.append('path')
      .datum(points)
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 2)
      .attr('d', lineGen)
  })

  const headline = runs[0].latency_ns!
  const markerValues: Record<string, number> = {
    p50:   headline.stats.p50,
    p99:   headline.stats.p99,
    p99_9: headline.stats.p99_9,
  }
  const markerLabels: Record<string, string> = {
    p50:   'p50',
    p99:   'p99',
    p99_9: 'p99.9',
  }

  markers.forEach((m, i) => {
    const ns = markerValues[m]
    if (!ns || ns <= 0) return
    const xPos = x(ns)
    const labelY = 10 + i * 12
    g.append('line')
      .attr('x1', xPos).attr('x2', xPos)
      .attr('y1', 0).attr('y2', inner.h)
      .attr('stroke', colors.textMuted)
      .attr('stroke-width', 1)
      .attr('stroke-dasharray', '4,3')
    g.append('text')
      .attr('x', xPos + 3)
      .attr('y', labelY)
      .attr('font-size', typography.captionSize)
      .attr('fill', colors.textMuted)
      .text(`${markerLabels[m]} ${ns} ns`)
  })

  appendXAxis(g, inner, colors, axisBottom(x).ticks(6, '~s').tickSize(0))
  appendXLabel(svg, 'latency (ns, log scale)', margin.left + inner.w / 2, H - 6, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(6, '~g'))
  appendYLabel(svg, 'P(latency ≥ x)  — CCDF (log scale)', -(margin.top + inner.h / 2), 14, colors)

  const { x: legendX, y: legendY } = legendPosition(isNarrow, margin, inner)
  appendLegendLines(svg, series.map(({ variant, color }) => ({ label: variant, color })),
    { x: legendX, y: legendY },
    { textSecondary: colors.textSecondary })
}

// ─── PDF renderer ─────────────────────────────────────────────────────────────

function renderPDF(
  el: SVGSVGElement,
  runs: LatencyRun[],
  allVariants: LatencyRun[],
  title?: string,
) {
  const H = 320
  const W = el.clientWidth || 640
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 80, left: 56 }
    : { top: 32, right: 120, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE_PDF)

  type Segment = { x0: number; x1: number; y: number }
  const allSeries: Array<{ variant: string; color: string; segs: Segment[] }> = []

  let globalMinX = Infinity, globalMaxX = 0, globalMaxY = 0

  for (const run of runs) {
    const h = run.latency_ns!
    if (h.stats.count === 0) continue

    const color = variantColorByIndex(allVariants.findIndex((r) => r.variant === run.variant))
    const segs: Segment[] = []

    for (let i = 1; i < h.bucket_count - 1; ++i) {
      const cnt = h.counts[i] ?? 0
      if (cnt === 0) continue
      const x0 = bucketLowerNs(i)
      const x1 = bucketLowerNs(i + 1)
      if (x0 <= 0 || x1 <= x0) continue
      segs.push({ x0, x1, y: cnt })
      if (x0 < globalMinX) globalMinX = x0
      if (x1 > globalMaxX) globalMaxX = x1
      if (cnt > globalMaxY) globalMaxY = cnt
    }
    allSeries.push({ variant: run.variant, color, segs })
  }

  if (allSeries.length === 0) return

  const x = scaleLog()
    .domain([Math.max(1, globalMinX * 0.8), globalMaxX * 1.5])
    .range([0, inner.w])
    .nice()

  const y = scaleLog()
    .domain([1, globalMaxY * 2])
    .range([inner.h, 0])
    .clamp(true)

  appendGrid(g, y, inner, { gridline: colors.border })

  allSeries.forEach(({ segs, color }) => {
    const areaGen = area<Segment>()
      .x0((d) => x(d.x0))
      .x1((d) => x(d.x1))
      .y0(inner.h)
      .y1((d) => y(Math.max(1, d.y)))

    const linePath = segs.map((d) =>
      `M${x(d.x0)},${y(Math.max(1, d.y))} L${x(d.x1)},${y(Math.max(1, d.y))}`
    ).join(' ')

    g.append('path')
      .datum(segs)
      .attr('fill', color)
      .attr('fill-opacity', 0.2)
      .attr('d', areaGen)

    g.append('path')
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 1)
      .attr('d', linePath)
  })

  appendXAxis(g, inner, colors, axisBottom(x).ticks(6, '~s').tickSize(0))
  appendXLabel(svg, 'latency (ns, log scale)', margin.left + inner.w / 2, H - 6, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(5, '~g'))
  appendYLabel(svg, 'sample count (log scale)', -(margin.top + inner.h / 2), 14, colors)

  const { x: legendX, y: legendY } = legendPosition(isNarrow, margin, inner)
  appendLegendRects(svg, allSeries.map(({ variant, color }) => ({ label: variant, color })),
    { x: legendX, y: legendY },
    { textSecondary: colors.textSecondary })
}
