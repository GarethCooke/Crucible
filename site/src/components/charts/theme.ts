// Shared D3 palette and typography for all Crucible charts.
// Values sourced from design-tokens.ts — do not hardcode colours here.

import { tokens } from '@/lib/design-tokens'

export const palette = {
  sorted:     tokens.color.chart.sorted,
  unsorted:   tokens.color.chart.unsorted,
  branchless: tokens.color.chart.series[2],   // yellow-green — consistent with 3-variant index scheme
  // false-sharing demo: padded = good (cyan), unpadded = bad (rose)
  padded:   tokens.color.chart.series[0],
  unpadded: tokens.color.chart.series[2],
  // AoS-vs-SoA demo (06): soa = good (cyan), aos = slower (red-orange), autovec = SIMD (yellow-green)
  'soa-scalar':  tokens.color.chart.series[0],
  'aos-scalar':  tokens.color.chart.series[1],
  'soa-autovec': tokens.color.chart.series[2],
  // allocators demo (05): index-ordered to match PressureSweepChart's variantColorByIndex
  'cross-thread-malloc':   tokens.color.chart.series[0],
  'freelist-return-queue': tokens.color.chart.series[1],
  'arena-batch-handoff':   tokens.color.chart.series[2],
  // SPSC queue demo (04): index-ordered to match LatencyVsLoadChart's variantColorByIndex
  'lockfree-handrolled': tokens.color.chart.series[0],
  'lockfree-boost':      tokens.color.chart.series[1],
  'mutex-condvar':       tokens.color.chart.series[2],
  // map comparison demo (07): index-ordered so variantColor() assigns distinct colours
  'absl_flat':  tokens.color.chart.series[0],
  'std_unord':  tokens.color.chart.series[1],
  'std_map':    tokens.color.chart.series[2],
  'boost_flat': tokens.color.chart.series[3],
  'sorted_vec': tokens.color.chart.series[4],
  // sorting shootout demo (08): same series palette so colours are consistent site-wide
  'std_sort':   tokens.color.chart.series[0],
  'pdqsort':    tokens.color.chart.series[1],
  'radix_lsd':  tokens.color.chart.series[2],
  // Black-Scholes cross-arch pairing — shared colours across demo 03 (Zen 2) and demo 09 (Pi).
  // Analogous variants take the same series index in both demos.
  // NB: demo-03 JSON uses no-underscore keys (scalarlibm, scalarpoly, sse2, avx2fma) — confirmed by grep.
  // demo 03 (Zen 2 SSE/AVX2) and demo 09 (Pi NEON) share scalarlibm/scalarpoly keys:
  'scalarlibm':   tokens.color.chart.series[0],   // libm baseline — shared
  'scalarpoly':   tokens.color.chart.series[1],   // poly baseline — shared
  'sse2':         tokens.color.chart.series[2],   // demo-03: 4-wide 128-bit SIMD
  'avx2fma':      tokens.color.chart.series[3],   // demo-03 only (no demo-09 counterpart = width ceiling)
  // demo 09 (Pi NEON): series[3] stays empty — no wider unit = the ceiling
  'neon':         tokens.color.chart.series[2],   // = sse2 (4-wide / 128-bit analogue)
  'autovec':      tokens.color.chart.series[4],   // demo-9-only
  series:   tokens.color.chart.series,
} as const

export function getColors() {
  if (typeof document === 'undefined') {
    return {
      bg:            tokens.color.dark.bgCard,
      bgSecondary:   tokens.color.dark.bgSecondary,
      textPrimary:   tokens.color.dark.textPrimary,
      textSecondary: tokens.color.dark.textSecondary,
      textMuted:     tokens.color.dark.textMuted,
      border:        tokens.color.dark.border,
      cyan:          tokens.color.dark.cyan,
    }
  }
  const cs = getComputedStyle(document.documentElement)
  return {
    bg:            cs.getPropertyValue('--bg-card').trim(),
    bgSecondary:   cs.getPropertyValue('--bg-secondary').trim(),
    textPrimary:   cs.getPropertyValue('--text-primary').trim(),
    textSecondary: cs.getPropertyValue('--text-secondary').trim(),
    textMuted:     cs.getPropertyValue('--text-muted').trim(),
    border:        cs.getPropertyValue('--border-color').trim(),
    cyan:          cs.getPropertyValue('--cyan').trim(),
  }
}

export const typography = {
  fontMono:       tokens.font.mono,
  fontSans:       tokens.font.sans,
  axisSize:       tokens.chart.axisSize,
  labelSize:      tokens.chart.labelSize,
  annotationSize: tokens.chart.annotationSize,
  captionSize:    tokens.chart.captionSize,
} as const

// Maps a variant name to its colour. Falls back to the first series colour.
export function variantColor(variant: string): string {
  if (variant in palette) return palette[variant as keyof typeof palette] as string
  return palette.series[0]
}

// Maps a numeric index to a series colour, cycling through the palette.
// Clamps negative indices to 0 so callers don't need a guard.
export function variantColorByIndex(idx: number): string {
  return palette.series[Math.max(0, idx) % palette.series.length] as string
}
