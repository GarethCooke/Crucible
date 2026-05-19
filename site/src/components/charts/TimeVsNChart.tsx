'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { colors, typography, variantColor } from './theme'
import { ChartZoom } from './ChartZoom'

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
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    if (!ref.current || runs.length === 0) return
    d3.select(ref.current).selectAll('*').remove()
    render(ref.current, runs, stat)
  }, [runs, stat])

  return (
    <ChartZoom>
      <figure className="my-8">
        {title && (
          <figcaption className="text-xs mb-3 font-mono" style={{ color: colors.textMuted }}>
            {title}
          </figcaption>
        )}
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

function render(el: SVGSVGElement, runs: TimeVsNRun[], stat: 'median' | 'min' | 'p99') {
  const W = el.clientWidth || 700
  const H = 320
  const margin = { top: 32, right: 112, bottom: 56, left: 72 }
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = d3
    .select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  const variants = Array.from(new Set(runs.map((r) => r.variant)))
  const ns = Array.from(new Set(runs.map((r) => r.n))).sort((a, b) => a - b)

  const nsPerElem = (r: TimeVsNRun) => r.ns_per_op[stat] ?? r.ns_per_op.median

  const x = d3.scaleLog().domain([ns[0], ns[ns.length - 1]]).range([0, inner.w])
  const allY = runs.map(nsPerElem)
  const y = d3.scaleLinear().domain([0, d3.max(allY)! * 1.15]).range([inner.h, 0]).nice()

  // Grid lines
  g.append('g')
    .call(d3.axisLeft(y).ticks(5).tickSize(-inner.w).tickFormat(() => ''))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) => sel.selectAll('line').attr('stroke', colors.border).attr('stroke-dasharray', '3,3'))

  // Lines + markers per variant
  const line = d3.line<TimeVsNRun>()
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
      .attr('d', line)

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
  // Find the N where the ratio is maximal (excluding N=1024 where cache effects dominate)
  const sorted    = runs.filter((r) => r.variant === 'sorted')
  const unsorted  = runs.filter((r) => r.variant === 'unsorted')
  if (sorted.length > 0 && unsorted.length > 0) {
    let maxRatio = 0, maxN = 0
    ns.slice(1).forEach((n) => {  // skip smallest N
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
        .attr('font-size', 10)
        .attr('fill', colors.textMuted)
        .text(`${maxRatio.toFixed(1)}×`)
    }
  }

  // X axis — log scale, N values labelled with SI suffixes
  const xAxis = d3.axisBottom(x)
    .tickValues(ns)
    .tickSize(0)
    .tickFormat((v) => {
      const n = +v
      if (n >= 1e6) return `${n / 1e6}M`
      if (n >= 1e3) return `${n / 1e3}K`
      return `${n}`
    })

  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(xAxis)
    .call((sel) => sel.select('.domain').attr('stroke', colors.border))
    .call((sel) =>
      sel.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textSecondary)
        .attr('dy', '1.4em')
    )

  svg.append('text')
    .attr('x', margin.left + inner.w / 2)
    .attr('y', H - 8)
    .attr('text-anchor', 'middle')
    .attr('font-size', 10)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text('N (elements)  ·  log scale')

  // Y axis
  g.append('g')
    .call(d3.axisLeft(y).ticks(5).tickFormat((v) => `${(+v).toFixed(2)} ns`))
    .call((sel) => sel.select('.domain').remove())
    .call((sel) => sel.selectAll('text').attr('font-size', typography.axisSize).attr('fill', colors.textMuted))
    .call((sel) => sel.selectAll('line').remove())

  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', -(margin.top + inner.h / 2))
    .attr('y', 14)
    .attr('text-anchor', 'middle')
    .attr('font-size', 9)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(`${stat} ns / element`)

  // Legend (right side)
  const legendX = margin.left + inner.w + 8
  variants.forEach((v, i) => {
    const col = variantColor(v)
    svg.append('line')
      .attr('x1', legendX).attr('x2', legendX + 16)
      .attr('y1', margin.top + i * 20 + 5)
      .attr('y2', margin.top + i * 20 + 5)
      .attr('stroke', col)
      .attr('stroke-width', 2)
    svg.append('circle')
      .attr('cx', legendX + 8).attr('cy', margin.top + i * 20 + 5)
      .attr('r', 3).attr('fill', col)
    svg.append('text')
      .attr('x', legendX + 20)
      .attr('y', margin.top + i * 20 + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(v.charAt(0).toUpperCase() + v.slice(1))
  })
}
