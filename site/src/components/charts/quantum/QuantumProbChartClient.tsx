'use client'

import { scaleLinear, scalePoint } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line, area } from 'd3-shape'
import { typography } from '../theme'
import {
  appendGrid, appendLegendLines,
  setupSVG, appendXAxis, appendYAxis, appendXLabel, appendYLabel,
} from '../d3helpers'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from '../ChartZoom'
import { ChartShell } from '../ChartShell'

export interface ProbSeries {
  label: string
  color: string
  dash?: string
  points: {
    xLabel: string
    xIndex: number
    y: number | null
    yMin?: number | null
    yMax?: number | null
  }[]
}

interface Props {
  title?: string
  series: ProbSeries[]
  xLabels: string[]
  xAxisLabel?: string
  yAxisLabel?: string
  /** Horizontal reference line (e.g. random floor) */
  hLines?: { y: number; label: string; color?: string }[]
  /** Annotate a specific point with a text label */
  annotations?: { xLabel: string; y: number; text: string }[]
  /** Show "hardware capture pending" overlay */
  pending?: boolean
}

export function QuantumProbChartClient({
  title,
  series,
  xLabels,
  xAxisLabel = 'N (search-space size)',
  yAxisLabel = 'P(success)',
  hLines,
  annotations,
  pending = false,
}: Props) {
  const ref = useChartEffect(
    (el) => {
      const H = 320
      const W = el.clientWidth || 700
      const margin = { top: 32, right: 140, bottom: 56, left: 72 }
      const { svg, g, inner, colors } = setupSVG(
        el, W, H, margin, title ?? 'Quantum probability chart',
      )

      const x = scalePoint<string>()
        .domain(xLabels)
        .range([0, inner.w])
        .padding(0.4)

      const y = scaleLinear().domain([0, 1]).range([inner.h, 0])

      appendGrid(g, y, inner, { gridline: colors.border })

      // Horizontal reference lines (e.g. random floor)
      if (hLines) {
        hLines.forEach((hl) => {
          const yPos = y(hl.y)
          const col = hl.color ?? colors.textMuted
          g.append('line')
            .attr('x1', 0).attr('x2', inner.w)
            .attr('y1', yPos).attr('y2', yPos)
            .attr('stroke', col)
            .attr('stroke-width', 1)
            .attr('stroke-dasharray', '4,3')
            .attr('opacity', 0.55)
          g.append('text')
            .attr('x', inner.w + 4)
            .attr('y', yPos + 4)
            .attr('font-size', typography.annotationSize)
            .attr('fill', col)
            .attr('opacity', 0.7)
            .attr('font-family', typography.fontMono)
            .text(hl.label)
        })
      }

      // Series: error bands first (behind lines), then lines, then dots
      series.forEach((s) => {
        const validPts = s.points.filter(
          (p) => p.y !== null && p.yMin != null && p.yMax != null,
        )
        if (validPts.length > 0) {
          const areaGen = area<typeof validPts[0]>()
            .x((d) => x(d.xLabel) ?? 0)
            .y0((d) => y(d.yMin!))
            .y1((d) => y(d.yMax!))
          g.append('path')
            .datum(validPts)
            .attr('fill', s.color)
            .attr('opacity', 0.12)
            .attr('d', areaGen)
        }
      })

      series.forEach((s) => {
        const validPts = s.points.filter((p) => p.y !== null)
        if (validPts.length === 0) return
        const lineGen = line<typeof validPts[0]>()
          .x((d) => x(d.xLabel) ?? 0)
          .y((d) => y(d.y!))
        g.append('path')
          .datum(validPts)
          .attr('fill', 'none')
          .attr('stroke', s.color)
          .attr('stroke-width', 2)
          .attr('stroke-dasharray', s.dash ?? 'none')
          .attr('opacity', 0.9)
          .attr('d', lineGen)

        g.selectAll(`.dot-qp-${s.label.replace(/\s+/g, '-')}`)
          .data(validPts)
          .join('circle')
          .attr('class', `dot-qp-${s.label.replace(/\s+/g, '-')}`)
          .attr('cx', (d) => x(d.xLabel) ?? 0)
          .attr('cy', (d) => y(d.y!))
          .attr('r', 4)
          .attr('fill', s.color)
          .attr('opacity', 0.9)
      })

      // Annotations
      if (annotations) {
        annotations.forEach((ann) => {
          const xPos = x(ann.xLabel)
          if (xPos == null) return
          const yPos = y(ann.y)
          g.append('text')
            .attr('x', xPos + 6)
            .attr('y', yPos - 6)
            .attr('font-size', typography.annotationSize)
            .attr('fill', colors.textMuted)
            .attr('font-family', typography.fontMono)
            .text(ann.text)
        })
      }

      // Pending overlay
      if (pending) {
        g.append('rect')
          .attr('x', 0).attr('y', 0)
          .attr('width', inner.w).attr('height', inner.h)
          .attr('fill', colors.bg)
          .attr('opacity', 0.65)
        g.append('text')
          .attr('x', inner.w / 2).attr('y', inner.h / 2 - 8)
          .attr('text-anchor', 'middle')
          .attr('font-size', 12)
          .attr('fill', colors.textMuted)
          .attr('font-family', typography.fontMono)
          .text('hardware capture pending')
        g.append('text')
          .attr('x', inner.w / 2).attr('y', inner.h / 2 + 10)
          .attr('text-anchor', 'middle')
          .attr('font-size', typography.annotationSize)
          .attr('fill', colors.textMuted)
          .attr('font-family', typography.fontMono)
          .text('ideal-simulator reference shown below')
      }

      // Axes
      const xAxisFn = axisBottom(x).tickSize(0)
      appendXAxis(g, inner, colors, xAxisFn, true)
      appendXLabel(svg, xAxisLabel, margin.left + inner.w / 2, H - 8, colors)

      appendYAxis(
        g, colors,
        axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(1)}`),
      )
      appendYLabel(svg, yAxisLabel, -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

      // Legend
      const legendItems = series.map((s) => ({
        label: s.label,
        color: s.color,
        dash: s.dash,
      }))
      appendLegendLines(
        svg,
        legendItems,
        { x: margin.left + inner.w + 8, y: margin.top, spacing: 18 },
        { textSecondary: colors.textSecondary },
      )
    },
    [series, xLabels, hLines, annotations, pending, title],
  )

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Quantum probability chart'} />
    </ChartZoom>
  )
}

// ─── Iteration-sweep chart (teaching: P(marked) vs Grover iteration count) ────

interface IterSweepProps {
  title?: string
  curve: { iters: number; p_marked: number }[]
  optimalIters: number
}

export function QuantumIterSweepClient({ title, curve, optimalIters }: IterSweepProps) {
  const ref = useChartEffect((el) => {
    const H = 300
    const W = el.clientWidth || 700
    const margin = { top: 32, right: 80, bottom: 56, left: 72 }
    const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? 'Grover iteration sweep')

    const xs = curve.map((p) => p.iters)
    const x = scaleLinear().domain([0, xs[xs.length - 1]]).range([0, inner.w])
    const y = scaleLinear().domain([0, 1.05]).range([inner.h, 0])

    appendGrid(g, y, inner, { gridline: colors.border })

    const optX = x(optimalIters)
    g.append('line')
      .attr('x1', optX).attr('x2', optX).attr('y1', 0).attr('y2', inner.h)
      .attr('stroke', colors.textMuted).attr('stroke-width', 1).attr('stroke-dasharray', '4,2').attr('opacity', 0.55)
    g.append('text').attr('x', optX + 4).attr('y', 12)
      .attr('font-size', typography.annotationSize).attr('fill', colors.textMuted).attr('font-family', typography.fontMono)
      .text('optimal')

    const col = 'oklch(72% 0.18 222)'
    const lineGen = line<{ iters: number; p_marked: number }>()
      .x((d) => x(d.iters)).y((d) => y(d.p_marked))

    g.append('path').datum(curve)
      .attr('fill', 'none').attr('stroke', col).attr('stroke-width', 2).attr('opacity', 0.9).attr('d', lineGen)

    g.selectAll('.dot-sweep').data(curve).join('circle')
      .attr('class', 'dot-sweep')
      .attr('cx', (d) => x(d.iters)).attr('cy', (d) => y(d.p_marked)).attr('r', 4).attr('fill', col).attr('opacity', 0.95)

    // Value labels above/below each point
    curve.forEach((d) => {
      g.append('text')
        .attr('x', x(d.iters)).attr('y', y(d.p_marked) - 8)
        .attr('text-anchor', 'middle')
        .attr('font-size', typography.annotationSize).attr('fill', colors.textSecondary).attr('font-family', typography.fontMono)
        .text(d.p_marked.toFixed(2))
    })

    appendXAxis(g, inner, colors, axisBottom(x).tickValues(xs).tickSize(0).tickFormat((v) => `${+v}`), true)
    appendXLabel(svg, 'Grover iterations', margin.left + inner.w / 2, H - 8, colors)
    appendYAxis(g, colors, axisLeft(y).tickValues([0, 0.25, 0.5, 0.75, 1.0]).tickFormat((v) => `${(+v).toFixed(2)}`))
    appendYLabel(svg, 'P(marked state)  ·  N=16, ideal simulator', -(margin.top + inner.h / 2), 14, colors, typography.captionSize)
  }, [curve, optimalIters])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? 'Grover iteration sweep'} />
    </ChartZoom>
  )
}

// ─── Asymptotic crossover — theory, not measurement ───────────────────────────

export function AsymptoticCrossoverClient() {
  const ref = useChartEffect((el) => {
    const H = 300
    const W = el.clientWidth || 700
    const margin = { top: 44, right: 80, bottom: 56, left: 72 }
    const { svg, g, inner, colors } = setupSVG(el, W, H, margin, 'Asymptotic crossover — theory, not measurement')

    const Nmax = 1e6
    const x = scaleLinear().domain([0, Nmax]).range([0, inner.w])
    const y = scaleLinear().domain([0, Nmax * 1.05]).range([inner.h, 0])

    appendGrid(g, y, inner, { gridline: colors.border })

    const classicalColor = 'oklch(52% 0.17 30)'
    const groverColor    = 'oklch(72% 0.18 222)'
    const nVals = Array.from({ length: 300 }, (_, i) => (i + 1) * (Nmax / 300))

    const classicalLine = line<number>().x((n) => x(n)).y((n) => y(n))
    const groverLine    = line<number>().x((n) => x(n)).y((n) => y(Math.sqrt(n)))

    g.append('path').datum(nVals).attr('fill', 'none').attr('stroke', classicalColor).attr('stroke-width', 2).attr('opacity', 0.85).attr('d', classicalLine)
    g.append('path').datum(nVals).attr('fill', 'none').attr('stroke', groverColor).attr('stroke-width', 2).attr('opacity', 0.85).attr('d', groverLine)

    // "theory — not a measurement" label inside the chart area
    g.append('text')
      .attr('x', inner.w / 2).attr('y', inner.h - 12)
      .attr('text-anchor', 'middle')
      .attr('font-size', typography.annotationSize).attr('fill', colors.textMuted).attr('font-family', typography.fontMono)
      .text('theory — not a measurement')

    g.append('text').attr('x', inner.w * 0.55).attr('y', 16)
      .attr('font-size', typography.annotationSize).attr('fill', colors.textMuted).attr('font-family', typography.fontMono)
      .text('crossover requires fault-tolerant QEC')
    g.append('text').attr('x', inner.w * 0.55).attr('y', 28)
      .attr('font-size', typography.annotationSize).attr('fill', colors.textMuted).attr('font-family', typography.fontMono)
      .text('not available on NISQ hardware')

    const fmt = (v: number) => {
      if (v >= 1e6) return `${v / 1e6}M`
      if (v >= 1e3) return `${v / 1e3}K`
      return `${v}`
    }
    appendXAxis(g, inner, colors, axisBottom(x).ticks(6).tickSize(0).tickFormat((v) => fmt(+v)), true)
    appendXLabel(svg, 'N (search-space size)', margin.left + inner.w / 2, H - 8, colors)
    appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => fmt(+v)))
    appendYLabel(svg, 'operations (relative)', -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

    appendLegendLines(svg, [
      { label: 'Classical O(N)', color: classicalColor },
      { label: 'Grover O(√N)',   color: groverColor },
    ], { x: margin.left + 12, y: margin.top + 8, spacing: 18 }, { textSecondary: colors.textSecondary })
  }, [])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title="Asymptotic crossover — theory, not measurement" ariaLabel="Asymptotic crossover theory chart" />
    </ChartZoom>
  )
}

// ─── Circuit depth / mechanism chart ─────────────────────────────────────────

interface MechanismProps {
  groverDepths: { N: number; depth: number }[]
  bvDepths: { N: number; depth: number }[]
  title?: string
}

export function QuantumMechanismClient({ groverDepths, bvDepths, title }: MechanismProps) {
  const ref = useChartEffect((el) => {
    const H = 300
    const W = el.clientWidth || 700
    const margin = { top: 32, right: 140, bottom: 56, left: 72 }
    const { svg, g, inner, colors } = setupSVG(el, W, H, margin, title ?? 'Transpiled circuit depth vs N')

    const allN = Array.from(new Set([...groverDepths, ...bvDepths].map((d) => d.N))).sort((a, b) => a - b)
    const x = scalePoint<string>().domain(allN.map((n) => `N=${n}`)).range([0, inner.w]).padding(0.4)
    const maxDepth = Math.max(...groverDepths.map((d) => d.depth), ...bvDepths.map((d) => d.depth))
    const y = scaleLinear().domain([0, maxDepth * 1.15]).range([inner.h, 0]).nice()

    appendGrid(g, y, inner, { gridline: colors.border })

    const groverColor = 'oklch(52% 0.17 30)'
    const bvColor     = 'oklch(72% 0.18 222)'

    const depthLine = line<{ N: number; depth: number }>()
      .x((d) => x(`N=${d.N}`) ?? 0).y((d) => y(d.depth))

    g.append('path').datum(groverDepths).attr('fill', 'none').attr('stroke', groverColor).attr('stroke-width', 2).attr('opacity', 0.85).attr('d', depthLine)
    g.append('path').datum(bvDepths).attr('fill', 'none').attr('stroke', bvColor).attr('stroke-width', 2).attr('opacity', 0.85).attr('d', depthLine)

    groverDepths.forEach((d) => {
      g.append('circle').attr('cx', x(`N=${d.N}`) ?? 0).attr('cy', y(d.depth)).attr('r', 4).attr('fill', groverColor).attr('opacity', 0.95)
      g.append('text').attr('x', (x(`N=${d.N}`) ?? 0) + 6).attr('y', y(d.depth) - 6)
        .attr('font-size', typography.annotationSize).attr('fill', groverColor).attr('font-family', typography.fontMono).text(`${d.depth}`)
    })
    bvDepths.forEach((d) => {
      g.append('circle').attr('cx', x(`N=${d.N}`) ?? 0).attr('cy', y(d.depth)).attr('r', 4).attr('fill', bvColor).attr('opacity', 0.95)
      g.append('text').attr('x', (x(`N=${d.N}`) ?? 0) + 6).attr('y', y(d.depth) - 6)
        .attr('font-size', typography.annotationSize).attr('fill', bvColor).attr('font-family', typography.fontMono).text(`${d.depth}`)
    })

    appendXAxis(g, inner, colors, axisBottom(x).tickSize(0), true)
    appendXLabel(svg, 'N (search-space size)', margin.left + inner.w / 2, H - 8, colors)
    appendYAxis(g, colors, axisLeft(y).ticks(5).tickFormat((v) => `${+v}`))
    appendYLabel(svg, 'transpiled circuit depth', -(margin.top + inner.h / 2), 14, colors, typography.captionSize)

    appendLegendLines(svg, [
      { label: 'Grover (deep)',  color: groverColor },
      { label: 'BV (shallow)',   color: bvColor },
    ], { x: margin.left + inner.w + 8, y: margin.top, spacing: 20 }, { textSecondary: colors.textSecondary })
  }, [groverDepths, bvDepths])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title ?? 'Transpiled circuit depth vs N'} ariaLabel="Circuit depth vs N" />
    </ChartZoom>
  )
}
