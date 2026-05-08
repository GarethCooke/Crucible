// Shared D3 palette and typography for all Crucible charts.
// Values sourced from design-tokens.ts — do not hardcode colours here.

import { tokens } from '@/lib/design-tokens'

export const palette = {
  sorted:   tokens.color.chart.sorted,
  unsorted: tokens.color.chart.unsorted,
  series:   tokens.color.chart.series,
} as const

export const colors = {
  bg:           tokens.color.dark.bgCard,
  bgSecondary:  tokens.color.dark.bgSecondary,
  textPrimary:  tokens.color.dark.textPrimary,
  textSecondary:tokens.color.dark.textSecondary,
  textMuted:    tokens.color.dark.textMuted,
  border:       tokens.color.dark.border,
  cyan:         tokens.color.dark.cyan,
} as const

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
