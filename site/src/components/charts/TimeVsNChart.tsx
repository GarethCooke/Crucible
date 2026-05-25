'use client'

import { scaleLog, scaleLinear, scalePoint } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { max } from 'd3-array'
import { line } from 'd3-shape'
import { typography, variantColor } from './theme'
import {
  appendGrid, appendLegendLines,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel,
} from './d3helpers'
import { capitalize, uniqueSortedNs } from '@/lib/format'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'

export interface TimeVsNRun {
  variant: string
  n: number
  k?: number
  modify_pct?: number
  workload?: string
  ns_per_op: { median: number; min: number; p99: number; iqr: number }
}

export interface ThresholdMarker { label: string; n: number }

interface Props {
  runs: TimeVsNRun[]
  stat?: 'median' | 'min' | 'p99'
  title?: string
  yAxisLabel?: string
  kFilter?: number | 'all'
  nFilter?: number
  xAxis?: 'n' | 'k' | 'modify_pct'
  thresholdMarkers?: ThresholdMarker[]
  /** Annotate the largest sorted/unsorted gap (demo 1 only). Default false. */
  annotateMaxGap?: boolean
}

// Dash patterns keyed by K value. K=1 is solid.
const K_DASH: Record<number, string> = {
  1:  'none',
  2:  '6,3',
  4:  '2,2',
  8:  '8,2,2,2',
  16: '12,4',
}

export function TimeVsNChart({ runs, stat = 'median', title, yAxisLabel, kFilter, nFilter, xAxis = 'n', thresholdMarkers, annotateMaxGap = false }: Props) {
  const ref = useChartEffect((el) => {
    if (runs.length === 0) return
    if (xAxis === 'k') {
      renderKAxis(el, runs, stat, title, yAxisLabel)
    } else if (xAxis === 'modify_pct') {
      renderModifyPctAxis(el, runs, stat, title, yAxisLabel, nFilter)
    } else {
      renderNAxis(el, runs, stat, title, yAxisLabel, kFilter, thresholdMarkers, annotateMaxGap)
    }
  }, [runs, stat, title, yAxisLabel, kFilter, nFilter, xAxis, thresholdMarkers, annotateMaxGap])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Time vs N benchmark'} />
    </ChartZoom>
  )
}

const DEFAULT_TITLE = 'Time vs N benchmark chart'

function renderNAxis(
  el: SVGSVGElement,
  runs: TimeVsNRun[],
  stat: 'median' | 'min' | 'p99',
  title?: string,
  yAxisLabel?: string,
  kFilter?: number | 'all',
  thresholdMarkers?: ThresholdMarker[],
  annotateMaxGap = false,
) {
  const groupByK = kFilter === 'all'
  const H = 320
  const W = el.clientWidth || 700
  // Extra right margin when showing a multi-K fan legend (up to 10 entries).
  const margin = { top: 32, right: groupByK ? 160 : 112, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  const ns = uniqueSortedNs(runs)
  const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median

  const x = scaleLog().domain([ns[0], ns[ns.length - 1]]).range([0, inner.w])
  const allY = runs.map(nsPerElem)
  const y = scaleLinear().domain([0, max(allY)! * 1.15]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  // Threshold markers drawn first so they sit behind data lines.
  // A marker whose x-coordinate exceeds the data extent is silently suppressed
  // rather than pushing the axis or crashing.
  if (thresholdMarkers) {
    let prevX = -Infinity
    thresholdMarkers.forEach((marker) => {
      const xPos = x(marker.n)
      if (!isFinite(xPos) || xPos > inner.w || xPos < 0) return

      g.append('line')
        .attr('x1', xPos).attr('x2', xPos)
        .attr('y1', 0).attr('y2', inner.h)
        .attr('stroke', colors.textMuted)
        .attr('stroke-width', 1)
        .attr('stroke-dasharray', '4,2')
        .attr('opacity', 0.6)

      // Stack label below the previous one if they are close (< 30 px apart).
      const labelY = (xPos - prevX) < 30 ? 22 : 10
      prevX = xPos

      g.append('text')
        .attr('x', xPos + 4)
        .attr('y', labelY)
        .attr('font-size', 10)
        .attr('fill', colors.textMuted)
        .attr('font-family', typography.fontMono)
        .text(marker.label)
    })
  }

  // Build series list: one entry per (variant, k) when kFilter="all", else per variant.
  type Series = { variant: string; k?: number; runs: TimeVsNRun[] }
  let seriesList: Series[]

  if (groupByK) {
    const seen = new Map<string, { variant: string; k?: number }>()
    runs.forEach((r) => {
      const key = `${r.variant}|${r.k}`
      if (!seen.has(key)) seen.set(key, { variant: r.variant, k: r.k })
    })
    const pairs = Array.from(seen.values())
      .sort((a, b) => a.variant.localeCompare(b.variant) || (a.k ?? 0) - (b.k ?? 0))
    seriesList = pairs.map(({ variant, k }) => ({
      variant,
      k,
      runs: runs.filter((r) => r.variant === variant && r.k === k).sort((a, b) => a.n - b.n),
    }))
  } else {
    const variants = Array.from(new Set(runs.map((r) => r.variant)))
    seriesList = variants.map((v) => ({
      variant: v,
      runs: runs.filter((r) => r.variant === v).sort((a, b) => a.n - b.n),
    }))
  }

  const lineGen = line<TimeVsNRun>()
    .x((d) => x(d.n))
    .y((d) => y(nsPerElem(d)))

  seriesList.forEach(({ variant, k, runs: sRuns }) => {
    const col = variantColor(variant)
    const dash = k != null ? (K_DASH[k] ?? 'none') : 'none'
    const safeKey = `${variant}-${k ?? 'x'}`

    g.append('path')
      .datum(sRuns)
      .attr('fill', 'none')
      .attr('stroke', col)
      .attr('stroke-width', 2)
      .attr('stroke-dasharray', dash)
      .attr('opacity', 0.85)
      .attr('d', lineGen)

    g.selectAll(`.dot-${safeKey}`)
      .data(sRuns)
      .join('circle')
      .attr('class', `dot-${safeKey}`)
      .attr('cx', (d) => x(d.n))
      .attr('cy', (d) => y(nsPerElem(d)))
      .attr('r', 3.5)
      .attr('fill', col)
      .attr('opacity', 0.9)
  })

  if (annotateMaxGap) {
    const sorted   = runs.filter((r) => r.variant === 'sorted')
    const unsorted = runs.filter((r) => r.variant === 'unsorted')
    if (sorted.length > 0 && unsorted.length > 0) {
      let maxRatio = 0, maxN = 0
      ns.slice(1).forEach((n) => {
        const s = sorted.find((r) => r.n === n)
        const u = unsorted.find((r) => r.n === n)
        if (s && u) {
          const ratio = nsPerElem(u) / nsPerElem(s)
          if (ratio > maxRatio) { maxRatio = ratio; maxN = n }
        }
      })
      if (maxN > 0) {
        const sx = x(maxN)
        const sRun = sorted.find((r) => r.n === maxN)!
        const uRun = unsorted.find((r) => r.n === maxN)!
        const sy = y(nsPerElem(sRun))
        const uy = y(nsPerElem(uRun))
        const midY = (sy + uy) / 2

        g.append('line')
          .attr('x1', sx + 8).attr('x2', sx + 8)
          .attr('y1', sy).attr('y2', uy)
          .attr('stroke', colors.textMuted)
          .attr('stroke-width', 1)
          .attr('stroke-dasharray', '2,2')

        g.append('text')
          .attr('x', sx + 12)
          .attr('y', midY + 4)
          .attr('font-size', typography.annotationSize)
          .attr('fill', colors.textMuted)
          .text(`${maxRatio.toFixed(1)}×`)
      }
    }
  }

  const xAxisFn = axisBottom(x)
    .tickValues(ns)
    .tickSize(0)
    .tickFormat((v) => {
      const n = +v
      if (n >= 1e6) return `${n / 1e6}M`
      if (n >= 1e3) return `${n / 1e3}K`
      return `${n}`
    })

  appendXAxis(g, inner, colors, xAxisFn, true)
  appendXLabel(svg, 'N (elements)  ·  log scale', margin.left + inner.w / 2, H - 8, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(2)} ns`))
  appendYLabel(svg, yAxisLabel ?? `${stat} ns / element`, -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

  const legendItems = seriesList.map(({ variant, k }) => ({
    label: k != null
      ? `${variant} (K=${k})`
      : capitalize(variant),
    color: variantColor(variant),
    dash: k != null ? (K_DASH[k] ?? 'none') : 'none',
  }))

  appendLegendLines(svg, legendItems, {
    x: margin.left + inner.w + 8,
    y: margin.top,
    spacing: 18,
  }, { textSecondary: colors.textSecondary })
}

function renderModifyPctAxis(
  el: SVGSVGElement,
  runs: TimeVsNRun[],
  stat: 'median' | 'min' | 'p99',
  title?: string,
  yAxisLabel?: string,
  nFilter?: number,
) {
  const H = 320
  const W = el.clientWidth || 700
  const margin = { top: 32, right: 112, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  // Group runs by (variant, n) — each is one line.
  const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median
  const pcts = Array.from(new Set(runs.map((r) => r.modify_pct ?? 0))).sort((a, b) => a - b)

  type Series = { variant: string; n: number; runs: TimeVsNRun[] }
  const seen = new Map<string, { variant: string; n: number }>()
  runs.forEach((r) => {
    const key = `${r.variant}|${r.n}`
    if (!seen.has(key)) seen.set(key, { variant: r.variant, n: r.n })
  })
  const seriesList: Series[] = Array.from(seen.values())
    .sort((a, b) => a.variant.localeCompare(b.variant) || a.n - b.n)
    .map(({ variant, n }) => ({
      variant,
      n,
      runs: runs
        .filter((r) => r.variant === variant && r.n === n)
        .sort((a, b) => (a.modify_pct ?? 0) - (b.modify_pct ?? 0)),
    }))

  const x = scalePoint<number>().domain(pcts).range([0, inner.w]).padding(0.3)
  const allY = runs.map(nsPerElem)
  const y = scaleLinear().domain([0, max(allY)! * 1.15]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  const lineGen = line<TimeVsNRun>()
    .x((d) => x(d.modify_pct ?? 0)!)
    .y((d) => y(nsPerElem(d)))

  seriesList.forEach(({ variant, n, runs: sRuns }) => {
    const col = variantColor(variant)
    // Dash by N when multiple Ns are present; solid when nFilter pins to one N.
    const nValues = Array.from(new Set(seriesList.map((s) => s.n))).sort((a, b) => a - b)
    const nIdx = nValues.indexOf(n)
    const dash = nValues.length > 1 ? (K_DASH[nIdx + 1] ?? 'none') : 'none'
    const safeKey = `${variant}-${n}`

    g.append('path')
      .datum(sRuns)
      .attr('fill', 'none')
      .attr('stroke', col)
      .attr('stroke-width', 2)
      .attr('stroke-dasharray', dash)
      .attr('opacity', 0.85)
      .attr('d', lineGen)

    g.selectAll(`.dot-mp-${safeKey}`)
      .data(sRuns)
      .join('circle')
      .attr('class', `dot-mp-${safeKey}`)
      .attr('cx', (d) => x(d.modify_pct ?? 0)!)
      .attr('cy', (d) => y(nsPerElem(d)))
      .attr('r', 3.5)
      .attr('fill', col)
      .attr('opacity', 0.9)
  })

  appendXAxis(g, inner, colors, axisBottom(x).tickSize(0).tickFormat((v) => `${v}%`), true)
  const xLabel = nFilter != null
    ? `modify_pct  ·  N=${nFilter.toLocaleString()}`
    : 'modify_pct'
  appendXLabel(svg, xLabel, margin.left + inner.w / 2, H - 8, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(1)} ns`))
  appendYLabel(svg, yAxisLabel ?? `${stat} ns / op`, -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

  const legendItems = seriesList.map(({ variant, n }) => {
    const nValues = Array.from(new Set(seriesList.map((s) => s.n))).sort((a, b) => a - b)
    const nIdx = nValues.indexOf(n)
    return {
      label: nValues.length > 1
        ? `${capitalize(variant)} N=${n >= 1000 ? `${n / 1000}K` : n}`
        : capitalize(variant),
      color: variantColor(variant),
      dash: nValues.length > 1 ? (K_DASH[nIdx + 1] ?? 'none') : 'none',
    }
  })

  appendLegendLines(svg, legendItems, {
    x: margin.left + inner.w + 8,
    y: margin.top,
    spacing: 18,
  }, { textSecondary: colors.textSecondary })
}

function renderKAxis(
  el: SVGSVGElement,
  runs: TimeVsNRun[],
  stat: 'median' | 'min' | 'p99',
  title?: string,
  yAxisLabel?: string,
) {
  const H = 320
  const W = el.clientWidth || 700
  const margin = { top: 32, right: 112, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  const variants = Array.from(new Set(runs.map((r) => r.variant)))
  const ks = Array.from(new Set(runs.map((r) => r.k ?? 0))).sort((a, b) => a - b)
  const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median

  const x = scalePoint<number>().domain(ks).range([0, inner.w]).padding(0.3)
  const allY = runs.map(nsPerElem)
  const y = scaleLinear().domain([0, max(allY)! * 1.15]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  const lineGen = line<TimeVsNRun>()
    .x((d) => x(d.k ?? 0)!)
    .y((d) => y(nsPerElem(d)))

  variants.forEach((v) => {
    const vRuns = runs.filter((r) => r.variant === v).sort((a, b) => (a.k ?? 0) - (b.k ?? 0))
    const col = variantColor(v)

    g.append('path')
      .datum(vRuns)
      .attr('fill', 'none')
      .attr('stroke', col)
      .attr('stroke-width', 2)
      .attr('opacity', 0.85)
      .attr('d', lineGen)

    g.selectAll(`.dot-k-${v}`)
      .data(vRuns)
      .join('circle')
      .attr('class', `dot-k-${v}`)
      .attr('cx', (d) => x(d.k ?? 0)!)
      .attr('cy', (d) => y(nsPerElem(d)))
      .attr('r', 3.5)
      .attr('fill', col)
      .attr('opacity', 0.9)
  })

  appendXAxis(g, inner, colors, axisBottom(x).tickSize(0).tickFormat((v) => `${v}`), true)
  appendXLabel(svg, 'K (fields per element)', margin.left + inner.w / 2, H - 8, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(2)} ns`))
  appendYLabel(svg, yAxisLabel ?? `${stat} ns / element`, -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

  appendLegendLines(svg, variants.map((v) => ({
    label: capitalize(v),
    color: variantColor(v),
  })), { x: margin.left + inner.w + 8, y: margin.top, spacing: 20 }, { textSecondary: colors.textSecondary })
}
