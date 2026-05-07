'use client'

import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { colors, typography, variantColor } from './theme'

interface Run {
  variant: string
  n: number
  ns_per_op: { median: number; min: number; p99: number; iqr: number }
  ops_per_sec: number
  branch_misses_per_op: number
  instructions_per_cycle: number
}

interface ThroughputBarsProps {
  runs: Run[]
  stat?: 'median' | 'min' | 'p99'
  targetN?: number
  title?: string
}

export function ThroughputBars({ runs, stat = 'median', targetN, title }: ThroughputBarsProps) {
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    if (!ref.current) return

    // Pick N — default to the largest available
    const ns = Array.from(new Set(runs.map((r) => r.n))).sort((a, b) => a - b)
    const n = targetN ?? ns[ns.length - 1]
    const data = runs.filter((r) => r.n === n)

    if (data.length === 0) return

    const W = ref.current.clientWidth || 600
    const H = 260
    const margin = { top: 24, right: 16, bottom: 64, left: 64 }
    const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

    // Clear previous render
    d3.select(ref.current).selectAll('*').remove()

    const svg = d3
      .select(ref.current)
      .attr('width', W)
      .attr('height', H)
      .attr('viewBox', `0 0 ${W} ${H}`)
      .style('font-family', typography.fontMono)

    const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

    // Scales
    const x = d3
      .scaleBand()
      .domain(data.map((d) => d.variant))
      .range([0, inner.w])
      .padding(0.45)

    const vals = data.map((d) => d.ns_per_op[stat])
    const y = d3
      .scaleLinear()
      .domain([0, d3.max(vals)! * 1.25])
      .range([inner.h, 0])
      .nice()

    // Grid lines
    g.append('g')
      .attr('class', 'grid')
      .call(
        d3.axisLeft(y)
          .ticks(5)
          .tickSize(-inner.w)
          .tickFormat(() => '')
      )
      .call((sel) => sel.select('.domain').remove())
      .call((sel) =>
        sel.selectAll('line')
          .attr('stroke', colors.border)
          .attr('stroke-dasharray', '3,3')
      )

    // Bars
    g.selectAll('.bar')
      .data(data)
      .join('rect')
      .attr('class', 'bar')
      .attr('x', (d) => x(d.variant)!)
      .attr('y', (d) => y(d.ns_per_op[stat]))
      .attr('width', x.bandwidth())
      .attr('height', (d) => inner.h - y(d.ns_per_op[stat]))
      .attr('fill', (d) => variantColor(d.variant))
      .attr('rx', 4)
      .attr('opacity', 0.9)

    // Value labels above bars
    g.selectAll('.bar-label')
      .data(data)
      .join('text')
      .attr('class', 'bar-label')
      .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
      .attr('y', (d) => y(d.ns_per_op[stat]) - 8)
      .attr('text-anchor', 'middle')
      .attr('font-size', typography.labelSize)
      .attr('fill', colors.textPrimary)
      .text((d) => `${d.ns_per_op[stat].toFixed(2)} ns/op`)

    // Branch-miss annotation below bar label
    g.selectAll('.miss-label')
      .data(data)
      .join('text')
      .attr('class', 'miss-label')
      .attr('x', (d) => x(d.variant)! + x.bandwidth() / 2)
      .attr('y', (d) => y(d.ns_per_op[stat]) - 26)
      .attr('text-anchor', 'middle')
      .attr('font-size', 10)
      .attr('fill', colors.textMuted)
      .text((d) => `${(d.branch_misses_per_op * 100).toFixed(1)}% miss`)

    // X axis
    g.append('g')
      .attr('transform', `translate(0,${inner.h})`)
      .call(d3.axisBottom(x).tickSize(0))
      .call((sel) => sel.select('.domain').attr('stroke', colors.border))
      .call((sel) =>
        sel.selectAll('text')
          .attr('font-size', typography.axisSize)
          .attr('fill', colors.textSecondary)
          .attr('dy', '1.4em')
          .text((d) => (d as string).charAt(0).toUpperCase() + (d as string).slice(1))
      )

    // Y axis
    g.append('g')
      .call(d3.axisLeft(y).ticks(5).tickFormat((v) => `${v} ns`))
      .call((sel) => sel.select('.domain').remove())
      .call((sel) =>
        sel.selectAll('text')
          .attr('font-size', typography.axisSize)
          .attr('fill', colors.textMuted)
      )
      .call((sel) => sel.selectAll('line').remove())

    // Caption: stat label + N
    svg.append('text')
      .attr('x', margin.left)
      .attr('y', H - 10)
      .attr('font-size', 10)
      .attr('fill', colors.textMuted)
      .attr('font-family', typography.fontMono)
      .text(`${stat} ns/op · N = ${n.toLocaleString()}`)
  }, [runs, stat, targetN])

  return (
    <figure className="my-8">
      {title && (
        <figcaption
          className="text-xs mb-3 font-mono"
          style={{ color: colors.textMuted }}
        >
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
  )
}
