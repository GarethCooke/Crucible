'use client'

import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line } from 'd3-shape'
import { variantColorByIndex } from './theme'
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

  const x = scaleLog()
    .domain([xMin * 0.8, xMax * 1.25])
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

  // Draw one line per variant.
  for (const [variantName, arr] of byVariant.entries()) {
    const varIdx = orderedVariants.indexOf(variantName)
    const color  = variantColorByIndex(varIdx)

    const points: [number, number][] = arr
      .map((r) => [r.background_pressure_hz!, getStatValue(r, metric)] as [number, number])
      .filter(([, v]) => v > 0)

    if (points.length === 0) continue

    g.append('path')
      .datum(points)
      .attr('fill', 'none')
      .attr('stroke', color)
      .attr('stroke-width', 2)
      .attr('d', lineGen)

    // Marker dots at each sweep step.
    g.selectAll(null)
      .data(points)
      .enter()
      .append('circle')
      .attr('cx', (d) => x(d[0]))
      .attr('cy', (d) => y(Math.max(1, d[1])))
      .attr('r', 3.5)
      .attr('fill', color)
  }

  // Draw faint horizontal reference lines for each variant's no-T_bg baseline.
  for (const baseRun of baselineRuns) {
    const varIdx = orderedVariants.indexOf(baseRun.variant)
    const color  = variantColorByIndex(varIdx)
    const v      = getStatValue(baseRun, metric)
    if (v <= 0) continue

    g.append('line')
      .attr('x1', 0)
      .attr('x2', inner.w)
      .attr('y1', y(v))
      .attr('y2', y(v))
      .attr('stroke', color)
      .attr('stroke-width', 1)
      .attr('stroke-dasharray', '4,4')
      .attr('opacity', 0.35)
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

  // Baseline key entry (if present).
  if (baselineRuns.length > 0) {
    const baseY = isNarrow
      ? legendY + variantItems.length * 17 + 8
      : legendY + variantItems.length * 17 + 6
    appendLegendLines(svg,
      [{ label: 'no pressure', color: colors.textMuted, dash: '4,4' }],
      { x: legendX, y: baseY, spacing: 16 },
      { textSecondary: colors.textMuted },
    )
  }
}
