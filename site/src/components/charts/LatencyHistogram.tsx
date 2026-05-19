'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { getColors, typography, palette } from './theme'
import { useTheme } from '@/hooks/useTheme'
import { ChartZoom } from './ChartZoom'

// ─── Data types ───────────────────────────────────────────────────────────────

interface LatencyStats {
  count: number
  min: number
  max: number
  p50: number
  p90: number
  p99: number
  p99_9: number
}

interface LatencyHistogramData {
  scheme: string
  bucket_count: number
  min_bucket_ns: number
  counts: number[]
  stats: LatencyStats
}

export interface LatencyRun {
  variant: string
  latency_ns?: LatencyHistogramData
  ns_per_op?: { median: number; min: number; p99: number; iqr: number }
  ops_per_sec?: number
}

// ─── Bucket boundary reconstruction ──────────────────────────────────────────
// Matches histogram_bucket_lower() in bench/common/histogram.h.

function bucketLowerNs(i: number): number {
  if (i < 16) return i
  const idx = i - 16
  const hb  = Math.floor(idx / 16) + 4
  const sub = idx % 16
  return (1 << hb) | (sub << (hb - 4))
}

// ─── Colour assignment ────────────────────────────────────────────────────────

function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length] as string
}

// ─── Props ────────────────────────────────────────────────────────────────────

interface Props {
  runs: LatencyRun[]
  variants?: string[]
  view?: 'ccdf' | 'pdf'
  markers?: Array<'p50' | 'p99' | 'p99_9'>
}

// ─── Component ────────────────────────────────────────────────────────────────

export function LatencyHistogramChart({
  runs,
  variants,
  view = 'ccdf',
  markers = ['p50', 'p99', 'p99_9'],
}: Props) {
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()

  useEffect(() => {
    const colors = getColors()
    if (!ref.current) return

    const ordered = variants
      ? variants.map((v) => runs.find((r) => r.variant === v)).filter(Boolean) as LatencyRun[]
      : runs
    const valid = ordered.filter((r) => r.latency_ns && r.latency_ns.counts.length > 0)

    d3.select(ref.current).selectAll('*').remove()
    if (valid.length === 0) return

    if (view === 'ccdf') {
      renderCCDF(ref.current, valid, markers, ordered)
    } else {
      renderPDF(ref.current, valid, ordered)
    }
  }, [runs, variants, view, markers, theme])

  const colors = getColors()

  return (
    <ChartZoom>
      <figure className="my-8">
        <div
          className="rounded-xl border overflow-hidden"
          style={{ background: colors.bg, borderColor: colors.border }}
        >
          <svg ref={ref} className="w-full" style={{ display: 'block' }} />
        </div>
      </figure>
    </ChartZoom>
  )
}

// ─── CCDF renderer ────────────────────────────────────────────────────────────

function renderCCDF(
  el: SVGSVGElement,
  runs: LatencyRun[],
  markers: Array<'p50' | 'p99' | 'p99_9'>,
  allVariants: LatencyRun[],
) {
  const colors = getColors()
  const W = el.clientWidth || 640
  const H = 360
  const margin = { top: 32, right: 120, bottom: 56, left: 72 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  // Build CCDF data per variant.
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
      const y = 1 - (cumulative - cnt) / total  // CCDF = fraction with latency >= bucket lower
      if (x > 0) {
        points.push({ x, y })
        if (x < globalMinX) globalMinX = x
        if (x > globalMaxX) globalMaxX = x
        if (y < globalMinY && y > 0) globalMinY = y
      }
    }
    // Final point at maxval
    points.push({ x: h.stats.max, y: 1 / total })
    series.push({ variant: run.variant, color, points })
  }

  if (series.length === 0) return

  // Floor at a sensible power of 10, at most 1e-6
  const yFloor = Math.max(1e-6, Math.pow(10, Math.floor(Math.log10(globalMinY))))

  const x = d3.scaleLog()
    .domain([Math.max(1, globalMinX * 0.9), globalMaxX * 1.5])
    .range([0, inner.w])
    .nice()

  const y = d3.scaleLog()
    .domain([yFloor, 2])
    .range([inner.h, 0])
    .clamp(true)

  // Grid lines
  g.append('g')
    .attr('class', 'grid')
    .call(d3.axisLeft(y).ticks(6, '~g').tickSize(-inner.w).tickFormat(() => ''))
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.border).attr('stroke-dasharray', '3,3'))

  // Lines
  const line = d3.line<{ x: number; y: number }>()
    .x((d) => x(d.x))
    .y((d) => y(Math.max(yFloor, d.y)))
    .defined((d) => d.x > 0 && d.y > 0)

  series.forEach(({ points, color }) => {
    g.append('path')
      .datum(points)
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 2)
      .attr('d', line)
  })

  // Markers on the headline variant (first entry)
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
      .attr('font-size', 9)
      .attr('fill', colors.textMuted)
      .text(`${markerLabels[m]} ${ns} ns`)
  })

  // X axis
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(d3.axisBottom(x).ticks(6, '~s').tickSize(0))
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
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  // Y axis
  g.append('g')
    .call(d3.axisLeft(y).ticks(6, '~g'))
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
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('P(latency ≥ x)  — CCDF (log scale)')

  // Legend
  const legendX = margin.left + inner.w + 8
  series.forEach(({ variant, color }, i) => {
    svg.append('line')
      .attr('x1', legendX).attr('x2', legendX + 18)
      .attr('y1', margin.top + i * 18 + 5).attr('y2', margin.top + i * 18 + 5)
      .attr('stroke', color).attr('stroke-width', 2)
    svg.append('text')
      .attr('x', legendX + 22)
      .attr('y', margin.top + i * 18 + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(variant)
  })
}

// ─── PDF renderer ─────────────────────────────────────────────────────────────

function renderPDF(
  el: SVGSVGElement,
  runs: LatencyRun[],
  allVariants: LatencyRun[],
) {
  const colors = getColors()
  const W = el.clientWidth || 640
  const H = 320
  const margin = { top: 32, right: 120, bottom: 56, left: 72 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

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

  const x = d3.scaleLog()
    .domain([Math.max(1, globalMinX * 0.8), globalMaxX * 1.5])
    .range([0, inner.w])
    .nice()

  const y = d3.scaleLog()
    .domain([1, globalMaxY * 2])
    .range([inner.h, 0])
    .clamp(true)

  // Grid
  g.append('g')
    .call(d3.axisLeft(y).ticks(5, '~g').tickSize(-inner.w).tickFormat(() => ''))
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.border).attr('stroke-dasharray', '3,3'))

  // Areas + strokes per variant
  allSeries.forEach(({ segs, color }) => {
    const area = d3.area<Segment>()
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
      .attr('d', area)

    g.append('path')
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 1)
      .attr('d', linePath)
  })

  // X axis
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(d3.axisBottom(x).ticks(6, '~s').tickSize(0))
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
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  // Y axis
  g.append('g')
    .call(d3.axisLeft(y).ticks(5, '~g'))
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
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('sample count (log scale)')

  // Legend
  const legendX = margin.left + inner.w + 8
  allSeries.forEach(({ variant, color }, i) => {
    svg.append('rect')
      .attr('x', legendX).attr('y', margin.top + i * 18)
      .attr('width', 18).attr('height', 10)
      .attr('fill', color).attr('fill-opacity', 0.35).attr('rx', 2)
    svg.append('text')
      .attr('x', legendX + 22)
      .attr('y', margin.top + i * 18 + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(variant)
  })
}
