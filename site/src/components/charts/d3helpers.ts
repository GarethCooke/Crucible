import { axisLeft, axisBottom } from 'd3-axis'
import type { AxisScale } from 'd3-axis'
import type { NumberValue } from 'd3-scale'
import type { Selection } from 'd3-selection'
import { select } from 'd3-selection'
import { getColors, typography } from './theme'

type NumericScale = AxisScale<NumberValue>
type Colors = ReturnType<typeof getColors>
type Margin = { top: number; right: number; bottom: number; left: number }
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AxisFn = (selection: Selection<SVGGElement, any, any, any>) => void

// ─── Grid ─────────────────────────────────────────────────────────────────────

export function appendGrid<E extends Element>(
  g: Selection<E, unknown, null, undefined>,
  y: NumericScale,
  inner: { w: number; h: number },
  colors: { gridline: string },
  x?: NumericScale,
  counts?: { y?: number; x?: number },
) {
  const yCount = counts?.y ?? 5
  const xCount = counts?.x ?? 6

  g.append('g')
    .attr('class', 'grid')
    .call(
      axisLeft(y)
        .ticks(yCount)
        .tickSize(-inner.w)
        .tickFormat(() => ''),
    )
    .call((s) => s.select('.domain').remove())
    .call((s) => s.selectAll('line').attr('stroke', colors.gridline).attr('stroke-dasharray', '3,3'))

  if (x) {
    g.append('g')
      .attr('transform', `translate(0,${inner.h})`)
      .call(
        axisBottom(x)
          .ticks(xCount, '~s')
          .tickSize(-inner.h)
          .tickFormat(() => ''),
      )
      .call((s) => s.select('.domain').remove())
      .call((s) => s.selectAll('line').attr('stroke', colors.gridline).attr('stroke-dasharray', '3,3'))
  }
}

// ─── Legend helpers ────────────────────────────────────────────────────────────

function appendLegendText<E extends Element>(
  container: Selection<E, unknown, null, undefined>,
  x: number,
  y: number,
  label: string,
  fill: string,
): void {
  container.append('text')
    .attr('x', x)
    .attr('y', y)
    .attr('font-size', typography.annotationSize)
    .attr('fill', fill)
    .attr('font-family', typography.fontMono)
    .text(label)
}

export function appendLegendLines<E extends Element>(
  container: Selection<E, unknown, null, undefined>,
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
    appendLegendText(container, x + 22, itemY + 9, item.label, colors.textSecondary)
  })
}

export function appendLegendRects<E extends Element>(
  container: Selection<E, unknown, null, undefined>,
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
    appendLegendText(container, x + 14, itemY + 9, item.label, colors.textSecondary)
  })
}

// ─── SVG setup ────────────────────────────────────────────────────────────────

export function setupSVG(
  el: SVGSVGElement,
  W: number,
  H: number,
  margin: Margin,
  title: string,
): {
  svg: Selection<SVGSVGElement, unknown, null, undefined>
  g: Selection<SVGGElement, unknown, null, undefined>
  inner: { w: number; h: number }
  colors: Colors
} {
  const colors = getColors()
  const inner = { w: W - margin.left - margin.right, h: H - margin.top - margin.bottom }

  const svg = select(el)
    .attr('width', W)
    .attr('height', H)
    .attr('viewBox', `0 0 ${W} ${H}`)
    .style('font-family', typography.fontMono)

  svg.append('title').text(title)

  const g = svg.append('g').attr('transform', `translate(${margin.left},${margin.top})`)

  return { svg, g, inner, colors }
}

// ─── Axis helpers ─────────────────────────────────────────────────────────────

export function appendXAxis(
  g: Selection<SVGGElement, unknown, null, undefined>,
  inner: { h: number },
  colors: Colors,
  axis: AxisFn,
  useSecondary = false,
): void {
  g.append('g')
    .attr('transform', `translate(0,${inner.h})`)
    .call(axis)
    .call((s) => s.select('.domain').attr('stroke', colors.border))
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', useSecondary ? colors.textSecondary : colors.textMuted)
        .attr('dy', '1.4em'),
    )
}

export function appendYAxis(
  g: Selection<SVGGElement, unknown, null, undefined>,
  colors: Colors,
  axis: AxisFn,
): void {
  g.append('g')
    .call(axis)
    .call((s) => s.select('.domain').remove())
    .call((s) =>
      s.selectAll('text')
        .attr('font-size', typography.axisSize)
        .attr('fill', colors.textMuted),
    )
    .call((s) => s.selectAll('line').remove())
}

// ─── Axis label helpers ────────────────────────────────────────────────────────

export function appendXLabel(
  svg: Selection<SVGSVGElement, unknown, null, undefined>,
  text: string,
  x: number,
  y: number,
  colors: Colors,
): void {
  svg.append('text')
    .attr('x', x)
    .attr('y', y)
    .attr('text-anchor', 'middle')
    .attr('font-size', typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(text)
}

export function appendYLabel(
  svg: Selection<SVGSVGElement, unknown, null, undefined>,
  text: string,
  x: number,
  y: number,
  colors: Colors,
  fontSize?: number,
): void {
  svg.append('text')
    .attr('transform', 'rotate(-90)')
    .attr('x', x)
    .attr('y', y)
    .attr('text-anchor', 'middle')
    .attr('font-size', fontSize ?? typography.annotationSize)
    .attr('fill', colors.textMuted)
    .attr('font-family', typography.fontMono)
    .text(text)
}

// ─── Legend position ──────────────────────────────────────────────────────────

export function legendPosition(
  isNarrow: boolean,
  margin: { left: number; top: number },
  inner: { w: number; h: number },
  xOffset = 8,
): { x: number; y: number } {
  return {
    x: isNarrow ? margin.left : margin.left + inner.w + xOffset,
    y: isNarrow ? margin.top + inner.h + 16 : margin.top,
  }
}
