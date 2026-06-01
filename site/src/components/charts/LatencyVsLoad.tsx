'use client'

import { scaleLog } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line } from 'd3-shape'
import { typography, variantColorByIndex } from './theme'
import {
  appendGrid, appendLegendLines,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel, legendPosition,
} from './d3helpers'
import { tokens } from '@/lib/design-tokens'
import { useChartEffect } from '@/hooks/useChartEffect'
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
  /** Ratio (achieved/offered) below which a point is considered decoupled. Default 0.9. */
  decoupleThreshold?: number
  /** When true, render the decoupled tail as a faint dashed continuation. Default false. */
  showDecoupledTail?: boolean
}

export function LatencyVsLoadChart({ runs, variants, title, decoupleThreshold = 0.9, showDecoupledTail = false }: Props) {
  const ref = useChartEffect((el) => {
    const orderedVariants = variants ?? [...new Set(runs.map((r) => r.variant))]
    const valid = runs.filter(
      (r) =>
        r.offered_rate_hz != null &&
        r.offered_rate_hz > 0 &&
        r.latency_ns?.stats != null,
    )
    if (valid.length === 0) return
    render(el, valid, orderedVariants, title, decoupleThreshold, showDecoupledTail)
  }, [runs, variants, title, decoupleThreshold, showDecoupledTail])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Latency vs offered load'} />
    </ChartZoom>
  )
}

function render(el: SVGSVGElement, runs: SweepRun[], orderedVariants: string[], title?: string, decoupleThreshold = 0.9, showDecoupledTail = false) {
  const H = 380
  const W = el.clientWidth || 680
  const isNarrow = W < tokens.chart.mobileBreakpoint
  const margin = isNarrow
    ? { top: 32, right: 16, bottom: 130, left: 80 }
    : { top: 32, right: 150, bottom: 60, left: 80 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  const byVariant = new Map<string, SweepRun[]>()
  for (const r of runs) {
    const arr = byVariant.get(r.variant) ?? []
    arr.push(r)
    byVariant.set(r.variant, arr)
  }

  for (const arr of byVariant.values()) {
    arr.sort((a, b) => (a.offered_rate_hz ?? 0) - (b.offered_rate_hz ?? 0))
  }

  // Compute decoupling index per variant: first point where achieved/offered < threshold.
  // All points at and before this index are "coupled" (drawn solid); points after are the
  // non-physical tail (clipped by default, shown faint when showDecoupledTail=true).
  const decoupleIdxByVariant = new Map<string, number>()
  for (const [name, arr] of byVariant.entries()) {
    const idx = arr.findIndex((r) => {
      const offered = r.offered_rate_hz ?? 0
      const achieved = r.ops_per_sec ?? 0
      return offered > 0 && achieved > 0 && achieved / offered < decoupleThreshold
    })
    decoupleIdxByVariant.set(name, idx)
  }

  // Scale domains use all points so the axes are stable regardless of tail visibility.
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
    const color  = variantColorByIndex(varIdx)

    const decoupleIdx = decoupleIdxByVariant.get(variantName) ?? -1
    // splitIdx: index of the first decoupled point (included in the solid line).
    // -1 means no decoupling found; treat all points as coupled.
    const splitIdx = decoupleIdx === -1 ? arr.length - 1 : decoupleIdx
    const coupledArr = arr.slice(0, splitIdx + 1)
    const tailArr    = arr.slice(splitIdx + 1)

    for (const stat of STATS_SHOWN) {
      const coupled: [number, number][] = coupledArr
        .map((r) => [r.offered_rate_hz!, r.latency_ns!.stats[stat as keyof LatencyStats] as number] as [number, number])
        .filter(([, v]) => v > 0)

      if (coupled.length === 0) continue

      // Solid coupled line
      g.append('path')
        .datum(coupled)
        .attr('fill', 'none')
        .attr('stroke', color)
        .attr('stroke-width', stat === 'p50' ? 2 : 1.5)
        .attr('stroke-dasharray', STAT_DASH[stat])
        .attr('opacity', stat === 'p99_9' ? 0.7 : 1)
        .attr('d', lineGen)

      g.selectAll(null)
        .data(coupled)
        .enter()
        .append('circle')
        .attr('cx', (d) => x(d[0]))
        .attr('cy', (d) => y(Math.max(1, d[1])))
        .attr('r', 2.5)
        .attr('fill', color)
        .attr('opacity', stat === 'p50' ? 1 : 0.6)

      // Faint dashed tail (non-physical regime), connected from last coupled point
      if (showDecoupledTail && tailArr.length > 0) {
        const tailData: [number, number][] = tailArr
          .map((r) => [r.offered_rate_hz!, r.latency_ns!.stats[stat as keyof LatencyStats] as number] as [number, number])
          .filter(([, v]) => v > 0)

        if (tailData.length > 0) {
          const tailPath: [number, number][] = [coupled[coupled.length - 1], ...tailData]
          g.append('path')
            .datum(tailPath)
            .attr('fill', 'none')
            .attr('stroke', color)
            .attr('stroke-width', stat === 'p50' ? 1.5 : 1)
            .attr('stroke-dasharray', '4,4')
            .attr('opacity', 0.3)
            .attr('d', lineGen)

          g.selectAll(null)
            .data(tailData)
            .enter()
            .append('circle')
            .attr('cx', (d) => x(d[0]))
            .attr('cy', (d) => y(Math.max(1, d[1])))
            .attr('r', 2)
            .attr('fill', color)
            .attr('opacity', 0.25)
        }
      }
    }

    // One hollow-circle marker per variant at the decoupling point (p50 y-coordinate)
    if (decoupleIdx !== -1) {
      const dr = arr[decoupleIdx]
      if (dr.offered_rate_hz && dr.latency_ns?.stats.p50) {
        g.append('circle')
          .attr('cx', x(dr.offered_rate_hz))
          .attr('cy', y(Math.max(1, dr.latency_ns.stats.p50)))
          .attr('r', 5.5)
          .attr('fill', 'none')
          .attr('stroke', color)
          .attr('stroke-width', 1.5)
      }
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

  appendXAxis(g, inner, colors, xAxis)
  appendXLabel(svg, 'offered load (items/sec, log scale)', margin.left + inner.w / 2, H - 18, colors)
  if (!isNarrow) {
    svg.append('text')
      .attr('x', margin.left + inner.w / 2)
      .attr('y', H - 4)
      .attr('text-anchor', 'middle')
      .attr('font-size', '9px')
      .attr('font-family', typography.fontMono)
      .attr('fill', colors.textMuted)
      .text('x-axis is offered (requested) load; each curve stops where the variant\'s achieved throughput plateaus')
  }

  appendYAxis(g, colors, axisLeft(y).ticks(6, '~g'))
  appendYLabel(svg, 'latency (ns, log scale)', -(margin.top + inner.h / 2), 16, colors)

  // Legend — variant colour swatches then stat dash key
  const { x: legendX, y: legendBaseY } = legendPosition(isNarrow, margin, inner, 10)

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
