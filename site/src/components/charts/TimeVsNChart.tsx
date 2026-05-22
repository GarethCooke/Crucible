'use client'

import { scaleLog, scaleLinear } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { max } from 'd3-array'
import { line } from 'd3-shape'
import { typography, variantColor } from './theme'
import {
  appendGrid, appendLegendLines,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel,
} from './d3helpers'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'

export interface TimeVsNRun {
  variant: string
  n: number
  ns_per_op: { median: number; min: number; p99: number; iqr: number }
}

interface Props {
  runs: TimeVsNRun[]
  stat?: 'median' | 'min' | 'p99'
  title?: string
}

export function TimeVsNChart({ runs, stat = 'median', title }: Props) {
  const ref = useChartEffect((el) => {
    if (runs.length === 0) return
    render(el, runs, stat, title)
  }, [runs, stat, title])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Time vs N benchmark'} />
    </ChartZoom>
  )
}

const DEFAULT_TITLE = 'Time vs N benchmark chart'

function render(el: SVGSVGElement, runs: TimeVsNRun[], stat: 'median' | 'min' | 'p99', title?: string) {
  const H = 320
  const W = el.clientWidth || 700
  const margin = { top: 32, right: 112, bottom: 56, left: 72 }
  const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  const variants = Array.from(new Set(runs.map((r) => r.variant)))
  const ns = Array.from(new Set(runs.map((r) => r.n))).sort((a, b) => a - b)

  const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median

  const x = scaleLog().domain([ns[0], ns[ns.length - 1]]).range([0, inner.w])
  const allY = runs.map(nsPerElem)
  const y = scaleLinear().domain([0, max(allY)! * 1.15]).range([inner.h, 0]).nice()

  appendGrid(g, y, inner, { gridline: colors.border })

  const lineGen = line<TimeVsNRun>()
    .x((d) => x(d.n))
    .y((d) => y(nsPerElem(d)))

  variants.forEach((v) => {
    const vRuns = runs.filter((r) => r.variant === v).sort((a, b) => a.n - b.n)
    const col = variantColor(v)

    g.append('path')
      .datum(vRuns)
      .attr('fill', 'none')
      .attr('stroke', col)
      .attr('stroke-width', 2)
      .attr('opacity', 0.85)
      .attr('d', lineGen)

    g.selectAll(`.dot-${v}`)
      .data(vRuns)
      .join('circle')
      .attr('class', `dot-${v}`)
      .attr('cx', (d) => x(d.n))
      .attr('cy', (d) => y(nsPerElem(d)))
      .attr('r', 3.5)
      .attr('fill', col)
      .attr('opacity', 0.9)
  })

  // Annotate the largest gap between sorted and unsorted
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

  const xAxis = axisBottom(x)
    .tickValues(ns)
    .tickSize(0)
    .tickFormat((v) => {
      const n = +v
      if (n >= 1e6) return `${n / 1e6}M`
      if (n >= 1e3) return `${n / 1e3}K`
      return `${n}`
    })

  appendXAxis(g, inner, colors, xAxis, true)
  appendXLabel(svg, 'N (elements)  ·  log scale', margin.left + inner.w / 2, H - 8, colors)

  appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(2)} ns`))
  appendYLabel(svg, `${stat} ns / element`, -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

  appendLegendLines(svg, variants.map((v) => ({
    label: v.charAt(0).toUpperCase() + v.slice(1),
    color: variantColor(v),
  })), { x: margin.left + inner.w + 8, y: margin.top, spacing: 20 }, { textSecondary: colors.textSecondary })
}
