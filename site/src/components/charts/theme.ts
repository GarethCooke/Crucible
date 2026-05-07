// Shared D3 palette and typography for all Crucible charts.
// Dark theme mirrors garethcooke.com — surface-900 background, hue-222 accent.

export const palette = {
  // Named variants — order matches typical sorted/unsorted comparison
  sorted:   'oklch(65% 0.18 222)',   // cyan  — the "good" result
  unsorted: 'oklch(65% 0.17 182)',   // emerald-teal — the "bad" result
  // Generic series for future charts
  series: [
    'oklch(65% 0.18 222)',
    'oklch(65% 0.17 182)',
    'oklch(65% 0.17 320)',
    'oklch(65% 0.17 60)',
  ],
} as const

export const colors = {
  bg:         '#0c1220',    // --color-surface-700 (card background)
  bgSecondary:'#090e18',
  textPrimary:'#eef2f7',
  textSecondary:'#8b9dbf',
  textMuted:  '#435270',
  border:     'rgba(255,255,255,0.07)',
  cyan:       'oklch(65% 0.18 222)',
} as const

export const typography = {
  fontMono: '"JetBrains Mono", ui-monospace, monospace',
  fontSans: '"Space Grotesk", ui-sans-serif, system-ui, sans-serif',
  axisSize: 11,
  labelSize: 12,
} as const

// Maps a variant name to its colour. Falls back to the first series colour.
export function variantColor(variant: string): string {
  if (variant in palette) return palette[variant as keyof typeof palette] as string
  return palette.series[0]
}
