// Shared D3 palette and typography for all Crucible charts.
// Values sourced from design-tokens.ts — do not hardcode colours here.

import { tokens } from '@/lib/design-tokens'

export const palette = {
  sorted:     tokens.color.chart.sorted,
  unsorted:   tokens.color.chart.unsorted,
  branchless: tokens.color.chart.series[3],   // amber — distinct from cyan/emerald
  // false-sharing demo: padded = good (cyan), unpadded = bad (rose)
  padded:   tokens.color.chart.series[0],
  unpadded: tokens.color.chart.series[2],
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
  fontMono: tokens.font.mono,
  fontSans: tokens.font.sans,
  axisSize:  tokens.chart.axisSize,
  labelSize: tokens.chart.labelSize,
} as const

// Maps a variant name to its colour. Falls back to the first series colour.
export function variantColor(variant: string): string {
  if (variant in palette) return palette[variant as keyof typeof palette] as string
  return palette.series[0]
}

// Maps a numeric index to a series colour, cycling through the palette.
export function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length] as string
}
