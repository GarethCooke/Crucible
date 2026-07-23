'use client'

import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line } from 'd3-shape'
import { variantColorByIndex, typography } from './theme'
import {
  appendGrid, appendLegendLines,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel, legendPosition,
} from './d3helpers'
import { tokens } from '@/lib/design-tokens'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import type { PressureSweepRun, LatencyStats } from '@/lib/perf-types'

export type PressureMetric = 'p50' | 'p99' | 'p99_9'

const METRIC_LABEL: Record<PressureMetric, string> = {
  p50:   'p50',
  p99:   'p99',
  p99_9: 'p99.9',
}

interface Props {
  runs: PressureSweepRun[]
  variants?: string[]
  metric?: PressureMetric
  yAxisLabel?: string
  title?: string
}

export function PressureSweepChart({
  runs,
  variants,
  metric = 'p99_9',
  yAxisLabel,
  title,
}: Props) {
  const ref = useChartEffect((el) => {
    const orderedVariants = variants ?? [...new Set(runs.map((r) => r.variant))]
    if (runs.length === 0) return
    render(el, runs, orderedVariants, metric, yAxisLabel, title)
  }, [runs, variants, metric, yAxisLabel, title])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Pressure sweep chart'} />
    </ChartZoom>
  )
}

function getStatValue(run: PressureSweepRun, metric: PressureMetric): number {
  const stats = run.latency_ns?.stats
  if (!stats) return 0
  return stats[metric as keyof LatencyStats] as number
}

function render(
  el: SVGSVGElement,
  runs: PressureSweepRun[],
  orderedVariants: string[],
  metric: PressureMetric,
  yAxisLabel?: string,
  title?: string,
) {
  const H = 380
  const W = el.clientWidth || 680
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 130, left: 80 }
    : { top: 32, right: 150, bottom: 60, left: 80 }
  const { svg, g, inner, colors } = setupSVG(
    el, W, H, margin, title ?? 'Background pressure vs tail latency',
  )

  // Separate null-background (no-T_bg) runs from pressure sweep runs.
  const baselineRuns = runs.filter((r) => r.background_pressure_hz === null)
  const sweepRuns    = runs.filter((r) => r.background_pressure_hz !== null && (r.background_pressure_hz ?? 0) > 0)

  // Group sweep runs by variant.
  const byVariant = new Map<string, PressureSweepRun[]>()
  for (const r of sweepRuns) {
    const arr = byVariant.get(r.variant) ?? []
    arr.push(r)
    byVariant.set(r.variant, arr)
  }
  for (const arr of byVariant.values()) {
    arr.sort((a, b) => (a.background_pressure_hz ?? 0) - (b.background_pressure_hz ?? 0))
  }

  // Determine x and y extents.
  let xMin = Infinity, xMax = 0, yMin = Infinity, yMax = 0
  for (const arr of byVariant.values()) {
    for (const r of arr) {
      const hz = r.background_pressure_hz!
      const v  = getStatValue(r, metric)
      if (hz > 0 && hz < xMin) xMin = hz
      if (hz > xMax) xMax = hz
      if (v > 0 && v < yMin) yMin = v
      if (v > yMax) yMax = v
    }
  }
  // Include baseline values in y extent.
  for (const r of baselineRuns) {
    const v = getStatValue(r, metric)
    if (v > 0 && v < yMin) yMin = v
    if (v > yMax) yMax = v
  }

  if (xMin === Infinity || xMax === 0) return

  // Categorical "none" (no-T_bg) slot at the far left, separated from the log
  // scale by a visible gap / axis break. The log axis starts at LOG_START so the
  // anchor never reads as a numeric pressure value.
  const NONE_SLOT_X = 8
  const LOG_START   = 56

  const x = scaleLog()
    .domain([xMin * 0.8, xMax * 1.25])
    .range([LOG_START, inner.w])
    .nice()

  const y = scaleLog()
    .domain([Math.max(1, yMin * 0.7), yMax * 2])
    .range([inner.h, 0])
    .clamp(true)

  appendGrid(g, y, inner, { gridline: colors.border }, undefined,
    isNarrow ? { y: 4 } : undefined)

  // Series points carry pre-computed pixel x so the no-pressure anchor (which has
  // no place on the log scale) can sit at the fixed NONE_SLOT_X alongside the
  // log-mapped sweep points.
  type Pt = { px: number; v: number }
  const lineGen = line<Pt>()
    .x((d) => d.px)
    .y((d) => y(Math.max(1, d.v)))

  // Draw one line per variant: a no-pressure anchor at the "none" slot, a dashed
  // bridge across the axis break to the first pressure point, then a solid line
  // through the log-spaced sweep.
  for (const [variantName, arr] of byVariant.entries()) {
    const varIdx = orderedVariants.indexOf(variantName)
    const color  = variantColorByIndex(varIdx)

    const sweepPts: Pt[] = arr
      .map((r) => ({ px: x(r.background_pressure_hz!), v: getStatValue(r, metric) }))
      .filter((p) => p.v > 0)

    const baseRun = baselineRuns.find((r) => r.variant === variantName)
    const baseV   = baseRun ? getStatValue(baseRun, metric) : 0
    const anchor: Pt | null = baseV > 0 ? { px: NONE_SLOT_X, v: baseV } : null

    if (sweepPts.length === 0 && !anchor) continue

    // Bridge segment: dashed, since it crosses the axis break and isn't a
    // continuous log interval.
    if (anchor && sweepPts.length > 0) {
      g.append('path')
        .datum([anchor, sweepPts[0]])
        .attr('fill', 'none')
        .attr('stroke', color)
        .attr('stroke-width', 2)
        .attr('stroke-dasharray', '4,4')
        .attr('d', lineGen)
    }

    // Solid sweep line across the log region.
    if (sweepPts.length > 0) {
      g.append('path')
        .datum(sweepPts)
        .attr('fill', 'none')
        .attr('stroke', color)
        .attr('stroke-width', 2)
        .attr('d', lineGen)
    }

    // Marker dots: no-pressure anchor + each sweep step.
    const allPts = anchor ? [anchor, ...sweepPts] : sweepPts
    g.selectAll(null)
      .data(allPts)
      .enter()
      .append('circle')
      .attr('cx', (d) => d.px)
      .attr('cy', (d) => y(Math.max(1, d.v)))
      .attr('r', 3.5)
      .attr('fill', color)
  }

  // Axes.
  const xAxis = isNarrow
    ? axisBottom(x).tickValues([1e4, 1e5, 1e6, 1e7]).tickFormat((d) => {
        const n = +d
        if (n >= 1e7) return '10M'
        if (n >= 1e6) return '1M'
        if (n >= 1e5) return '100k'
        return '10k'
      }).tickSize(0)
    : axisBottom(x).ticks(6, '~s').tickSize(0)

  appendXAxis(g, inner, colors, xAxis)
  appendXLabel(svg, 'background pressure (ops/sec, log scale)', margin.left + inner.w / 2, H - 6, colors)

  // Categorical "none" tick at the no-pressure slot, set apart from the log ticks.
  g.append('text')
    .attr('x', NONE_SLOT_X)
    .attr('y', inner.h)
    .attr('dy', '1.4em')
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.axisSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('none')

  // Axis-break glyph (//) in the gap, signalling the discontinuity between the
  // categorical "none" slot and the log scale.
  const breakX = (NONE_SLOT_X + LOG_START) / 2
  for (const off of [-3, 3]) {
    g.append('line')
      .attr('x1', breakX + off - 3).attr('y1', inner.h + 5)
      .attr('x2', breakX + off + 3).attr('y2', inner.h - 5)
      .attr('stroke', colors.textMuted)
      .attr('stroke-width', 1)
  }

  appendYAxis(g, colors, axisLeft(y).ticks(6, '~g'))
  appendYLabel(svg, yAxisLabel ?? `${METRIC_LABEL[metric]} latency (ns, log scale)`, -(margin.top + inner.h / 2), 16, colors)

  // Legend.
  const { x: legendX, y: legendY } = legendPosition(isNarrow, margin, inner, 10)

  const variantItems = orderedVariants
    .filter((v) => byVariant.has(v))
    .map((v, i) => ({ label: v, color: variantColorByIndex(i) }))

  appendLegendLines(svg, variantItems,
    { x: legendX, y: legendY, spacing: 17 },
    { textSecondary: colors.textSecondary })
}
