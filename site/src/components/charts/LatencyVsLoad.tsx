'use client'

import { useEffect, useRef } from 'react'
import { select } from 'd3-selection'
import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line } from 'd3-shape'
import { getColors, typography, variantColorByIndex } from './theme'
import { appendGrid, appendLegendLines } from './d3helpers'
import { tokens } from '@/lib/design-tokens'
import { useTheme } from '@/hooks/useTheme'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import type { LatencyStats, LatencyStatsOnly } from '@/lib/perf-types'

export interface SweepRun {
  variant: string
  mode?: string
  offered_rate_hz?: number
  latency_ns?: LatencyStatsOnly
  ops_per_sec?: number
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

const DEFAULT_TITLE = 'Latency vs offered load chart'

interface Props {
  runs: SweepRun[]
  variants?: string[]
  title?: string
}

export function LatencyVsLoadChart({ runs, variants, title }: Props) {
  const ref = useRef<SVGSVGElement>(null)
  const theme = useTheme()

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

    select(ref.current).selectAll('*').remove()
    if (valid.length === 0) return

    render(ref.current, valid, orderedVariants, title)
  }, [runs, variants, title, theme])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Latency vs offered load'} />
    </ChartZoom>
  )
}

function render(el: SVGSVGElement, runs: SweepRun[], orderedVariants: string[], title?: string) {
  const colors = getColors()
  const W = el.clientWidth || 680
  const H = 380
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 130, left: 80 }
    : { top: 32, right: 150, bottom: 60, left: 80 }
  const inner  = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title ?? DEFAULT_TITLE)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const byVariant = new Map<string, SweepRun[]>()
  for (const r of runs) {
    const arr = byVariant.get(r.variant) ?? []
    arr.push(r)
    byVariant.set(r.variant, arr)
  }

  for (const arr of byVariant.values()) {
    arr.sort((a, b) => (a.offered_rate_hz ?? 0) - (b.offered_rate_hz ?? 0))
  }

  let xMin = Infinity, xMax = 0, yMin = Infinity, yMax = 0
  for (const arr of byVariant.values()) {
    for (const r of arr) {
      const hz = r.offered_rate_hz!
      const s  = r.latency_ns!.stats
      if (hz < xMin) xMin = hz
      if (hz > xMax) xMax = hz
      for (const stat of STATS_SHOWN) {
        const v = s[stat as keyof typeof s] as number
        if (v > 0 && v < yMin) yMin = v
        if (v > yMax) yMax = v
      }
    }
  }

  const x = scaleLog()
    .domain([xMin * 0.85, xMax * 1.2])
    .range([0, inner.w])
    .nice()

  const y = scaleLog()
    .domain([Math.max(1, yMin * 0.7), yMax * 2])
    .range([inner.h, 0])
    .clamp(true)

  appendGrid(g, y, inner, { gridline: colors.border }, undefined,
    isNarrow ? { y: 4 } : undefined)

  const lineGen = line<[number, number]>()
    .x((d) => x(d[0]))
    .y((d) => y(Math.max(1, d[1])))

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

  const xAxis = isNarrow
    ? axisBottom(x).tickValues([1e4, 1e5, 1e6, 1e8]).tickFormat((d) => {
        const n = +d
        if (n >= 1e8) return '100M'
        if (n >= 1e6) return '1M'
        if (n >= 1e5) return '100k'
        return '10k'
      }).tickSize(0)
    : axisBottom(x).ticks(6, '~s').tickSize(0)

  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(xAxis)
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
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('offered load (items/sec, log scale)')

  g.append('g')
    .call(axisLeft(y).ticks(6, '~g'))
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
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('latency (ns, log scale)')

  // Legend — variant colour swatches then stat dash key
  const legendX = isNarrow ? margin.left : margin.left + inner.w + 10
  const legendBaseY = isNarrow ? margin.top + inner.h + 16 : margin.top

  const variantItems = orderedVariants
    .filter((v) => byVariant.has(v))
    .map((v, i) => ({ label: v, color: variantColorByIndex(i) }))

  appendLegendLines(svg, variantItems,
    { x: legendX, y: legendBaseY, spacing: 17 },
    { textSecondary: colors.textSecondary })

  const statKeyY = isNarrow
    ? legendBaseY + variantItems.length * 17 + 8
    : margin.top + variantItems.length * 17 + 6
  appendLegendLines(svg, STATS_SHOWN.map((stat) => ({
    label: STAT_LABEL[stat],
    color: colors.textMuted,
    dash:  STAT_DASH[stat],
  })), { x: legendX, y: statKeyY, spacing: 16 }, { textSecondary: colors.textMuted })
}
