'use client'

import { useEffect, useState } from 'react'
import { median } from 'd3-array'
import { axisBottom, axisLeft } from 'd3-axis'
import { scaleBand, scaleThreshold } from 'd3-scale'
import { select } from 'd3-selection'
import type { Selection } from 'd3-selection'
import { tokens } from '@/lib/design-tokens'
import { matrixPalette, typography } from './theme'
import {
  setupSVG, appendXAxis, appendYAxis, appendLegendRects, appendLegendLines,
} from './d3helpers'
import { useChartEffect } from '@/hooks/useChartEffect'
import { ChartZoom } from './ChartZoom'
import { ChartShell } from './ChartShell'
import type {
  LatencyMatrixBlock, LatencyMatrixCore, LatencyMatrixStats,
} from '@/lib/perf-types'

const DEFAULT_TITLE = 'Core-to-core latency matrix'

// ─── Layout constants ─────────────────────────────────────────────────────────
// All y offsets are measured downwards from the bottom edge of the grid, so the
// bottom margin can be derived from the same numbers the renderer draws with.

const MAX_SIDE   = 460   // cap the square grid on wide containers
const MIN_SIDE   = 140
const LEGEND_W   = 186   // right-hand legend column (wide layout only)
const LEGEND_GAP = 16

const AXIS_H        = 18                    // x tick labels sit under the grid
const BRACKET_Y     = AXIS_H + 8            // CCX bracket rule
const BRACKET_LBL_Y = BRACKET_Y + 13        // CCX bracket label baseline
const READOUT_Y     = BRACKET_LBL_Y + 18    // hover readout, line 1
const READOUT_Y2    = READOUT_Y + 13        // hover readout, line 2
const LEGEND_ROW_H  = 18
const NOTE_LINE_H   = 13
const NARROW_LEGEND_Y = READOUT_Y2 + 14     // legend block top (narrow only)

// Wide keeps the legend and notes in the right-hand column, so only the axis,
// brackets and readout drive its bottom margin. Narrow stacks everything, so
// its bottom is derived in render() from the actual legend row and note
// counts — the cluster analysis runs before layout for exactly this reason.
const BOTTOM_WIDE   = READOUT_Y2 + 14

// Below this cell size a 3-digit label at caption size stops having room to
// breathe, so labels are dropped and colour + hover carry the cell.
const MIN_CELL_PX_FOR_LABEL = 30

const SEAM_CHANNEL_PX = 6   // dark gutter cut between the CCX quadrants
const SEAM_OVERHANG   = 7   // how far the seam runs past the grid edge

// ─── Props ────────────────────────────────────────────────────────────────────

interface Props {
  matrix: LatencyMatrixBlock
  title?: string
}

export function LatencyMatrixChart({ matrix, title }: Props) {
  // Unlike the other charts in the stack this one derives its *height* from its
  // width — the grid is square — so a stale width measurement letterboxes the
  // whole SVG inside its viewBox instead of merely scaling it. Re-measure on
  // container resize and feed the width back through the house render effect.
  const [width, setWidth] = useState(0)

  const ref = useChartEffect((el) => {
    render(el, matrix, title)
  }, [matrix, title, width])

  useEffect(() => {
    const el = ref.current
    if (!el || typeof ResizeObserver === 'undefined') return
    // Observe the container, not the SVG: the SVG's own height changes as a
    // result of re-rendering, and watching it would feed back on itself.
    const target = el.parentElement ?? el
    const ro = new ResizeObserver(() => setWidth(el.clientWidth))
    ro.observe(target)
    return () => ro.disconnect()
  }, [ref])

  return (
    <ChartZoom>
      <ChartShell ref={ref} title={title} ariaLabel={title ?? DEFAULT_TITLE} />
    </ChartZoom>
  )
}

// ─── Cell model ───────────────────────────────────────────────────────────────

interface Cell {
  a: number
  b: number
  sameCcx: boolean
  stats: LatencyMatrixStats
}

/** One rendered square. `self` and `missing` are nulls — never coloured on the RTT scale. */
interface Tile {
  row: number
  col: number
  kind: 'pair' | 'self' | 'missing'
  cell?: Cell
}

interface CcxGroup {
  ccx: number
  l3: string
  startIdx: number
  endIdx: number
}

const cellKey = (a: number, b: number) => `${a}:${b}`

/**
 * Mirrors the stored unordered pairs into both orientations. The same Cell
 * object is stored under both keys, so cell[a][b] and cell[b][a] are identical
 * by construction rather than by a second lookup.
 */
function buildLookup(pairs: LatencyMatrixBlock['pairs'], cpus: Set<number>): Map<string, Cell> {
  const lookup = new Map<string, Cell>()
  for (const p of pairs) {
    if (p.a === p.b) continue                      // a self-pair is not an interconnect hop
    if (!cpus.has(p.a) || !cpus.has(p.b)) continue // pair references a core outside the grid
    const cell: Cell = { a: p.a, b: p.b, sameCcx: p.same_ccx, stats: p.rtt_ns }
    lookup.set(cellKey(p.a, p.b), cell)
    lookup.set(cellKey(p.b, p.a), cell)
  }
  return lookup
}

/**
 * Splits the observed medians at their widest empty interval and returns that
 * interval plus its midpoint.
 *
 * This is what keeps the colour scale honest. A min→max ramp would spend its
 * whole dynamic range inside the two clusters, where the variation is timer
 * quantisation and slice wobble, and would manufacture gradients that read as
 * topology. Anchoring the single threshold in the empty interval instead puts
 * every cell of a cluster on exactly one colour: two flat blocks, one seam.
 *
 * Returns null when there is no interval to split on (fewer than two distinct
 * values), in which case the caller falls back to a single flat colour.
 */
function splitAtWidestGap(values: number[]): { lowMax: number; highMin: number; mid: number } | null {
  if (values.length < 2) return null
  const sorted = [...values].sort((p, q) => p - q)
  let bestGap = 0
  let bestIdx = -1
  for (let i = 1; i < sorted.length; i++) {
    const gap = sorted[i] - sorted[i - 1]
    if (gap > bestGap) {
      bestGap = gap
      bestIdx = i
    }
  }
  if (bestIdx < 0 || bestGap <= 0) return null
  const lowMax = sorted[bestIdx - 1]
  const highMin = sorted[bestIdx]
  return { lowMax, highMin, mid: (lowMax + highMin) / 2 }
}

/** Consecutive runs of equal ccx in the already-grouped core order. */
function ccxGroups(cores: LatencyMatrixCore[]): CcxGroup[] {
  const groups: CcxGroup[] = []
  cores.forEach((c, i) => {
    const last = groups[groups.length - 1]
    if (last && last.ccx === c.ccx) last.endIdx = i
    else groups.push({ ccx: c.ccx, l3: c.l3_domain, startIdx: i, endIdx: i })
  })
  return groups
}

const ns1 = (v: number) => v.toFixed(1)

// ─── Renderer ─────────────────────────────────────────────────────────────────

function render(el: SVGSVGElement, matrix: LatencyMatrixBlock, title?: string) {
  // Grouping comes from the data: sort by ccx then cpu so each L3 domain is a
  // contiguous block whatever order the JSON happens to list cores in.
  const cores = [...matrix.cores].sort((p, q) => p.ccx - q.ccx || p.cpu - q.cpu)
  if (cores.length === 0) return

  const cpus = cores.map((c) => c.cpu)
  const cpuSet = new Set(cpus)
  const ccxOf = new Map(cores.map((c) => [c.cpu, c.ccx]))
  const groups = ccxGroups(cores)
  const lookup = buildLookup(matrix.pairs, cpuSet)

  const W = el.clientWidth || 640
  const isNarrow = W < tokens.chart.mobileBreakpoint

  // ── Cluster analysis, before layout: the legend rows and honesty notes it
  // yields drive the narrow layout's bottom margin. Only stored pairs feed the
  // domain — the diagonal is excluded by construction, since a self-pair
  // rendered on the RTT scale would drag the split downwards. ─────────────────
  const cells = Array.from(new Set(Array.from(lookup.values())))
  const observed = cells.map((c) => c.stats.median)
  const split = splitAtWidestGap(observed)
  const lowCells = split ? cells.filter((c) => c.stats.median <= split.mid) : cells
  const highCells = split ? cells.filter((c) => c.stats.median > split.mid) : []

  // The colour split is derived from VALUES; the CCX split is topology. On an
  // honest capture they are the same partition, but nothing forces that — so
  // verify, and on a mismatch label the plateaus by value order and say so in
  // a note, rather than silently badging a slow intra pair as "cross L3".
  const topologyPure =
    !!split &&
    lowCells.every((c) => c.sameCcx) &&
    highCells.every((c) => !c.sameCcx)

  const plateau = (cs: Cell[]) => {
    const m = median(cs.map((c) => c.stats.median))
    return m === undefined ? '—' : String(Math.round(m))
  }
  const lowName  = topologyPure ? 'same L3   ' : 'faster    '
  const highName = topologyPure ? 'cross L3  ' : 'slower    '
  const swatches: { label: string; color: string }[] =
    [{ label: `${lowName}≈${plateau(lowCells)} ns  (${lowCells.length})`, color: matrixPalette.low }]
  if (highCells.length > 0) {
    swatches.push({ label: `${highName}≈${plateau(highCells)} ns  (${highCells.length})`, color: matrixPalette.high })
  }
  const legendRows = swatches.length + 1  // + the CCX-boundary line row

  const notes: string[] = ['— = self-pair, not measured']
  if (split) {
    // The empty interval is the finding stated as a number: the colour
    // threshold sits inside it, so neither plateau owns a gradient.
    notes.push(
      isNarrow
        ? `no pair in ${ns1(split.lowMax)}–${ns1(split.highMin)} ns`
        : 'no pair measured between',
    )
    if (!isNarrow) notes.push(`${ns1(split.lowMax)} and ${ns1(split.highMin)} ns`)
  }
  if (split && !topologyPure) {
    if (isNarrow) notes.push('colour plateaus ≠ CCX split')
    else notes.push('colour plateaus do not match', 'the CCX split — check capture')
  }

  const narrowNoteY = NARROW_LEGEND_Y + legendRows * LEGEND_ROW_H + 12
  const margin = isNarrow
    ? { top: 26, right: 12, bottom: narrowNoteY + notes.length * NOTE_LINE_H + 6, left: 48 }
    : { top: 26, right: 20, bottom: BOTTOM_WIDE,   left: 62 }

  const avail = W - margin.left - margin.right
  const gridSpace = isNarrow ? avail : Math.max(200, avail - (LEGEND_W + LEGEND_GAP))
  const side = Math.max(MIN_SIDE, Math.min(gridSpace, MAX_SIDE))
  const H = margin.top + side + margin.bottom

  const { g, inner, colors } = setupSVG(el, W, H, margin, title ?? DEFAULT_TITLE)

  // Centre the grid (+ legend column, when there is one) in the available width.
  const blockW = side + (isNarrow ? 0 : LEGEND_W + LEGEND_GAP)
  const gx = Math.max(0, (inner.w - blockW) / 2)
  const grid = g.append('g').attr('transform', `translate(${gx},0)`)

  const x = scaleBand<number>().domain(cpus).range([0, side]).paddingInner(0.06).paddingOuter(0)
  const y = scaleBand<number>().domain(cpus).range([0, side]).paddingInner(0.06).paddingOuter(0)

  // ── Colour: two plateaus, threshold anchored in the empty interval (the
  // cluster analysis above the margin computation). ───────────────────────────
  const fillScale = scaleThreshold<number, string>()
    .domain(split ? [split.mid] : [])
    .range(split ? [matrixPalette.low, matrixPalette.high] : [matrixPalette.low])

  const labelScale = scaleThreshold<number, string>()
    .domain(split ? [split.mid] : [])
    .range(split ? [matrixPalette.lowLabel, matrixPalette.highLabel] : [matrixPalette.lowLabel])

  // ── Tiles ───────────────────────────────────────────────────────────────────
  const tiles: Tile[] = []
  for (const row of cpus) {
    for (const col of cpus) {
      if (row === col) {
        tiles.push({ row, col, kind: 'self' })
        continue
      }
      const cell = lookup.get(cellKey(row, col))
      tiles.push(cell ? { row, col, kind: 'pair', cell } : { row, col, kind: 'missing' })
    }
  }

  const baseStroke = (d: Tile) => (d.kind === 'pair' ? 'none' : colors.border)
  const tileFill = (d: Tile) =>
    d.kind === 'pair' ? fillScale(d.cell!.stats.median) : colors.bgSecondary

  const tileG = grid.append('g').attr('class', 'cells')

  const rects = tileG
    .selectAll<SVGRectElement, Tile>('rect.cell')
    .data(tiles)
    .join('rect')
    .attr('class', 'cell')
    .attr('x', (d) => x(d.col) ?? 0)
    .attr('y', (d) => y(d.row) ?? 0)
    .attr('width', x.bandwidth())
    .attr('height', y.bandwidth())
    .attr('rx', 2)
    .attr('fill', tileFill)
    .attr('stroke', baseStroke)
    .attr('stroke-width', 1)

  // Native <title> tooltips: unlike pointer handlers they survive the static
  // SVG clone ChartZoom puts in its modal, so the per-cell spread stays
  // reachable when the chart is enlarged.
  rects.append('title').text((d) => tileTitle(d, ccxOf, matrix))

  // Labels live in their own group above the tiles so a hovered tile's outline
  // can never be painted over its own number.
  const showLabels = x.bandwidth() >= MIN_CELL_PX_FOR_LABEL
  const labelG = grid.append('g').attr('class', 'cell-labels')

  labelG
    .selectAll<SVGTextElement, Tile>('text.cell-label')
    .data(showLabels ? tiles : tiles.filter((d) => d.kind !== 'pair'))
    .join('text')
    .attr('class', 'cell-label')
    .attr('x', (d) => (x(d.col) ?? 0) + x.bandwidth() / 2)
    .attr('y', (d) => (y(d.row) ?? 0) + y.bandwidth() / 2)
    .attr('text-anchor', 'middle')
    .attr('dominant-baseline', 'central')
    .attr('font-size', typography.captionSize)
    .attr('font-family', typography.fontMono)
    .attr('fill', (d) =>
      d.kind === 'pair' ? labelScale(d.cell!.stats.median) : colors.textMuted)
    .style('pointer-events', 'none')
    // Whole ns: the intra cluster sits on a ~1-cycle quantisation ladder, so a
    // decimal place here would imply a resolution the harness does not have.
    // The spread lives in the readout and the <title>, not on the tile.
    .text((d) => (d.kind === 'pair' ? String(Math.round(d.cell!.stats.median)) : '—'))

  // ── Axes ────────────────────────────────────────────────────────────────────
  // isNarrow is passed as false deliberately: the tick labels are single core
  // ids, which never collide, so the helper's rotated narrow treatment would
  // cost legibility for nothing.
  appendXAxis(grid, { h: side }, colors, axisBottom(x).tickSize(0), false, false)
  appendYAxis(grid, colors, axisLeft(y).tickSize(0))

  // ── CCX brackets and the seam ───────────────────────────────────────────────
  const bandStart = (idx: number) => (x(cpus[idx]) ?? 0)
  const bandEnd = (idx: number) => bandStart(idx) + x.bandwidth()
  const gapPx = x.step() - x.bandwidth()
  // Midpoint of the inter-band gutter immediately before band `idx`.
  const boundaryAt = (idx: number) => bandStart(idx) - gapPx / 2

  groups.forEach((grp) => {
    const from = bandStart(grp.startIdx)
    const to = bandEnd(grp.endIdx)
    const label = isNarrow ? `CCX${grp.ccx}` : `CCX${grp.ccx} · L3 ${grp.l3}`

    // Column bracket, below the x tick labels.
    grid.append('path')
      .attr('d', `M${from},${side + BRACKET_Y - 4} L${from},${side + BRACKET_Y} ` +
                 `L${to},${side + BRACKET_Y} L${to},${side + BRACKET_Y - 4}`)
      .attr('fill', 'none')
      .attr('stroke', colors.border)
      .attr('stroke-width', 1)
    grid.append('text')
      .attr('x', (from + to) / 2)
      .attr('y', side + BRACKET_LBL_Y)
      .attr('text-anchor', 'middle')
      .attr('font-size', typography.captionSize)
      .attr('font-family', typography.fontMono)
      .attr('fill', colors.textSecondary)
      .text(label)

    // Row bracket, left of the y tick labels.
    const bx = isNarrow ? -24 : -30
    grid.append('path')
      .attr('d', `M${bx + 4},${from} L${bx},${from} L${bx},${to} L${bx + 4},${to}`)
      .attr('fill', 'none')
      .attr('stroke', colors.border)
      .attr('stroke-width', 1)
    grid.append('text')
      .attr('transform', `translate(${bx - 5},${(from + to) / 2}) rotate(-90)`)
      .attr('text-anchor', 'middle')
      .attr('font-size', typography.captionSize)
      .attr('font-family', typography.fontMono)
      .attr('fill', colors.textSecondary)
      .text(label)
  })

  // The seam itself: a rule at every CCX transition, on both axes, drawn over
  // the tiles and overhanging the grid slightly, so the four quadrants read as
  // framed structure rather than as something inferred from colour alone.
  //
  // The rule is cut into a channel of card background first. A bare accent line
  // would be nearly invisible: --cyan is oklch(65% 0.18 222) and the intra
  // plateau is oklch(72% 0.18 222) — same hue, 7 points of lightness apart — so
  // the seam would disappear exactly where it matters, along the intra blocks.
  // The channel gives it contrast against both plateaus and is itself the gap.
  const seamG = grid.append('g').attr('class', 'ccx-seam')
  const seamRule = (x1: number, y1: number, x2: number, y2: number) => {
    seamG.append('line')
      .attr('x1', x1).attr('x2', x2).attr('y1', y1).attr('y2', y2)
      .attr('stroke', colors.bg).attr('stroke-width', SEAM_CHANNEL_PX)
    seamG.append('line')
      .attr('x1', x1).attr('x2', x2).attr('y1', y1).attr('y2', y2)
      .attr('stroke', colors.cyan).attr('stroke-width', 1.5)
  }
  groups.slice(1).forEach((grp) => {
    const at = boundaryAt(grp.startIdx)
    seamRule(at, -SEAM_OVERHANG, at, side + SEAM_OVERHANG)
    seamRule(-SEAM_OVERHANG, at, side + SEAM_OVERHANG, at)
  })

  // ── Hover readout ───────────────────────────────────────────────────────────
  const readoutLine = (lineY: number, fill: string) =>
    grid.append('text')
      .attr('x', 0)
      .attr('y', side + lineY)
      .attr('font-size', typography.annotationSize)
      .attr('font-family', typography.fontMono)
      .attr('fill', fill)

  const readout1 = readoutLine(READOUT_Y, colors.textSecondary)
  const readout2 = readoutLine(READOUT_Y2, colors.textMuted)

  const idleLine2 = isNarrow
    ? `${lookup.size / 2} pairs · ${matrix.placements_per_cell} placements each`
    : `${lookup.size / 2} pairs · ${matrix.placements_per_cell} placements each · ` +
      `${matrix.windows_per_placement} windows per placement`

  function setReadout(d: Tile | null) {
    if (!d) {
      readout1.text('hover or tap a cell for its across-placement spread')
      readout2.text(idleLine2)
      return
    }
    if (d.kind === 'self') {
      readout1.text(`core ${d.row} · self-pair`)
      readout2.text('not measured — no interconnect hop')
      return
    }
    if (d.kind === 'missing' || !d.cell) {
      readout1.text(`cores ${d.row}↔${d.col}`)
      readout2.text('no capture for this pair')
      return
    }
    const { a, b, sameCcx, stats } = d.cell
    const regime = sameCcx
      ? `same L3 (CCX${ccxOf.get(a)})`
      : `cross L3 (CCX${ccxOf.get(a)}↔CCX${ccxOf.get(b)})`
    if (isNarrow) {
      readout1.text(`${a}↔${b} · ${sameCcx ? 'same' : 'cross'} L3 · ${ns1(stats.median)} ns`)
      readout2.text(`IQR ${ns1(stats.iqr_lo)}–${ns1(stats.iqr_hi)} · max ${ns1(stats.max)} ns`)
    } else {
      readout1.text(`cores ${a}↔${b} · ${regime} · median ${ns1(stats.median)} ns`)
      readout2.text(
        `placement IQR ${ns1(stats.iqr_lo)}–${ns1(stats.iqr_hi)} ns · ` +
        `max ${ns1(stats.max)} ns · n=${stats.n_reps}`,
      )
    }
  }

  setReadout(null)

  rects
    .style('cursor', 'pointer')
    .on('mouseenter', function (_event, d) {
      select(this).attr('stroke', colors.textPrimary).attr('stroke-width', 1.5)
      setReadout(d)
    })
    .on('mouseleave', function (_event, d) {
      select(this).attr('stroke', baseStroke(d)).attr('stroke-width', 1)
      setReadout(null)
    })

  // ── Legend (swatches and notes precomputed with the cluster analysis) ──────
  const legendX = isNarrow ? 0 : side + LEGEND_GAP
  const legendY = isNarrow ? side + NARROW_LEGEND_Y : 0

  appendLegendRects(grid, swatches, { x: legendX, y: legendY, spacing: LEGEND_ROW_H }, colors)
  appendLegendLines(
    grid,
    [{ label: 'CCX boundary', color: colors.cyan }],
    { x: legendX, y: legendY + swatches.length * LEGEND_ROW_H - 1 },
    colors,
  )

  // ── Honesty notes ───────────────────────────────────────────────────────────
  const notesX = isNarrow ? 0 : legendX
  const notesY = isNarrow ? side + narrowNoteY : legendY + legendRows * LEGEND_ROW_H + 14
  appendNotes(grid, notes, notesX, notesY, colors.textMuted)
}

function appendNotes(
  container: Selection<SVGGElement, unknown, null, undefined>,
  notes: string[],
  x: number,
  y: number,
  fill: string,
): void {
  notes.forEach((note, i) => {
    container.append('text')
      .attr('x', x)
      .attr('y', y + i * NOTE_LINE_H)
      .attr('font-size', typography.captionSize)
      .attr('font-family', typography.fontMono)
      .attr('fill', fill)
      .text(note)
  })
}

// ─── Native tooltip text ──────────────────────────────────────────────────────

function tileTitle(
  d: Tile,
  ccxOf: Map<number, number>,
  matrix: LatencyMatrixBlock,
): string {
  if (d.kind === 'self') return `core ${d.row} — self-pair, not measured`
  if (d.kind === 'missing' || !d.cell) return `cores ${d.row}↔${d.col} — no capture`
  const { a, b, sameCcx, stats } = d.cell
  const regime = sameCcx
    ? `same L3 (CCX${ccxOf.get(a)})`
    : `cross L3 (CCX${ccxOf.get(a)}↔CCX${ccxOf.get(b)})`
  return [
    `cores ${a}↔${b} — ${regime}`,
    `median ${ns1(stats.median)} ns`,
    `across-placement IQR ${ns1(stats.iqr_lo)}–${ns1(stats.iqr_hi)} ns`,
    `min ${ns1(stats.min)} ns · max ${ns1(stats.max)} ns`,
    `${stats.n_reps} placements × ${matrix.windows_per_placement} windows`,
  ].join('\n')
}
