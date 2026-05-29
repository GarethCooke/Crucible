# Crucible site/ code review — findings

Review date: 2026-05-19  
Scope: `site/src/` — all four chart components, four MDX posts, Benchmark, CodeCompare, methodology page, lib, app routes, config files.  
Method: full file read; all focus areas from the brief checked. Where a finding can only be confirmed at runtime this is stated explicitly.

---

## Critical

*(Affects what a visitor sees in a shipped page, or breaks the build.)*

---

### C-01 — `Benchmark` silently renders a blank SVG for demos 1–3 when `chart="latency-histogram"` or `chart="latency-vs-load"`

**Location:** `site/src/components/Benchmark.tsx:96–117`, `site/src/components/charts/LatencyHistogram.tsx:70–98`, `site/src/components/charts/LatencyVsLoad.tsx:61–93`

**Observation:**  
`Benchmark.tsx` computes `noData` as:
```ts
const noData = chart === 'latency-vs-load' ? sweepRuns.length === 0 : runs.length === 0
```
For `chart="latency-histogram"` with `slug="01-branch-prediction"` (no `mode` prop):
- `filterRuns` returns all 18 runs (mode filter skipped when `mode === undefined`)
- `runs.length` is 18 → `noData` is `false`
- `<LatencyHistogramChart>` is rendered
- Inside the chart, `valid = ordered.filter(r => r.latency_ns && r.latency_ns.counts.length > 0)` → empty, because demo 1 runs have no `latency_ns` field
- The SVG is cleared but never drawn → a blank `<svg>` is painted with no error message

For `chart="latency-vs-load"` with any pre-demo-4 slug:
- `filterRuns(data.runs, 'sweep', undefined, variants)` with a demo 1–3 JSON:
  - `withMode = runs.filter(r => r.mode === 'sweep')` → empty
  - Fallback: `runs.filter(r => !r.mode)` → **all runs pass** (they have no `mode` field, so `!r.mode` is `true`)
  - `sweepRuns.length` is non-zero → `noData` is `false`
  - `<LatencyVsLoadChart>` renders
  - Inside the chart, `valid = runs.filter(r => r.offered_rate_hz != null && r.offered_rate_hz > 0 && r.latency_ns?.stats != null)` → empty
  - Blank SVG, no error

**Problem:** The fallback logic in `filterRuns` ("if no runs match the mode, keep runs with no mode field") was designed to make old data compatible with mode-aware filtering. It inadvertently makes any post 1–3 JSON look like it has sweep data, bypassing the `noData` guard. The visitor sees a blank SVG frame with no explanation.

**Suggested fix:**  
In `filterRuns`, do not fall back to mode-less runs when the caller explicitly requests `'sweep'`. A separate early-exit guard in `Benchmark.tsx` should check whether the JSON actually contains any runs with the required `latency_ns` / `offered_rate_hz` fields before passing them downstream, and show the no-data box if not.

**Severity:** Critical — silent blank chart on any shipped post that uses these combinations. Not currently triggered in production (no post uses this combination), but any copy-paste of a demo-4 component invocation into an older post would reproduce it with no runtime error.

---

### C-02 — `<ul>` nested inside `<p>` in `Commitment` component — invalid HTML, list loses styling on methodology page

**Location:** `site/src/app/methodology/page.tsx:8–44` (`Commitment` component), line 200–223 (Commitment n=4 usage)

**Observation:**  
The `Commitment` component wraps its children in:
```tsx
<p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
  {children}
</p>
```
Commitment n=4 passes a `<ul>` as part of its JSX children:
```tsx
<Commitment n={4} title="Statistical reporting">
  Each benchmark runs ≥20 outer repetitions …
  <ul className="mt-2 space-y-1 list-disc list-inside">
    <li><strong>Median</strong> …</li>
    …
```

**Problem:** `<ul>` is a block-level element and cannot be a descendant of `<p>`. The HTML spec requires browsers to implicitly close the `<p>` before parsing the `<ul>`, which moves the list **outside** the `<p>` element. The `<p>`'s `text-sm leading-relaxed` and `color: var(--text-secondary)` styles no longer apply to the `<ul>` or `<li>` elements. The list renders at the browser's default size and colour, visually inconsistent with the surrounding text. Verified by inspecting the rendered DOM in the page.

**Suggested fix:**  
Change the `Commitment` component to use `<div>` instead of `<p>` as the children wrapper, and move any prose `<p>` tags inside the caller's children at the call sites.

**Severity:** Critical — visible styling bug on the shipped methodology page.

---

### C-03 — Logo `<img>` has no intrinsic `width` attribute — cumulative layout shift on every page load

**Location:** `site/src/components/TopNav.tsx:99`

**Observation:**
```tsx
<img src="/iguana.svg" alt="Gareth Cooke" />
```
CSS sets `height: 88px; width: auto` but the `<img>` element has no `width` attribute and no explicit `height` attribute. The browser cannot reserve space for the image before the SVG loads.

**Problem:** The browser allocates 0×0 px for the image, then reflows when the SVG arrives at 88px height. This causes a CLS event on every page load, on every route. The topnav height is 88px and the logo drives it; a CLS in the nav shifts all page content below it. This will directly impact a CLS Lighthouse score.

**Suggested fix:**  
Add `width="auto" height="88"` to the `<img>` element, or convert to Next.js `<Image>` with explicit `width` and `height` props (which would also enable lazy-load optimisation for non-critical images). The ESLint `no-img-element` disable comment at line 98 explicitly acknowledged the tradeoff — for an SVG logo that doesn't benefit from WebP conversion, keeping `<img>` is acceptable but the dimension attributes must be added.

**Severity:** Critical — CLS on every page load for every visitor. Affects the Lighthouse score the pre-demo-5-lighthouse brief will run.

---

## Material

*(Real DRY violations, missing types, silent-failure paths in components.)*

---

### M-01 — D3 chart colours hard-coded to dark values; charts do not update when user switches to light mode

**Location:** `site/src/lib/design-tokens.ts:29–53`, `site/src/components/charts/theme.ts:16–24`, all five chart `*Chart.tsx` files

**Observation:**  
`theme.ts` exports `colors.bg`, `colors.border`, `colors.textMuted`, etc., all sourced from `tokens.color.dark.*`. These are plain string constants (`'#0c1220'`, `'rgba(255,255,255,0.07)'`, etc.) that are resolved at module-import time. All five chart components pass these strings directly to D3 `.attr('fill', colors.bg)` and `.attr('stroke', colors.border)`.

`globals.css` defines a full `html.light` override block (lines 44–55) and `TopNav.tsx` exposes a theme-toggle button. The light-mode overrides only affect CSS custom properties; they have no effect on D3 inline attributes.

**Problem:** When a visitor switches to light mode, the page background becomes `#f5f7fb` (light grey) while D3 chart backgrounds remain `#0c1220` (near-black). All chart text and axis labels remain light-coloured. The charts are visually broken in light mode. `design-tokens.ts` line 29 even has a comment "Crucible is dark-only; no light-mode aliases" — but a light mode is shipped and accessible from every page.

**Suggested fix:**  
Either (a) remove the light-mode toggle (the comment in design-tokens suggests this was the intent), or (b) change all D3 colour attributes to read CSS variables at draw time: pass `getComputedStyle(el).getPropertyValue('--bg-card')` rather than the constant string. Option (a) is simpler given the "dark-only" architectural decision.

**Severity:** Material — visible visual breakage in a shipped, user-accessible feature.

---

### M-02 — `import * as d3 from 'd3'` in all five chart files — full D3 bundle, tree-shaking disabled

**Location:** `site/src/components/charts/ThroughputBarsChart.tsx:4`, `TimeVsNChart.tsx:4`, `CounterOverlayChart.tsx:4`, `LatencyHistogram.tsx:4`, `LatencyVsLoad.tsx:4`

**Observation:**  
Every chart client component begins with `import * as d3 from 'd3'`. All five are bundled together into the client JS chunk.

**Problem:** `import * as d3` is a namespace import. Webpack and Next.js cannot tree-shake namespace imports — every export in the `d3` package is included even if only `select`, `scaleLinear`, and `axisBottom` are used. D3 v7 is approximately 230 KB gzipped. This directly inflates the JS bundle delivered to every visitor on every page that includes a chart.

**Suggested fix:**  
Replace each `import * as d3 from 'd3'` with named imports of the sub-packages actually used, e.g.:
```ts
import { select } from 'd3-selection'
import { scaleLinear, scaleLog, scaleBand } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { line, area } from 'd3-shape'
import { group } from 'd3-array'
```
This lets webpack dead-code-eliminate unused D3 modules.

**Severity:** Material — JS bundle bloat affecting every chart page; directly measurable on Lighthouse performance audit.

---

### M-03 — `variantColorByIndex` function defined identically in two chart files but absent from `theme.ts`

**Location:** `site/src/components/charts/LatencyHistogram.tsx:47–49`, `site/src/components/charts/LatencyVsLoad.tsx:33–35`

**Observation:**  
```ts
// LatencyHistogram.tsx line 47
function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length] as string
}

// LatencyVsLoad.tsx line 33 — identical
function variantColorByIndex(idx: number): string {
  return palette.series[idx % palette.series.length] as string
}
```

**Problem:** The function is copy-pasted verbatim. `theme.ts` already exports `variantColor(variant: string)` for name-based lookup but has no index-based equivalent, even though both newer charts need one.

**Suggested fix:**  
Export `variantColorByIndex` from `theme.ts` alongside `variantColor`, and import it in both chart files.

**Severity:** Material — two-site DRY violation; a palette-change needs three edits.

---

### M-04 — `LatencyHistogramData` and `LatencyStats` interfaces defined twice, with different shapes

**Location:** `site/src/components/charts/LatencyHistogram.tsx:9–17`, `site/src/components/charts/LatencyVsLoad.tsx:9–21`

**Observation:**  
`LatencyHistogram.tsx`:
```ts
interface LatencyStats { count, min, max, p50, p90, p99, p99_9 }
interface LatencyHistogramData { scheme, bucket_count, min_bucket_ns, counts, stats: LatencyStats }
```
`LatencyVsLoad.tsx`:
```ts
interface LatencyStats { count, min, max, p50, p90, p99, p99_9 }  // identical
interface LatencyHistogramData { stats: LatencyStats }              // subset — no bucket fields
```

**Problem:** Two files define interfaces with the same names describing the same JSON shape; they diverge in what fields they expose. If the schema changes, two definitions must be updated. `LatencyHistogram.tsx` exports `LatencyRun` which is imported by `Benchmark.tsx`, but `SweepRun` in `LatencyVsLoad.tsx` defines its own `latency_ns?: LatencyHistogramData` using the local (narrower) definition.

**Suggested fix:**  
Move the full `LatencyStats` and `LatencyHistogramData` interfaces into a shared file (`site/src/lib/types.ts` or similar) and import in both chart files. The narrower view in `LatencyVsLoad.tsx` can be expressed as `Pick<LatencyHistogramData, 'stats'>`.

**Severity:** Material — type divergence; schema changes require multi-file updates.

---

### M-05 — `Benchmark.tsx` types `latency_ns` as `unknown` — type safety lost at the schema's most complex boundary

**Location:** `site/src/components/Benchmark.tsx:31`

**Observation:**  
```ts
interface RunRecord {
  ...
  latency_ns?: unknown   // ← typed as unknown
}
```
The `latency_ns` histogram object is the most structurally complex field in the JSON (nested `stats`, `counts[]`, `bucket_count`, `scheme`, `percentile_convention`, `top_bucket_count`, `calibration_drift_pct`). It is then passed to chart components via `runs as LatencyRun[]` (line 126) and `sweepRuns as SweepRun[]` (line 138) — both are `as` casts over the `unknown`.

**Problem:** TypeScript provides zero help if the field shape is wrong. A JSON schema change (e.g., renaming `p99_9` to `p999`) would fail silently at runtime.

**Suggested fix:**  
Once M-04 is resolved and `LatencyHistogramData` is in a shared file, replace `latency_ns?: unknown` with `latency_ns?: LatencyHistogramData` in `RunRecord`.

**Severity:** Material — `unknown` cast at the schema's deepest boundary removes all type-checking for the demo-4 data path.

---

### M-06 — No-data error box duplicated across four components and appears twice within `Benchmark.tsx`; inconsistent use of raw values vs CSS vars

**Location:** `site/src/components/Benchmark.tsx:84–94` and `107–116`, `ThroughputBars.tsx:37–43`, `TimeVsN.tsx:32–37`, `CounterOverlay.tsx:23–31`

**Observation:**  
Five occurrences of the same "No benchmark data" fallback box. Two are inside `Benchmark.tsx` — one for the `readFile` catch (lines 84–94) and a separate one for the `noData` check (lines 107–116). Worse: the two in `Benchmark.tsx` use `'var(--border-color)'` and `'var(--cyan)'`, while the copies in `ThroughputBars`, `TimeVsN`, and `CounterOverlay` hard-code raw values `'rgba(255,255,255,0.07)'` and `'oklch(65% 0.18 222)'`.

**Problem:** Six edits to change this component; CSS-var vs raw-value inconsistency means light-mode (where these exist; see M-01) would break the fallback boxes differently depending on which component shows them.

**Suggested fix:**  
Extract a `NoData` server component (or a shared JSX fragment) in `@/components/NoData.tsx`, using CSS vars. Call it from all five sites.

**Severity:** Material — six-site repetition with a correctness inconsistency (CSS-var vs hardcoded).

---

### M-07 — Figure shell (figure + optional figcaption + div + svg) copy-pasted across five chart components; `LatencyHistogramChart` and `LatencyVsLoadChart` have no `title` prop

**Location:** `ThroughputBarsChart.tsx:73–87`, `TimeVsNChart.tsx:29–43`, `CounterOverlayChart.tsx:45–60`, `CounterOverlayChart.tsx:233–247` (`BranchMissOverlayChart`), `LatencyHistogram.tsx:88–98`, `LatencyVsLoad.tsx:82–93`

**Observation:**  
The outer chart shell:
```tsx
<figure className="my-8">
  {title && <figcaption className="text-xs mb-3 font-mono" style={{ color: colors.textMuted }}>{title}</figcaption>}
  <div className="rounded-xl border overflow-hidden" style={{ background: colors.bg, borderColor: colors.border }}>
    <svg ref={ref} className="w-full" style={{ display: 'block' }} />
  </div>
</figure>
```
is pasted into five chart components with minor variations. `LatencyHistogramChart` and `LatencyVsLoadChart` have no `title` prop at all and omit the `figcaption`, so `Benchmark.tsx` can never pass a chart title to them (and does not try).

**Problem:** Style changes (e.g., a different border-radius) require five edits. The two newest charts (demos 3–4 primary views) silently lack titles/captions even though `Benchmark.tsx` has `data.title` available.

**Suggested fix:**  
Extract a `ChartShell` client component (`ChartShell({ title, children })`) and use it in all chart render components. Add optional `title?: string` to `LatencyHistogramChart` and `LatencyVsLoadChart` Props.

**Severity:** Material — five-site structural duplication; two charts permanently miss captions.

---

### M-08 — `appendGrid` exists only in `ThroughputBarsChart.tsx`; grid logic duplicated inline in all other charts

**Location:** `ThroughputBarsChart.tsx:301–320` (`appendGrid`), `TimeVsNChart.tsx:71–74`, `CounterOverlayChart.tsx:97–110`, `LatencyHistogram.tsx:172–177` and `339–344`, `LatencyVsLoad.tsx:151–161`

**Observation:**  
`appendGrid(g, y, inner)` is a private helper in `ThroughputBarsChart.tsx` that appends horizontal dashed grid lines from the Y scale. `CounterOverlayChart.tsx` inlines an equivalent block. `TimeVsNChart.tsx`, `LatencyHistogram.tsx` (twice — CCDF and PDF renderers), and `LatencyVsLoad.tsx` (which also adds a matching X grid) all do the same. `LatencyVsLoad.tsx` has the most complete version (both axes); the others omit the X grid.

**Problem:** Six inline implementations of the same pattern. Any change to grid styling (e.g., switching to `rgba` or a different dash pattern) requires touching six call sites. The helper already exists in the codebase — it just wasn't exported.

**Suggested fix:**  
Move `appendGrid` to `theme.ts` or a new `site/src/components/charts/d3helpers.ts` and export it. The two-axis version from `LatencyVsLoad.tsx` can be the canonical form with an optional `x` axis argument.

**Severity:** Material — six-site DRY violation on a shared visual pattern.

---

### M-09 — Legend rendering block repeated inline in all five chart renderers

**Location:** `ThroughputBarsChart.tsx:276–296` (renderGrouped), `CounterOverlayChart.tsx:199–218`, `TimeVsNChart.tsx:191–209`, `LatencyHistogram.tsx:265–278` (CCDF) and `412–426` (PDF), `LatencyVsLoad.tsx:246–278`

**Observation:**  
Each chart builds its legend by appending D3 `rect`/`line` + `text` pairs in a fixed vertical layout at a right-margin X position. The structure is identical across all sites; only the items and y-spacing vary slightly.

**Problem:** Legend style (font size, spacing, swatch shape) is replicated six times. The CCDF and PDF renderers in `LatencyHistogram.tsx` have slightly diverged already (CCDF uses `line` swatches, PDF uses `rect` swatches — correct for their chart type, but the rest of the boilerplate is the same).

**Suggested fix:**  
Extract `appendLegendLines` and `appendLegendRects` helpers (by analogy with `appendGrid`) into a shared `d3helpers.ts`.

**Severity:** Material — six-site repetition; style changes require six edits.

---

### M-10 — `github-dark-dimmed` theme string duplicated in two files with separate Shiki invocation chains

**Location:** `site/src/components/CodeCompare.tsx:21`, `site/src/app/posts/[slug]/page.tsx:119`

**Observation:**  
`CodeCompare.tsx` passes `theme: 'github-dark-dimmed' as const` to `codeToHtml` (the Shiki API). `posts/[slug]/page.tsx` passes `theme: 'github-dark-dimmed'` to `rehypePrettyCode`. These are two separate syntax-highlighting chains — one for side-by-side code panels, one for fenced code blocks in MDX.

**Problem:** The two theme strings are not connected. Changing the theme requires two edits in separate files. The two rendering paths also have independent CSS styling: `CodeComparePanels` renders Shiki's inline HTML without the `.highlighted` class being styled (the CSS in `globals.css` only targets `[data-rehype-pretty-code-figure]`), meaning `highlightLines` in `CodeCompare` applies the `highlighted` class but nothing styles it.

**Suggested fix:**  
Export a shared `SYNTAX_THEME = 'github-dark-dimmed' as const` from `@/lib/design-tokens.ts` or a `@/lib/syntax.ts` constant file. Add a CSS rule for `.highlighted` that matches the `[data-highlighted-line]` style used by rehype-pretty-code (which is currently only styled for the MDX path).

**Severity:** Material — two separate concerns: the theme duplication (maintenance) and the missing `.highlighted` CSS rule (current UI gap for any `highlightLines` usage).

---

### M-11 — D3 SVG charts have no `aria-label`, `role`, or SVG `<title>` — invisible to screen readers

**Location:** All five `*Chart.tsx` files — `<svg ref={ref} className="w-full" style={{ display: 'block' }} />`

**Observation:**  
Every rendered chart is a bare `<svg>` element with no accessibility attributes. Screen readers encounter a generic SVG with no label, no title, and no description. The benchmark data shown in the charts is not available in any text-equivalent form.

**Problem:** A visitor using a screen reader gets no information from any chart on the site. This is a WCAG 2.1 Level AA failure (1.1.1 Non-text Content).

**Suggested fix:**  
At a minimum, add `aria-label` to the `<figure>` element using the chart's `title` prop when available. Longer term, a `<title>` element should be appended as the first child of each D3 SVG (e.g., `svg.append('title').text(title ?? 'Benchmark chart')`). A visually hidden data table of the key data points would be the gold standard.

*Requires runtime verification to confirm screen reader behaviour.*

**Severity:** Material — accessibility failure on every chart across all four posts.

---

### M-12 — Chart colour palette: all four series colours have identical lightness (65% OKLCH) — not color-blind-safe

**Location:** `site/src/lib/design-tokens.ts:47–53`, `site/src/components/charts/theme.ts:6–14`

**Observation:**  
The four series colours:
- `oklch(65% 0.18 222)` — blue-cyan (sorted / padded / series[0])
- `oklch(65% 0.17 182)` — emerald (unsorted / series[1])
- `oklch(65% 0.17 320)` — rose (series[2])
- `oklch(65% 0.17 60)` — amber (series[3] / branchless)

All four colours share 65% lightness and ≈0.17–0.18 chroma. The only distinguishing property is hue. For deuteranopia and protanopia viewers, hues 182 (green) and 222 (blue-cyan) are the most commonly confused pair — these are the two colours used for the primary "sorted/unsorted" and "padded/unpadded" comparisons across demos 1 and 2.

**Problem:** The two-colour comparisons that carry the main scientific finding of demos 1 and 2 may be indistinguishable for ~8% of male visitors. The Okabe-Ito palette would separate these in brightness and saturation, not just hue.

**Suggested fix:**  
Adopt Okabe-Ito or a perceptually-distinct alternative: e.g., use a luminance contrast of ≥2:1 between any two series colours in addition to hue difference. A simple improvement: increase the lightness gap between the primary two series (e.g., 72% cyan vs 52% emerald) while keeping the dark-theme aesthetics.

*Requires runtime / simulation verification to measure the actual delta-E under deuteranopia.*

**Severity:** Material — affects the primary visual claim on two of four shipped posts.

---

## Minor

*(Stylistic, naming, comments, dependency hygiene.)*

---

### N-01 — Magic font-size values `10` and `9` throughout chart renderers — drift from `typography.axisSize`

**Location:** Every chart file — `ThroughputBarsChart.tsx`, `TimeVsNChart.tsx`, `CounterOverlayChart.tsx`, `LatencyHistogram.tsx`, `LatencyVsLoad.tsx`

**Observation:**  
`typography.axisSize = 11` and `typography.labelSize = 12` are defined in `design-tokens.ts` and exported via `theme.ts`. Chart code correctly uses `typography.axisSize` and `typography.labelSize` on primary axis tick labels. But almost all secondary text (value labels, axis titles, legend labels, annotation text) uses the literal `10` or `9`, not a token.

**Problem:** Changing the chart type scale requires grep-hunting six files. The design-tokens values are already ignored in practice (the rendered size is 10, not the documented 11).

**Suggested fix:**  
Add `annotationSize: 10` and `captionSize: 9` to `tokens.chart` in `design-tokens.ts` and replace all literal `10`/`9` occurrences in chart renderers.

**Severity:** Minor.

---

### N-02 — `BranchMissOverlayChart` footer label hardcodes `N = 32 M`

**Location:** `site/src/components/charts/CounterOverlayChart.tsx:337`

**Observation:**  
```ts
.text('branch misses / op  ·  N = 32 M')
```
The `N = 32 M` value is hardcoded even though `BranchMissRun[]` contains the data from which the max N was already computed in the parent server component (`CounterOverlay.tsx:47`).

**Problem:** If demo 1 is re-run with a different max N, the chart label is silently wrong.

**Suggested fix:**  
Pass `maxN` as a prop to `BranchMissOverlayChart` and format it with the same SI suffix formatter used in `TimeVsNChart`.

**Severity:** Minor.

---

### N-03 — Post 03 Black-Scholes formula uses an un-tagged code fence

**Location:** `site/src/posts/03-simd-blackscholes.mdx:18–24`

**Observation:**  
```
```
C  = S·N(d₁) − K·e^(−rT)·N(d₂)
…
```
```
The fenced block has no language tag; rehype-pretty-code will not apply any syntax colouring or a Shiki theme. Every other code block in all four posts (asm, cpp, bash) has a language tag.

**Problem:** Slight visual inconsistency — the formula block renders as raw monospace with no colouring. For mathematical notation this may be intentional, but it's not documented.

**Suggested fix:**  
Add `text` as the language tag if no highlighting is wanted, making the intent explicit: `\`\`\`text`.

**Severity:** Minor.

---

### N-04 — `<code>` elements in methodology page use inline style that duplicates `.prose code` CSS

**Location:** `site/src/app/methodology/page.tsx:147`, and other `<code>` elements throughout the file

**Observation:**  
Methodology page `<code>` elements use:
```tsx
<code style={{ color: "var(--cyan)" }}>lscpu --extended</code>
```
The methodology page renders inside `<div className="max-w-2xl fu">` with no `.prose` wrapper. The `.prose code` CSS rule in `globals.css` (lines 275–283) applies `color: var(--cyan)` and `background`, `border`, `border-radius`, `padding` — all of which are missing from the inline-styled `<code>` elements on the methodology page.

**Problem:** Inline code on the methodology page is styled inconsistently with inline code in post articles (which get the full `.prose code` treatment). Background box, border, and padding are absent.

**Suggested fix:**  
Either wrap the methodology page content in a `<div className="prose">` to inherit the shared styles, or add a `methodology-code` class with the same properties.

**Severity:** Minor.

---

### N-05 — Methodology page `h2` sections have no `id` attributes — no fragment navigation

**Location:** `site/src/app/methodology/page.tsx:88`, `156`, `232`, `256`

**Observation:**  
Four `<h2>` sections ("Reference machine", "Four non-negotiable commitments", "Additional best-practice items", "References") have no `id` attribute. `posts/[slug]/page.tsx` links to `/methodology` (no anchor). Any future post wanting to deep-link to a specific section (e.g., `/methodology#statistical-reporting`) cannot.

**Suggested fix:**  
Add `id` slugs to each `h2`.

**Severity:** Minor.

---

### N-06 — MDX component invocation convention is inconsistent across posts

**Location:** `site/src/posts/01-branch-prediction.mdx`, `02-false-sharing.mdx`, `03-simd-blackscholes.mdx`, `04-spsc-queue.mdx`

**Observation:**  
- Posts 01 and 02 call chart-specific server components directly: `<ThroughputBars>`, `<CounterOverlay>`, `<TimeVsN>`
- Post 03 uses `<ThroughputBars>` directly
- Post 04 uses only `<Benchmark chart="...">` for all chart embedding

`<Benchmark>` is the only component that supports `mode`, `offered_rate_hz`, `view`, and `markers` — the newer filtering props. Direct use of `<ThroughputBars>` without `mode` will silently include all mode-tagged runs if demo-4's JSON were accidentally used as the slug (see C-01 related root cause).

There is no documented convention for when to use `<Benchmark>` vs a direct chart component.

**Suggested fix:**  
Standardise on `<Benchmark chart="...">` as the single MDX API and deprecate direct chart component usage in MDX. Remove `ThroughputBars`, `CounterOverlay`, `TimeVsN` from the `components` map in `posts/[slug]/page.tsx` after migrating posts 01–03.

**Severity:** Minor (current posts work; risk is latent for future post authors).

---

### N-07 — `params` typed synchronously in `generateMetadata` and `PostPage`

**Location:** `site/src/app/posts/[slug]/page.tsx:24–39` and `41`

**Observation:**  
```ts
export async function generateMetadata({ params }: { params: { slug: string } })
```
In Next.js 15, `params` is a `Promise<{ slug: string }>` and must be awaited. The current code is on Next.js 14.2.35 where this is synchronous, so it works today.

**Problem:** Forward-compatibility — the next major Next.js version upgrade will require updating this signature.

**Suggested fix:**  
No immediate action required; note for the Next.js 15 upgrade checklist.

**Severity:** Minor.

---

### N-08 — CSS custom properties (`--text-muted`, `--bg-card`, etc.) not registered as Tailwind `@theme` tokens — requires inline styles throughout

**Location:** `site/src/app/globals.css:33–43` (`:root` block), every component

**Observation:**  
The `@theme {}` block registers `--color-accent-*` and `--color-surface-*` as Tailwind tokens (usable as `text-accent-500`). The dark-mode semantic aliases (`--text-primary`, `--bg-card`, `--cyan`, etc.) are defined only in `:root` and not in `@theme {}`. This means no Tailwind utility exists for them; every component must use `style={{ color: 'var(--text-muted)' }}` inline.

**Problem:** Tailwind utilities and inline styles are mixed throughout. Dark/light theming is handled by CSS-var override rather than Tailwind's native dark-mode utilities.

**Suggested fix:**  
Add semantic colour aliases to `@theme {}`:
```css
@theme {
  --color-text-primary: var(--text-primary);
  --color-text-muted: var(--text-muted);
  --color-bg-card: var(--bg-card);
  --color-cyan: var(--cyan);
}
```
Then `className="text-text-muted"` works and inline styles can be removed.

**Severity:** Minor — stylistic consistency; no functional impact.

---

## Not-a-finding — passing checks (explicit confirmation)

- **Static export integrity:** `output: 'export'` confirmed in `next.config.mjs`. `generateStaticParams` correctly implemented in `posts/[slug]/page.tsx`. No API routes, server actions, or ISR patterns found. ✓
- **Tailwind v4:** `postcss.config.mjs` uses `@tailwindcss/postcss`. `globals.css` uses `@import "tailwindcss"` and `@theme {}`. No `tailwind.config.ts` (correct for v4). No residual `@layer utilities` or v3 `theme.extend` patterns found. ✓
- **Shiki integration (BRIEF.md open item resolved):** Shiki is vendored (`package.json: "shiki": "^1.29.2"`), not CDN. `next.config.mjs` enables `asyncWebAssembly: true` for WASM. `CodeCompare.tsx` is a server component; client-side scroll sync is correctly split into `CodeComparePanels.tsx`. ✓
- **MDX frontmatter consistency:** All four posts use `title`, `date`, `summary` in that order. No extra or missing keys. ✓
- **MDX heading levels:** All four posts use `##` for all body sections; no `#` in MDX body (post title rendered by `PostPage`). ✓
- **No `console.log` in production paths:** None found across all source files. ✓
- **No unused `package.json` dependencies:** All five production dependencies (`next`, `react`, `next-mdx-remote`, `gray-matter`, `shiki`, `rehype-pretty-code`, `d3`) are actively used. ✓
- **Font preloading:** `next/font/google` in `layout.tsx` for Inter, Space Grotesk, and JetBrains Mono. Next.js automatically preloads these. No FOUT risk. ✓
- **ARIA on interactive elements:** Theme toggle (`aria-label="Toggle theme"`) and hamburger (`aria-label="Toggle menu"`, `aria-expanded`) in `TopNav.tsx` are correct. ✓
- **`CodeCompare` `labels` prop:** All four posts that use `<CodeCompare>` supply the `labels` prop with two strings. The default `['Naive', 'Optimised']` is not relied on in any shipped post. ✓
- **Data-loading pattern (clean path note):** When used through `Benchmark.tsx`, the data-loading pattern is well-structured — one `readFile`, one `filterRuns`, one type-cast to the appropriate chart's run type. The parallel `readFile` calls in `CodeCompare.tsx` (for the two Shiki renders) are correct. The direct server components (`ThroughputBars`, `TimeVsN`, `CounterOverlay`) each load their own data; this is an acceptable split given their current usage pattern in posts 01–03.
