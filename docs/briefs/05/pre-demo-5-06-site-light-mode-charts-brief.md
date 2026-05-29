# Crucible — site light-mode chart theming brief

**Pre-demo-5 brief 6 of 9. Decision is to keep light mode; this brief makes the charts respect it.**

---

## 1. Context

`globals.css` defines a full `html.light` override block and `TopNav.tsx` exposes a theme-toggle button. Switching to light mode flips `--bg-card`, `--text-muted`, `--border-color`, and the rest of the semantic CSS custom properties.

D3 charts don't follow. The five chart components import colour strings from `components/charts/theme.ts`, which sources them from `tokens.color.dark.*` in `design-tokens.ts`. These are plain string constants resolved at module-import time — `'#0c1220'`, `'rgba(255,255,255,0.07)'`, etc. — and passed directly to D3 (`.attr('fill', colors.bg)`). The strings have no relationship to the runtime CSS-var state.

Result: a visitor in light mode sees a light-grey page with five dark-blue chart panels glued onto it. Axis labels, gridlines, and chart text remain dark-mode-coloured against the light background — frequently unreadable.

A secondary instance of the same pattern: the no-data fallback boxes (M-06). `Benchmark.tsx` uses `var(--border-color)` and `var(--cyan)` (CSS vars — correct), but `ThroughputBars.tsx`, `TimeVsN.tsx`, and `CounterOverlay.tsx` hardcode raw values (`'rgba(255,255,255,0.07)'`, `'oklch(65% 0.18 222)'`). Five no-data boxes total; three break in light mode in different ways depending on which component renders them.

This brief makes charts theme-aware (M-01) and unifies the no-data box styling (M-06) in one pass, since they share the underlying mechanism: read CSS vars at draw time rather than baking in dark-mode strings.

---

## 2. Goals

- All five chart components read their background, border, axis, gridline, and text colours from CSS custom properties at draw time.
- Toggling the theme re-renders every chart with the new colour values without a page reload.
- The four no-data fallback boxes (across `Benchmark.tsx`, `ThroughputBars.tsx`, `TimeVsN.tsx`, `CounterOverlay.tsx`) all use the same CSS-var-based styling.
- Typography (font sizes, line heights) stays as constants — those values are theme-invariant.
- Series palette (the data colours) stays as constants for now — colour-blind-safety improvements are brief 8 (M-12).

---

## 3. New hook: `useTheme`

**File:** `site/src/hooks/useTheme.ts` (new).

Watches `<html>` for `class` attribute changes and returns a `'dark' | 'light'` token. Charts depend on this in their render `useEffect` so a theme toggle triggers redraw.

```ts
'use client';

import { useEffect, useState } from 'react';

export type Theme = 'dark' | 'light';

export function useTheme(): Theme {
  const [theme, setTheme] = useState<Theme>('dark');

  useEffect(() => {
    const root = document.documentElement;
    const read = (): Theme => (root.classList.contains('light') ? 'light' : 'dark');

    setTheme(read());

    const observer = new MutationObserver(() => setTheme(read()));
    observer.observe(root, { attributes: true, attributeFilter: ['class'] });
    return () => observer.disconnect();
  }, []);

  return theme;
}
```

The initial state is `'dark'` to match the SSR/static-export default; the effect corrects to the actual class on mount. This avoids hydration mismatches.

---

## 4. CSS-var reader

**File:** `site/src/components/charts/theme.ts`.

Replace the static `colors` object with a `getColors()` function. Charts call it inside their render effect, so values are read fresh on every render.

```ts
// BEFORE — module-time constants:
export const colors = {
  bg: tokens.color.dark.bgCard,
  border: tokens.color.dark.borderColor,
  textMuted: tokens.color.dark.textMuted,
  textPrimary: tokens.color.dark.textPrimary,
  // ...
} as const;

// AFTER — runtime reader:
export function getColors() {
  if (typeof document === 'undefined') {
    // SSR path — use dark defaults from design tokens
    return {
      bg: tokens.color.dark.bgCard,
      border: tokens.color.dark.borderColor,
      textMuted: tokens.color.dark.textMuted,
      textPrimary: tokens.color.dark.textPrimary,
      // ...
    };
  }
  const cs = getComputedStyle(document.documentElement);
  return {
    bg: cs.getPropertyValue('--bg-card').trim(),
    border: cs.getPropertyValue('--border-color').trim(),
    textMuted: cs.getPropertyValue('--text-muted').trim(),
    textPrimary: cs.getPropertyValue('--text-primary').trim(),
    // ...
  };
}
```

Map every existing `colors.*` key to its corresponding `--*` CSS custom property. CC should enumerate the full set against the current `theme.ts` exports and `globals.css` `:root` block before writing — there are several keys to cover.

`typography`, `palette`, and any other non-colour exports from `theme.ts` stay as constants and continue to be imported directly.

---

## 5. Update each chart's render effect

For every chart component (`ThroughputBarsChart.tsx`, `TimeVsNChart.tsx`, `CounterOverlayChart.tsx`, `LatencyHistogram.tsx`, `LatencyVsLoad.tsx`):

1. Add `'use client'` if not already present (the `useTheme` hook requires client component).
2. Add `import { useTheme } from '@/hooks/useTheme'`.
3. Replace `import { colors, typography, palette } from './theme'` with `import { getColors, typography, palette } from './theme'`.
4. Inside the component body: `const theme = useTheme()`.
5. Inside the render `useEffect`: `const colors = getColors()` as the first line.
6. Add `theme` to the `useEffect` dependency array.

The render code stays the same — it still references `colors.bg`, `colors.border`, etc. The change is that `colors` is now a fresh runtime read on every render rather than a module constant, and the effect re-runs when `theme` changes.

Server components that *contain* these charts (e.g. `ThroughputBars.tsx`) don't need changes — they still pass data to client chart components as before.

---

## 6. M-06 — unify no-data fallback boxes

The four no-data fallback boxes currently exist in:

- `site/src/components/Benchmark.tsx` lines 84–94 (readFile catch path) — uses CSS vars ✓
- `site/src/components/Benchmark.tsx` lines 107–116 (noData branch) — uses CSS vars ✓
- `site/src/components/charts/ThroughputBars.tsx` lines 37–43 — hardcoded raw values ✗
- `site/src/components/charts/TimeVsN.tsx` lines 32–37 — hardcoded raw values ✗
- `site/src/components/charts/CounterOverlay.tsx` lines 23–31 — hardcoded raw values ✗

Extract a single `NoData` component:

**File:** `site/src/components/charts/NoData.tsx` (new).

```tsx
export function NoData({ children }: { children?: React.ReactNode }) {
  return (
    <div
      className="my-8 rounded-xl border p-6 text-xs font-mono"
      style={{
        background: 'var(--bg-card)',
        borderColor: 'var(--border-color)',
        color: 'var(--cyan)',
      }}
    >
      {children ?? 'No benchmark data available.'}
    </div>
  );
}
```

Replace all five existing inline fallback boxes with `<NoData />` calls. The two in `Benchmark.tsx` can pass error context as children if they currently do; keep the messaging behaviour the same.

After this, no chart-area fallback box has raw colour values anywhere — they all flip cleanly between dark and light mode via the CSS vars they depend on.

---

## 7. Light-mode CSS overrides — confirmation pass

`globals.css` defines the `html.light` override block. Before declaring this brief done, walk through every CSS custom property referenced by `getColors()` and the `NoData` component, and confirm each has a light-mode override:

| CSS var | Dark value | Light override present? |
|---|---|---|
| `--bg-card` | (read from `:root`) | check `html.light` block |
| `--border-color` | (read from `:root`) | check |
| `--text-muted` | (read from `:root`) | check |
| `--text-primary` | (read from `:root`) | check |
| `--cyan` | (read from `:root`) | check |
| … | … | … |

Any property used by a chart that lacks a light-mode override will read the dark default in light mode — same bug, lower-level. Add overrides as needed.

---

## 8. Verification

1. **Dark mode (default).** Open every post page and the methodology page. All charts should render visually identically to the pre-fix state. No regression.
2. **Toggle to light mode.** Click the theme toggle in the topnav. Every chart on the visible page should redraw with light-appropriate colours within one animation frame:
   - Chart background lightens
   - Axis lines and gridlines pick up the new border colour (typically a darker grey on light background)
   - Axis labels and value labels pick up the new text colour
   - Series colours (the data) stay the same — the palette is theme-invariant in this brief
3. **Toggle back.** Charts return cleanly to dark.
4. **No-data state.** If feasible, force a no-data path (e.g. point `<Benchmark>` at a non-existent slug in dev). The `NoData` box should toggle colour with the theme.
5. **SSR / static export.** `npm run build` produces a clean static export. First paint of any page in dark mode looks correct without a flicker.

---

## 9. Out of scope

- **Brief 7 (chart refactor)** — same files will be touched again for `ChartShell`, `appendGrid`, `appendLegend`, shared types, etc. Brief 7 should preserve the theme-awareness pattern (the `useTheme` + `getColors()` calls move from each chart into `ChartShell` or stay in the chart bodies, depending on the final refactor shape). Sequencing handled by the brief ordering.
- **Series palette colour-blind safety (M-12)** → brief 8.
- **Light-mode-specific series palette.** Could be desirable later (different chroma/lightness for contrast against light bg). Out of scope here; the current series palette is rendered against both backgrounds for now.
- **Theme context / provider pattern.** A future architectural improvement would centralise theme state in React Context, with the toggle button writing to it and `html.classList` mirroring it for CSS-var purposes. Out of scope — `useTheme` with `MutationObserver` is contained and works without restructuring the app shell.

---

## 10. Acceptance checklist

- [ ] `site/src/hooks/useTheme.ts` created, exports `useTheme()` returning `'dark' | 'light'`.
- [ ] `site/src/components/charts/theme.ts` exports `getColors()` (function) replacing the static `colors` object. Typography and palette exports unchanged.
- [ ] All five chart components (`ThroughputBarsChart`, `TimeVsNChart`, `CounterOverlayChart`, `LatencyHistogram`, `LatencyVsLoad`) call `useTheme()` and `getColors()`, and include `theme` in their render `useEffect` dependency array.
- [ ] `site/src/components/charts/NoData.tsx` created.
- [ ] All five existing inline no-data fallback boxes replaced with `<NoData />`. Search confirms: zero remaining occurrences of `'rgba(255,255,255,0.07)'` and `'oklch(65% 0.18 222)'` as inline style strings.
- [ ] `globals.css` `html.light` block covers every CSS var referenced by `getColors()` and `NoData`.
- [ ] Manual: dark mode renders identically to pre-fix state.
- [ ] Manual: light mode toggle re-renders every chart with light-appropriate colours within one frame.
- [ ] Manual: dark/light toggle is reversible without page reload, no visual artefacts.
- [ ] `npm run build` succeeds; static export clean; no hydration warnings in the dev console.
