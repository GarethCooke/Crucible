# Crucible — site chart refactor brief

**Pre-demo-5 brief 7 of 9. The big site-side refactor — one coordinated pass touching every chart component.**

---

## 1. Context

The site review surfaced one critical and seven material findings that all live in the chart layer and share a common shape: code that was reasonable when there were two chart components has become repetitive now that there are five. Doing them in one pass keeps the diff coherent; doing them piecemeal would touch the same five files repeatedly.

**Dependencies:** Brief 6 (light-mode chart theming) lands first. The `useTheme` hook, `getColors()` runtime reader, and `NoData` component established there are the foundation this brief builds on. Where this brief mentions "the existing `getColors()` call" or "the existing `useTheme()` import", those exist because brief 6 added them.

The brief packages:

- **C-01** — `filterRuns` silent-blank-SVG fallback bug (latent — not currently triggered, but a foot-gun for any future post that uses these chart combinations).
- **M-03** — `variantColorByIndex` copy-pasted in two charts.
- **M-04** — `LatencyStats` / `LatencyHistogramData` interfaces defined twice with different shapes.
- **M-05** — `Benchmark.tsx` types `latency_ns` as `unknown`.
- **M-07** — figure shell duplicated across five charts; two chart types have no title prop.
- **M-08** — `appendGrid` private to one chart; inlined in five other places.
- **M-09** — legend rendering block inlined in all five charts.
- **M-10** — Shiki theme string duplicated; `.highlighted` CSS rule missing.

---

## 2. Goals

- Each chart component renders through a shared `ChartShell` and uses shared d3 helpers; no chart re-implements the figure scaffold, grid logic, or legend layout inline.
- Latency-related types are defined once in a shared types file; `Benchmark.tsx` no longer casts `unknown` to typed run shapes.
- `filterRuns` never returns mode-less runs when the caller explicitly requests sweep data; `Benchmark.tsx` has a defensive early-exit checking required fields exist before passing data downstream.
- Shiki theme is a single shared constant; the `.highlighted` class is styled wherever `highlightLines` is used.

---

## 3. New shared files

### 3.1 `site/src/lib/perf-types.ts` (new)

Move all latency-related types here. Includes the full `LatencyStats` and `LatencyHistogramData` shapes from `LatencyHistogram.tsx`. The narrower view used by `LatencyVsLoadChart` is expressed as `Pick<LatencyHistogramData, 'stats'>`.

```ts
export interface LatencyStats {
  count: number
  min: number
  max: number
  p50: number
  p90: number
  p99: number
  p99_9: number
}

export interface LatencyHistogramData {
  scheme: string
  bucket_count: number
  min_bucket_ns: number
  counts: number[]
  stats: LatencyStats
  // any other fields from the JSON schema — confirm against actual data
}

export type LatencyStatsOnly = Pick<LatencyHistogramData, 'stats'>
```

Both `LatencyHistogram.tsx` and `LatencyVsLoad.tsx` import from here. `Benchmark.tsx`'s `RunRecord.latency_ns` becomes `LatencyHistogramData | undefined` (replacing the `unknown`). The `as LatencyRun[]` / `as SweepRun[]` casts in `Benchmark.tsx` (lines 126 and 138) become unnecessary or narrow to genuinely-typed assertions.

### 3.2 `site/src/components/charts/d3helpers.ts` (new)

Houses the extracted helpers. Each takes a `colors` argument (passed from the caller's `getColors()` result) rather than reading CSS vars internally — this keeps the helpers pure and the colour-read centralised.

```ts
import type { Selection } from 'd3-selection'
import type { ScaleLinear, ScaleLogarithmic, ScaleBand } from 'd3-scale'

type Numeric = ScaleLinear<number, number> | ScaleLogarithmic<number, number>
type Inner = { w: number; h: number }

export function appendGrid<E extends SVGGElement>(
  g: Selection<E, unknown, null, undefined>,
  y: Numeric,
  inner: Inner,
  colors: { gridline: string },
  x?: Numeric, // optional x grid for charts that want both
) {
  // … emit horizontal dashed lines from y.ticks(); if x supplied, emit vertical too
}

export function appendLegendLines(
  g: Selection<SVGGElement, unknown, null, undefined>,
  items: { label: string; color: string }[],
  position: { x: number; y: number; spacing?: number },
  colors: { textMuted: string },
) {
  // line swatch + text, vertically stacked
}

export function appendLegendRects(
  g: Selection<SVGGElement, unknown, null, undefined>,
  items: { label: string; color: string }[],
  position: { x: number; y: number; spacing?: number },
  colors: { textMuted: string },
) {
  // rect swatch + text, vertically stacked
}
```

The canonical `appendGrid` form is the two-axis version from `LatencyVsLoad.tsx:151–161`; the `x?` parameter lets the simpler charts pass only the y-axis grid.

### 3.3 `site/src/components/charts/ChartShell.tsx` (new)

Client component that wraps the figure/figcaption/div/svg scaffold. Exposes the SVG ref to the caller via React.

```tsx
'use client'

import { forwardRef, type ReactNode } from 'react'
import { getColors } from './theme'

interface ChartShellProps {
  title?: string
  ariaLabel?: string  // accessibility — see brief 8
  children?: ReactNode
}

export const ChartShell = forwardRef<SVGSVGElement, ChartShellProps>(
  function ChartShell({ title, ariaLabel }, ref) {
    const colors = getColors()
    return (
      <figure
        className="my-8"
        role="img"
        aria-label={ariaLabel ?? title ?? 'Benchmark chart'}
      >
        {title && (
          <figcaption className="text-xs mb-3 font-mono" style={{ color: colors.textMuted }}>
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
  },
)
```

The `role` + `aria-label` are part of brief 8's a11y fix; they're baked into `ChartShell` here so every chart inherits them automatically. Brief 8 builds on this.

### 3.4 `site/src/lib/syntax.ts` (new)

```ts
export const SYNTAX_THEME = 'github-dark-dimmed' as const
```

Both `CodeCompare.tsx:21` and `app/posts/[slug]/page.tsx:119` import from here. Single edit to change theme.

---

## 4. Chart component changes

Each of `ThroughputBarsChart`, `TimeVsNChart`, `CounterOverlayChart`, `LatencyHistogramChart`, `LatencyVsLoadChart`:

1. Replace the inline `<figure>...<svg ref={ref}/>...</figure>` scaffold with `<ChartShell ref={ref} title={title} ariaLabel={...}>`.
2. Replace the inline grid-drawing block with `appendGrid(g, y, inner, colors)` (or with the `x` arg for `LatencyVsLoadChart`).
3. Replace the inline legend block with `appendLegendLines(...)` or `appendLegendRects(...)` as appropriate to the chart type.
4. Replace the local `variantColorByIndex` (only in `LatencyHistogram.tsx` and `LatencyVsLoad.tsx`) with the imported one from `theme.ts`.
5. Import `LatencyStats` and `LatencyHistogramData` from `@/lib/perf-types` (only the two latency charts) and remove the local interface definitions.

Add `title?: string` to `LatencyHistogramChart` and `LatencyVsLoadChart` props (M-07). The chart bodies thread it through to `ChartShell`. `Benchmark.tsx` already has `data.title` available and can pass it.

### 4.1 `theme.ts` additions

Export `variantColorByIndex` alongside the existing `variantColor`:

```ts
export function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length]
}
```

---

## 5. C-01 — `filterRuns` and `Benchmark.tsx` early exit

### 5.1 `filterRuns`

**File:** wherever `filterRuns` is defined (search for `function filterRuns`).

The mode-less fallback is a back-compat patch for runs predating mode-aware filtering. The bug: when caller passes `'sweep'`, the fallback still returns all mode-less runs, making any demo-1–3 JSON look like it has sweep data.

Fix: gate the fallback on the requested mode. Only fall back to mode-less runs when the caller's request *could* match mode-less data (i.e., not `'sweep'` or any future mode that requires explicit tagging).

```ts
// BEFORE
const withMode = runs.filter(r => r.mode === mode)
return withMode.length > 0 ? withMode : runs.filter(r => !r.mode)

// AFTER
const withMode = runs.filter(r => r.mode === mode)
if (withMode.length > 0) return withMode
if (mode === 'sweep') return []  // sweep data must be explicitly tagged; no fallback
return runs.filter(r => !r.mode)
```

The `mode === 'sweep'` short-circuit is the targeted fix. Future modes added to the schema that should also be strict can be added to this guard.

### 5.2 `Benchmark.tsx` defensive early exit

Current `noData` check is at lines ~96 onward:

```ts
const noData = chart === 'latency-vs-load' ? sweepRuns.length === 0 : runs.length === 0
```

This is insufficient — even with the `filterRuns` fix, a `chart="latency-histogram"` on a slug whose runs lack `latency_ns` (demo 01 today) would pass `runs.length > 0` and produce a blank SVG.

Strengthen the guard by checking that the downstream chart's required field is actually populated:

```ts
const hasLatencyData = runs.some(r => r.latency_ns?.counts?.length)
const hasSweepData = sweepRuns.some(
  r => r.offered_rate_hz != null && r.offered_rate_hz > 0 && r.latency_ns?.stats != null,
)

const noData =
  chart === 'latency-histogram'
    ? !hasLatencyData
    : chart === 'latency-vs-load'
    ? !hasSweepData
    : runs.length === 0
```

Any future post that mistakenly invokes `latency-histogram` on demo 01 data now shows the `<NoData />` box (introduced in brief 6) rather than a blank SVG.

---

## 6. M-10 — `.highlighted` CSS rule

**File:** `site/src/styles/globals.css` (or wherever the rehype-pretty-code CSS lives).

The current CSS only styles `[data-rehype-pretty-code-figure] [data-highlighted-line]`. `CodeCompare`'s `highlightLines` prop applies a `.highlighted` class that nothing styles. Add a parallel rule:

```css
/* Existing: rehype-pretty-code path */
[data-rehype-pretty-code-figure] [data-highlighted-line] { /* … */ }

/* New: CodeCompare path (Shiki direct) */
.highlighted {
  background-color: rgba(255, 255, 255, 0.06);
  border-left: 3px solid var(--cyan);
  padding-left: calc(1rem - 3px);
}
```

Match whatever the existing `[data-highlighted-line]` rule does; the two paths should produce visually identical highlights so a reader can't tell which renderer was used.

---

## 7. Out of scope

- **D3 tree-shake (M-02), a11y SVG titles (M-11), palette luminance (M-12)** → brief 8. These are about *what* the charts draw and how the bundle ships; this brief is about *structure*. ChartShell's `role="img"` + `aria-label` is the only a11y piece here; SVG `<title>` element appending happens in brief 8.
- **Theme-awareness mechanism** → established in brief 6. This brief uses it.
- **MDX rewrite of post bodies** → wholly separate concern, has its own briefs (`05-mdx-rewrite-brief.md` already in the project).
- **Removing the old `LatencyHistogramData` from `LatencyVsLoad.tsx`** is part of M-04 and *is* in scope; deprecating the narrower local definition is the entire point.

---

## 8. Acceptance checklist

### Shared infrastructure

- [ ] `site/src/lib/perf-types.ts` created; exports `LatencyStats`, `LatencyHistogramData`.
- [ ] `site/src/components/charts/d3helpers.ts` created; exports `appendGrid`, `appendLegendLines`, `appendLegendRects`.
- [ ] `site/src/components/charts/ChartShell.tsx` created; renders figure+figcaption+div+svg with `role="img"` and `aria-label`.
- [ ] `site/src/lib/syntax.ts` created; exports `SYNTAX_THEME`.
- [ ] `theme.ts` exports `variantColorByIndex` alongside `variantColor`.

### Chart components

- [ ] All five chart components use `<ChartShell>` instead of inline figure scaffold.
- [ ] No chart component contains an inline grid-drawing block; all call `appendGrid` from `d3helpers`.
- [ ] No chart component contains an inline legend block; all call `appendLegendLines` or `appendLegendRects`.
- [ ] No chart component defines a local `variantColorByIndex`.
- [ ] `LatencyHistogram.tsx` and `LatencyVsLoad.tsx` import latency types from `@/lib/perf-types`; no local definitions remain.
- [ ] `LatencyHistogramChart` and `LatencyVsLoadChart` accept and render a `title` prop.

### C-01

- [ ] `filterRuns` returns `[]` when `mode === 'sweep'` and no runs match.
- [ ] `Benchmark.tsx` checks `latency_ns.counts.length` for `latency-histogram` chart and `offered_rate_hz + latency_ns.stats` for `latency-vs-load` before declaring data present.
- [ ] Manual: invoking `<Benchmark slug="01-branch-prediction" chart="latency-histogram" />` in dev renders the `<NoData />` box, not a blank SVG.
- [ ] Manual: invoking `<Benchmark slug="01-branch-prediction" chart="latency-vs-load" />` renders the `<NoData />` box.

### Types

- [ ] `Benchmark.tsx` `RunRecord.latency_ns` is typed as `LatencyHistogramData | undefined`, not `unknown`.
- [ ] `runs as LatencyRun[]` and `sweepRuns as SweepRun[]` casts in `Benchmark.tsx` removed or narrowed to typed assertions.
- [ ] `npm run typecheck` (or `tsc --noEmit`) passes cleanly.

### M-10

- [ ] `CodeCompare.tsx:21` and `app/posts/[slug]/page.tsx:119` both import `SYNTAX_THEME` from `@/lib/syntax`.
- [ ] `globals.css` has a `.highlighted` rule matching the `[data-highlighted-line]` styling.
- [ ] Manual: a `<CodeCompare>` invocation with `highlightLines` shows the highlight visually.

### Regression

- [ ] All four shipped post pages render identically to pre-refactor state (visual diff).
- [ ] Dark/light theme toggle still works (brief 6 functionality preserved).
- [ ] `npm run build` succeeds; static export clean.
