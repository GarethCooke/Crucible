import * as d3 from 'd3'
import { typography } from './theme'

type NumericScale = d3.AxisScale<d3.NumberValue>

export function appendGrid<E extends Element>(
  g: d3.Selection<E, unknown, null, undefined>,
  y: NumericScale,
  inner: { w: number; h: number },
  colors: { gridline: string },
  x?: NumericScale,
) {
  g.append('g')
    .attr('class', 'grid')
    .call(
      d3.axisLeft(y)
        .ticks(5)
        .tickSize(-inner.w)
        .tickFormat(() => ''),
    )
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.gridline).attr('stroke-dasharray', '3,3'))

  if (x) {
    g.append('g')
      .attr('transform', `translate(0,${inner.h})`)
      .call(
        d3.axisBottom(x)
          .ticks(6, '~s')
          .tickSize(-inner.h)
          .tickFormat(() => ''),
      )
      .call((s) => s.select('.domain').remove())
      .call((s) => s.selectAll('line').attr('stroke', colors.gridline).attr('stroke-dasharray', '3,3'))
  }
}

export function appendLegendLines<E extends Element>(
  container: d3.Selection<E, unknown, null, undefined>,
  items: { label: string; color: string; dash?: string }[],
  position: { x: number; y: number; spacing?: number },
  colors: { textSecondary: string },
) {
  const { x, y, spacing = 18 } = position
  items.forEach((item, i) => {
    const itemY = y + i * spacing
    container.append('line')
      .attr('x1', x).attr('x2', x + 18)
      .attr('y1', itemY + 5).attr('y2', itemY + 5)
      .attr('stroke', item.color)
      .attr('stroke-width', 2)
      .attr('stroke-dasharray', item.dash ?? 'none')
    container.append('text')
      .attr('x', x + 22)
      .attr('y', itemY + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(item.label)
  })
}

export function appendLegendRects<E extends Element>(
  container: d3.Selection<E, unknown, null, undefined>,
  items: { label: string; color: string }[],
  position: { x: number; y: number; spacing?: number },
  colors: { textSecondary: string },
) {
  const { x, y, spacing = 18 } = position
  items.forEach((item, i) => {
    const itemY = y + i * spacing
    container.append('rect')
      .attr('x', x).attr('y', itemY)
      .attr('width', 10).attr('height', 10)
      .attr('fill', item.color)
      .attr('rx', 2)
    container.append('text')
      .attr('x', x + 14)
      .attr('y', itemY + 9)
      .attr('font-size', 10)
      .attr('fill', colors.textSecondary)
      .attr('font-family', typography.fontMono)
      .text(item.label)
  })
}
