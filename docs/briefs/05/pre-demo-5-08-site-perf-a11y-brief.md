# Crucible — site perf and a11y brief

**Pre-demo-5 brief 8 of 9. Lighthouse prep — these three findings feed task 9 (Lighthouse 2–4) directly.**

---

## 1. Context

Three site-review findings whose impact is measured by Lighthouse and assistive-tech testing rather than by visual inspection:

- **M-02** — D3 imported as `import * as d3 from 'd3'` in every chart. Every chart page bundles every D3 sub-module — selection, scale, axis, shape, array, force, geo, etc. The performance and accessibility audits about to run on demos 2–4 will read the JS payload size and the absence of accessible chart labels as failures.
- **M-11** — `<svg>` elements rendered by D3 have no `role`, `aria-label`, or `<title>` child. Screen readers encounter a generic SVG with no information. WCAG 2.1 Level AA failure (1.1.1 Non-text Content).
- **M-12** — All four series colours use 65% OKLCH lightness; only hue distinguishes them. The "sorted vs unsorted" comparison on demo 01 and the "padded vs unpadded" comparison on demo 02 (the headline visual claim of each post) use hues that are challenging for ~8% of male viewers.

**Dependencies:** Brief 7 lands first. `ChartShell` from brief 7 already adds `role="img"` and `aria-label` to the figure element; this brief adds the SVG `<title>` element inside the D3-painted SVG (a complementary fix, not a replacement). Brief 6 establishes the theme reader; this brief's palette change updates the constants the theme reader resolves.

---

## 2. Goals

- Each chart page's JS bundle includes only the D3 sub-modules that chart actually uses.
- Every chart SVG carries a `<title>` element as its first child, populated from the chart's `title` prop (or a sensible default).
- The four-series palette has a luminance gap of ≥2:1 between any two colours likely to appear in the same chart, in addition to hue differentiation. The "sorted vs unsorted" and "padded vs unpadded" pairs are visibly distinct under deuteranopia simulation.

---

## 3. M-02 — D3 tree-shake

### 3.1 Audit which D3 sub-modules each chart uses

Before changing imports, grep each chart file for D3 usage. Typical findings:

| API | sub-module |
|---|---|
| `d3.select`, `d3.selectAll` | `d3-selection` |
| `d3.scaleLinear`, `d3.scaleLog`, `d3.scaleBand` | `d3-scale` |
| `d3.axisBottom`, `d3.axisLeft` | `d3-axis` |
| `d3.line`, `d3.area`, `d3.curveMonotoneX` | `d3-shape` |
| `d3.group`, `d3.max`, `d3.extent` | `d3-array` |
| `d3.format` | `d3-format` |
| `d3.bisector` | `d3-array` |

For each chart and for `d3helpers.ts` (from brief 7), produce the exact list of named symbols used. The list will differ between charts — `ThroughputBarsChart` uses scaleBand and bars (no line/area); `LatencyHistogram` uses log scales and lines.

### 3.2 Replace the wildcard imports

In each chart file and in `d3helpers.ts`:

```ts
// BEFORE
import * as d3 from 'd3'

// AFTER (example for ThroughputBarsChart — adapt per file based on §3.1 audit)
import { select } from 'd3-selection'
import { scaleLinear, scaleBand } from 'd3-scale'
import { axisBottom, axisLeft } from 'd3-axis'
import { max } from 'd3-array'
import { format } from 'd3-format'
```

Then replace each `d3.foo` usage in the file with bare `foo`. The named imports give webpack the static information it needs to tree-shake unused sub-modules.

### 3.3 Verify the bundle change

Before-and-after measurement on a representative chart page (e.g., `/posts/04-spsc-queue`):

```bash
cd site
npm run build
# Inspect .next/static/chunks/ for the chart page's JS
du -h .next/static/chunks/*.js | sort -h
```

Document the bundle size delta in the PR description. Typical savings from this transformation are 100–300 KB per chart-bearing page.

A more diagnostic check: use `@next/bundle-analyzer` (or `webpack-bundle-analyzer` via a one-off config) to confirm `d3-force`, `d3-geo`, `d3-zoom`, and other unused modules no longer appear in the bundle.

### 3.4 package.json

Each `d3-*` sub-module needs to be a direct dependency rather than an implicit one through the `d3` umbrella. Add them:

```bash
npm install d3-selection d3-scale d3-axis d3-shape d3-array d3-format
# … any others surfaced by the §3.1 audit
```

The `d3` umbrella package can stay as a dependency or be removed. If removed: confirm no remaining import statements reference it. If kept (e.g., types convenience): document why.

---

## 4. M-11 — accessibility on chart SVGs

Brief 7's `ChartShell` already adds `role="img"` and `aria-label` to the outer `<figure>`. Two further steps complete the WCAG fix.

### 4.1 SVG `<title>` element

D3 paints into the `<svg>` element from inside each chart's render `useEffect`. Add a `<title>` child as the *first* element appended:

In each chart's render effect, immediately after `const svg = select(ref.current); svg.selectAll('*').remove();`:

```ts
svg.append('title').text(title ?? defaultTitleForThisChart)
```

Where `defaultTitleForThisChart` is a chart-type-specific fallback string defined as a constant near the top of the file:

```ts
const DEFAULT_TITLE = 'Throughput comparison bar chart'  // adapt per chart
```

Screen readers announce the `<title>` content when the SVG receives focus or is read in sequence. The `<title>` must be the first child of `<svg>` to be picked up by assistive tech reliably.

### 4.2 `<desc>` element (optional but recommended)

For charts that present numerical data, a `<desc>` element following the `<title>` can list key data points in plain text:

```ts
svg.append('desc').text(generateDescriptionFromData(runs))
```

Where `generateDescriptionFromData` produces something like `"Sorted: 0.74 ns/op. Unsorted: 3.83 ns/op. Branchless: 0.68 ns/op."` for a throughput chart, or analogous for each chart type.

This is a stretch goal — implement for at least one chart type as a template; expand to others if time permits. The minimum WCAG fix is the `<title>` element from §4.1.

### 4.3 Verification

Manual screen-reader test on a representative chart page using VoiceOver (macOS) or NVDA (Windows):

- The chart should be announced with its title when the reader reaches it.
- The chart should not be silently skipped.

Note this on the PR. *Requires runtime verification* — the code change alone doesn't prove screen-reader behaviour.

---

## 5. M-12 — palette luminance

### 5.1 Reframe the palette

Current state (`site/src/lib/design-tokens.ts:47–53`):

```
series[0]: oklch(65% 0.18 222)  // blue-cyan — used for sorted, padded
series[1]: oklch(65% 0.17 182)  // emerald — used for unsorted
series[2]: oklch(65% 0.17 320)  // rose
series[3]: oklch(65% 0.17 60)   // amber — used for branchless
```

The structural problem is uniform 65% lightness. Two colours of equal lightness are hard to distinguish without colour vision; under deuteranopia the hue 222 vs 182 pair collapses to a similar grey-green. Reframe: separate the primary comparison pair by lightness AND hue, not hue alone.

### 5.2 Suggested values

```
series[0]: oklch(72% 0.18 222)  // lighter blue-cyan
series[1]: oklch(52% 0.17 30)   // darker red-orange (replaces emerald)
series[2]: oklch(78% 0.15 95)   // light yellow-green
series[3]: oklch(60% 0.17 320)  // mid rose
```

The hue change on series[1] from 182 to 30 moves the primary "vs" pair from blue-cyan/emerald to blue-cyan/red-orange — the canonical Okabe-Ito high-contrast pair. The 20-percentage-point lightness gap between series[0] (72%) and series[1] (52%) provides discrimination independent of hue.

These specific values are a starting point. CC should:

1. Render the new palette in dark mode against `--bg-card`; check the chart panels visually.
2. Run the new palette through a deuteranopia simulator (Chrome DevTools Rendering panel → Emulate vision deficiencies → Deuteranopia). Confirm series[0] and series[1] remain distinguishable.
3. Adjust chroma if any colour washes out under simulation; preserve the lightness gap.

### 5.3 Light mode

Brief 6 keeps light mode supported. The palette values should be evaluated against `--bg-card`'s light-mode value too:

- Light-mode background: ~98% lightness (off-white).
- series[0] at 72% lightness: visible but lower-contrast than against a dark background.
- series[1] at 52% lightness: high contrast against light bg.

If contrast against light backgrounds is unacceptable, the cleanest fix is a light-mode palette override — i.e., `tokens.color.dark.palette` and `tokens.color.light.palette` as separate arrays, with `getColors()` selecting based on the active theme. This is a small extension of brief 6's `getColors()` and worth the explicit support given the decision to keep light mode.

### 5.4 Verification

Three checks before declaring done:

1. **Visual against dark bg**: open demo 01 and demo 02 in dark mode; the primary comparison pair should be obviously different colours.
2. **Deuteranopia simulation**: same pages with Chrome DevTools deuteranopia emulation on; pair remains distinguishable.
3. **Light mode**: same pages in light mode; pair remains distinguishable against light-bg.

*Requires runtime / simulation verification* — the colour codes alone don't prove the result.

---

## 6. Out of scope

- **Pattern fills for series** (stripes/dots in addition to colour). A possible further accessibility win, but visually disruptive on small charts. Defer.
- **High-contrast mode** (`prefers-contrast: more`). Out of scope; current palette plus the M-12 fix should satisfy default users.
- **Data table as text alternative for charts**. The `<title>` + `<desc>` from §4 gets to WCAG AA; a full data-table alternative would be AAA-level. Defer.
- **Replacing D3 with a lighter charting library** (uPlot, ObservablePlot, etc.). Out of scope — D3 with tree-shaking should hit the perf target.
- **`d3-shape` curve type changes** affecting visual appearance. Out of scope; tree-shaking does not change rendered output.

---

## 7. Acceptance checklist

### M-02

- [ ] Each chart file imports D3 sub-modules by name (`import { select } from 'd3-selection'`), not as a wildcard.
- [ ] `d3helpers.ts` (from brief 7) uses named D3 imports.
- [ ] All `d3-*` sub-modules used by the codebase are direct dependencies in `package.json`.
- [ ] Build succeeds; `npm run typecheck` passes.
- [ ] PR description includes before/after bundle size for at least one chart page (e.g., `/posts/04-spsc-queue`).

### M-11

- [ ] Every chart `useEffect` appends a `<title>` element as the first child of the SVG, populated from the `title` prop or a chart-type-specific default.
- [ ] `ChartShell` (from brief 7) carries `role="img"` and `aria-label`.
- [ ] Manual screen-reader test documented in PR (which tool used, what was announced for one chart).
- [ ] At least one chart additionally has a `<desc>` element with numerical data (stretch).

### M-12

- [ ] `design-tokens.ts` palette series have a lightness gap of ≥20 percentage points between series[0] and series[1].
- [ ] Chrome DevTools deuteranopia simulation: series[0] and series[1] remain visually distinguishable.
- [ ] Demo 01 and demo 02 pages render with the new palette and look correct in both themes.
- [ ] (Optional) `tokens.color.light.palette` exists if light-mode contrast required separate values; `getColors()` resolves correctly.

### Lighthouse (feeds task 9)

- [ ] Lighthouse run on `/posts/01-branch-prediction`: Performance ≥ 90, Accessibility ≥ 95.
- [ ] Same for `/posts/02-false-sharing`.
- [ ] Same for `/posts/03-simd-blackscholes`.
- [ ] Same for `/posts/04-spsc-queue`.
- [ ] No "uses ARIA correctly" failures.
- [ ] No "image elements have alt attributes" failures (logo from brief 5 carries width/height; SVG charts now have title/role).
