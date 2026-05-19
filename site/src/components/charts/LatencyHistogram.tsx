'use client'

import { useEffect, useRef } from 'react'
import { select } from 'd3-selection'
import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line, area } from 'd3-shape'
import { getColors, typography, variantColorByIndex } from './theme'
import { tokens } from '@/lib/design-tokens'
import { appendGrid, appendLegendLines, appendLegendRects } from './d3helpers'
import { useTheme } from '@/hooks/useTheme'
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
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()

  useEffect(() => {
    if (!ref.current) return

    const ordered = variants
      ? variants.map((v) => runs.find((r) => r.variant === v)).filter(Boolean) as LatencyRun[]
      : runs
    const valid = ordered.filter((r) => r.latency_ns && r.latency_ns.counts.length > 0)

    select(ref.current).selectAll('*').remove()
    if (valid.length === 0) return

    if (view === 'ccdf') {
      renderCCDF(ref.current, valid, markers, ordered, title)
    } else {
      renderPDF(ref.current, valid, ordered, title)
    }
  }, [runs, variants, view, markers, title, theme])

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
  const colors = getColors()
  const W = el.clientWidth || 640
  const H = 360
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 80, left: 56 }
    : { top: 32, right: 120, bottom: 56, left: 72 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_CCDF)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

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

  markers.forEach((m) => {
    const ns = markerValues[m]
    if (!ns || ns <= 0) return
    const xPos = x(ns)
    g.append('line')
      .attr('x1', xPos).attr('x2', xPos)
      .attr('y1', 0).attr('y2', inner.h)
      .attr('stroke', colors.textMuted)
      .attr('stroke-width', 1)
      .attr('stroke-dasharray', '4,3')
    g.append('text')
      .attr('x', xPos + 3)
      .attr('y', 10)
      .attr('font-size', typography.captionSize)
      .attr('fill', colors.textMuted)
      .text(`${markerLabels[m]} ${ns} ns`)
  })

  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x).ticks(6, '~s').tickSize(0))
    .call((s) => s.select('.domain').attr('stroke', colors.border))
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
        .attr('dy', '1.4em')
    )
  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 6)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  g.append('g')
    .call(axisLeft(y).ticks(6, '~g'))
    .call((s) => s.select('.domain').remove())
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((s) => s.selectAll('line').remove())
  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 14)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('P(latency ≥ x)  — CCDF (log scale)')

  const legendX = isNarrow ? margin.left : margin.left + inner.w + 8
  const legendY = isNarrow ? margin.top + inner.h + 16 : margin.top
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
  const colors = getColors()
  const W = el.clientWidth || 640
  const H = 320
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 80, left: 56 }
    : { top: 32, right: 120, bottom: 56, left: 72 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE_PDF)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

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

  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axisBottom(x).ticks(6, '~s').tickSize(0))
    .call((s) => s.select('.domain').attr('stroke', colors.border))
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
        .attr('dy', '1.4em')
    )
  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 6)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  g.append('g')
    .call(axisLeft(y).ticks(5, '~g'))
    .call((s) => s.select('.domain').remove())
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
    )
    .call((s) => s.selectAll('line').remove())
  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 14)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('sample count (log scale)')

  const legendX = isNarrow ? margin.left : margin.left + inner.w + 8
  const legendY = isNarrow ? margin.top + inner.h + 16 : margin.top
  appendLegendRects(svg, allSeries.map(({ variant, color }) => ({ label: variant, color })),
    { x: legendX, y: legendY },
    { textSecondary: colors.textSecondary })
}
