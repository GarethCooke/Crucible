// Crucible design tokens — colour palette copied verbatim from garethcooke.com.
// Typography and component scale diverge to suit a dense, code-heavy benchmark context.
// Keep the color.* and font.* families in sync with the portfolio; everything else is local.

export const tokens = {
  color: {
    // Accent palette — hue 222 (blue-cyan) — identical to garethcooke.com
    accent: {
      50:  'oklch(97% 0.03 222)',
      100: 'oklch(93% 0.06 222)',
      200: 'oklch(87% 0.10 222)',
      300: 'oklch(79% 0.14 222)',
      400: 'oklch(72% 0.17 222)',
      500: 'oklch(65% 0.18 222)',
      600: 'oklch(57% 0.17 222)',
      700: 'oklch(48% 0.15 222)',
      800: 'oklch(38% 0.12 222)',
      900: 'oklch(28% 0.09 222)',
    },

    // Raw surface scale — identical to garethcooke.com
    surface: {
      900: '#06090f',
      800: '#090e18',
      700: '#0c1220',
      600: '#1c2d4a',
    },

    // Crucible is dark-only; no light-mode aliases
    dark: {
      bgPrimary:     '#06090f',
      bgSecondary:   '#090e18',
      bgCard:        '#0c1220',
      textPrimary:   '#eef2f7',
      textSecondary: '#8b9dbf',
      textMuted:     '#435270',
      border:        'rgba(255,255,255,0.07)',
      borderHover:   'rgba(255,255,255,0.14)',
      cyan:          'oklch(65% 0.18 222)',
      emerald:       'oklch(65% 0.17 182)',
    },

    // D3 chart palette — ordered for sorted/unsorted comparison + generic series.
    // series[0] (72%) and series[1] (52%) have a 20-pt luminance gap so the
    // primary "vs" pair is distinguishable under deuteranopia as well as by hue.
    chart: {
      sorted:   'oklch(72% 0.18 222)',   // lighter blue-cyan — the "good" result
      unsorted: 'oklch(52% 0.17 30)',    // darker red-orange — the "bad" result
      series: [
        'oklch(72% 0.18 222)',   // lighter blue-cyan
        'oklch(52% 0.17 30)',    // darker red-orange
        'oklch(78% 0.15 95)',    // light yellow-green
        'oklch(60% 0.17 320)',   // mid rose
        'oklch(70% 0.16 260)',   // mid purple
      ] as const,
    },
  },

  font: {
    // Mono is primary in Crucible — headings, data labels, benchmark IDs
    mono:  '"JetBrains Mono", ui-monospace, monospace',
    // Sans for UI chrome and navigation
    sans:  '"Space Grotesk", ui-sans-serif, system-ui, sans-serif',
    // Body for prose articles / methodology pages
    body:  '"Inter", ui-sans-serif, system-ui, sans-serif',
  },

  // Compact type scale — smaller base than the portfolio for data density
  fontSize: {
    xs:   '0.6875rem',  // 11px — D3 axis labels
    sm:   '0.75rem',    // 12px — D3 data labels, captions
    base: '0.875rem',   // 14px — body text, table cells
    md:   '1rem',       // 16px — sub-headings, card titles
    lg:   '1.25rem',    // 20px — section headings
    xl:   '1.5rem',     // 24px — page headings
    '2xl': '2rem',      // 32px — hero / benchmark name
  },

  // D3 chart-specific type sizes (numeric px for axis scale)
  chart: {
    axisSize:        11,
    labelSize:       12,
    titleSize:       13,
    annotationSize:  10,  // value labels, footers, annotation text
    captionSize:      9,  // rotated axis titles, secondary annotations
    mobileBreakpoint: 480, // SVG width threshold for narrow-layout adjustments
  },

  radius: {
    sm:  '3px',
    md:  '4px',   // bar charts, inline code
    lg:  '8px',   // code blocks, cards
    xl:  '12px',
  },

  // Prose styles for MDX benchmark write-ups
  prose: {
    maxWidth:   '72ch',
    lineHeight: '1.75',
    codeSize:   '0.875em',
    codePadding: '0.1em 0.4em',
    preRadius:  '8px',
    prePadding: '1.25rem 1.5rem',
  },

  easing: {
    spring: 'cubic-bezier(0.16,1,0.3,1)',
  },

  duration: {
    fast:   '0.25s',
    normal: '0.5s',
  },

  stagger: {
    0: '0s',
    1: '0.08s',
    2: '0.16s',
  },
} as const

export type Tokens = typeof tokens
