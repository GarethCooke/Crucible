'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { colors, typography, palette } from './theme'
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
  stats: LatencyStats
}

export interface SweepRun {
  variant: string
  mode?: string
  offered_rate_hz?: number
  latency_ns?: LatencyHistogramData
  ops_per_sec?: number
}

// ─── Colour assignment ────────────────────────────────────────────────────────

function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length] as string
}

// Dash patterns to distinguish p50 / p99 / p99.9 lines within each variant
const STAT_DASH: Record<string, string> = {
  p50:   'none',
  p99:   '6,3',
  p99_9: '2,3',
}

const STAT_LABEL: Record<string, string> = {
  p50:   'p50',
  p99:   'p99',
  p99_9: 'p99.9',
}

const STATS_SHOWN = ['p50', 'p99', 'p99_9'] as const

// ─── Props ────────────────────────────────────────────────────────────────────

interface Props {
  runs: SweepRun[]
  variants?: string[]
}

// ─── Component ────────────────────────────────────────────────────────────────

export function LatencyVsLoadChart({ runs, variants }: Props) {
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    if (!ref.current) return

    const orderedVariants = variants
      ?? [...new Set(runs.map((r) => r.variant))]

    const valid = runs.filter(
      (r) =>
        r.offered_rate_hz != null &&
        r.offered_rate_hz > 0 &&
        r.latency_ns?.stats != null,
    )

    d3.select(ref.current).selectAll('*').remove()
    if (valid.length === 0) return

    render(ref.current, valid, orderedVariants)
  }, [runs, variants])

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

// ─── Renderer ─────────────────────────────────────────────────────────────────

function render(el: SVGSVGElement, runs: SweepRun[], orderedVariants: string[]) {
  const W = el.clientWidth || 680
  const H = 380
  const margin = { top: 32, right: 150, bottom: 60, left: 80 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  // Group runs by variant
  const byVariant = new Map<string, SweepRun[]>()
  for (const r of runs) {
    const arr = byVariant.get(r.variant) ?? []
    arr.push(r)
    byVariant.set(r.variant, arr)
  }

  // Sort each variant's points by offered_rate_hz
  for (const arr of byVariant.values()) {
    arr.sort((a, b) => (a.offered_rate_hz ?? 0) - (b.offered_rate_hz ?? 0))
  }

  // Global x/y extents
  let xMin = Infinity, xMax = 0, yMin = Infinity, yMax = 0
  for (const arr of byVariant.values()) {
    for (const r of arr) {
      const hz = r.offered_rate_hz!
      const s  = r.latency_ns!.stats
      if (hz < xMin) xMin = hz
      if (hz > xMax) xMax = hz
      for (const stat of STATS_SHOWN) {
        const v = s[stat as keyof LatencyStats] as number
        if (v > 0 && v < yMin) yMin = v
        if (v > yMax) yMax = v
      }
    }
  }

  const x = d3.scaleLog()
    .domain([xMin * 0.85, xMax * 1.2])
    .range([0, inner.w])
    .nice()

  const y = d3.scaleLog()
    .domain([Math.max(1, yMin * 0.7), yMax * 2])
    .range([inner.h, 0])
    .clamp(true)

  // Grid
  g.append('g')
    .call(d3.axisLeft(y).ticks(6, '~g').tickSize(-inner.w).tickFormat(() => ''))
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.border).attr('stroke-dasharray', '3,3'))

  g.append('g')
    .call(d3.axisBottom(x).ticks(6, '~s').tickSize(-inner.h).tickFormat(() => ''))
    .attr('transform', `translate(0,${inner.h})`)
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.border).attr('stroke-dasharray', '3,3'))

  const lineGen = d3.line<[number, number]>()
    .x((d) => x(d[0]))
    .y((d) => y(Math.max(1, d[1])))

  // Draw lines
  for (const [variantName, arr] of byVariant.entries()) {
    const varIdx = orderedVariants.indexOf(variantName)
    const color  = variantColorByIndex(varIdx < 0 ? 0 : varIdx)

    for (const stat of STATS_SHOWN) {
      const points: [number, number][] = arr
        .map((r) => [r.offered_rate_hz!, r.latency_ns!.stats[stat as keyof LatencyStats] as number] as [number, number])
        .filter(([, v]) => v > 0)

      if (points.length === 0) continue

      g.append('path')
        .datum(points)
        .attr('fill', 'none')
        .attr('stroke', color)
        .attr('stroke-width', stat === 'p50' ? 2 : 1.5)
        .attr('stroke-dasharray', STAT_DASH[stat])
        .attr('opacity', stat === 'p99_9' ? 0.7 : 1)
        .attr('d', lineGen)

      // Dots at each measured point
      g.selectAll(null)
        .data(points)
        .enter()
        .append('circle')
        .attr('cx', (d) => x(d[0]))
        .attr('cy', (d) => y(Math.max(1, d[1])))
        .attr('r', 2.5)
        .attr('fill', color)
        .attr('opacity', stat === 'p50' ? 1 : 0.6)
    }
  }

  // X axis
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(d3.axisBottom(x).ticks(6, '~s').tickSize(0))
    .call((s) => s.select('.domain').attr('stroke', colors.border))
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted)
        .attr('dy', '1.4em'),
    )
  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 6)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('offered load (items/sec, log scale)')

  // Y axis
  g.append('g')
    .call(d3.axisLeft(y).ticks(6, '~g'))
    .call((s) => s.select('.domain').remove())
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted),
    )
    .call((s) => s.selectAll('line').remove())
  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 16)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  // Legend — variant rows, then stat line-style key
  const legendX = margin.left + inner.w + 10
  let legendY = margin.top

  // Variant colour swatches
  orderedVariants.forEach((variantName, i) => {
    if (!byVariant.has(variantName)) return
    const color = variantColorByIndex(i)
    svg.append('line')
      .attr('x1', legendX).attr('x2', legendX + 18)
      .attr('y1', legendY + 5).attr('y2', legendY + 5)
      .attr('stroke', color).attr('stroke-width', 2)
    svg.append('text')
      .attr('x', legendX + 22)
      .attr('y', legendY + 9)
      .attr('font-size', 9)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(variantName)
    legendY += 17
  })

  // Stat dash key
  legendY += 6
  for (const stat of STATS_SHOWN) {
    svg.append('line')
      .attr('x1', legendX).attr('x2', legendX + 18)
      .attr('y1', legendY + 5).attr('y2', legendY + 5)
      .attr('stroke', colors.textMuted).attr('stroke-width', 1.5)
      .attr('stroke-dasharray', STAT_DASH[stat])
    svg.append('text')
      .attr('x', legendX + 22)
      .attr('y', legendY + 9)
      .attr('font-size', 9)
      .attr('fill', colors.textMuted)
      .attr('font-family', typography.fontMono)
      .text(STAT_LABEL[stat])
    legendY += 16
  }
}
