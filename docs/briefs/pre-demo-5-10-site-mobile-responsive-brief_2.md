# Crucible — site mobile responsive brief

**Pre-demo-5 brief 10. The mobile-rendering findings from task 10, packaged into one responsive pass across `page.tsx` and the three demo-04 charts.**

---

## 1. Context

The mobile rendering audit (task 10, see `pre-demo-5-mobile-findings.md`) found four issues breaking the post pages at 375–414 px viewport widths. All four are addressed here in one brief because they share the responsive-behaviour theme and fit a coordinated diff:

- **M02-1 / M03-1** — Post-navigation pill links overflow the viewport on middle posts (demos 2, 3). Two `max-w-[220px]` siblings + `gap-2` measure ~448 px, inside a ≈327–390 px content area. The right-hand link is clipped by the viewport edge; a user cannot read or tap it.
- **M04-1** — `LatencyHistogram` legend text overflows the SVG's right edge by ~24 px on mobile. The 120 px right margin reserved for legend text leaves only 51–90 px for the actual labels, while "lockfree-handrolled" needs ~114 px. The label silently truncates to "lockfree-handro" under the `ChartShell` `overflow:hidden` wrapper.
- **M04-2** — `LatencyVsLoad` x-axis log-scale tick labels collide. Five decade labels (10k, 100k, 1M, 10M, 100M) cannot fit into the 133–172 px inner plot width; "10M" and "100M" visually merge into one string. **This also folds in the Lighthouse post-04 DOM-size finding** — reducing tick and grid-line counts drops both the visual collision and the SVG DOM size penalty (post 04 currently has 1,205 elements; D3 grid lines and axis ticks dominate the depth-12 and width-120 chains reported by Lighthouse).
- **M04-3** — `ThroughputBars` x-axis variant labels collide on mobile. "Lockfree-handrolled" and "Lockfree-boost" overlap by 14 px at 375 px, fusing into a single illegible string.

**Dependencies:** Brief 07 (chart refactor — `ChartShell`, `d3helpers.ts`) lands first. This brief's chart-side work uses the helpers established there. Brief 06 (theme reading) is a transitive dependency through brief 07.

---

## 2. Goals

- Both prev and next post-navigation links are fully visible and tappable on viewports ≥375 px.
- Every chart's labels, legends, and axis ticks render fully within the SVG bounds at viewport widths 375–414 px, with no truncation or overlap.
- Post 04's `LatencyVsLoad` chart reduces DOM size enough to meaningfully shift the Lighthouse DOM-size diagnostic (target: drop the page total from 1,205 to <1,000 elements).
- No regression at desktop widths (≥640 px); existing layouts preserved.

---

## 3. M02-1 / M03-1 — Post-nav overflow

**File:** `site/src/app/posts/[slug]/page.tsx` lines 65–88 (the prev/next pill-link container).

The current container is a horizontal flex row with two children, each `max-w-[220px]`:

```tsx
<div className="flex items-center gap-2">
  {prevSlug && <Link className="... max-w-[220px]" ...>← {prevTitle}</Link>}
  {nextSlug && <Link className="... max-w-[220px]" ...>{nextTitle} →</Link>}
</div>
```

Two siblings + `gap-2` = 448 px minimum. Article content area is 327–390 px on the tested mobile widths. Fix: allow wrapping and let each link shrink to fit on narrow viewports, restore desktop sizing at `sm:` breakpoint.

```tsx
<div className="flex flex-wrap items-center gap-2">
  {prevSlug && (
    <Link className="... min-w-0 flex-1 sm:flex-initial sm:max-w-[220px]" ...>
      ← {prevTitle}
    </Link>
  )}
  {nextSlug && (
    <Link className="... min-w-0 flex-1 sm:flex-initial sm:max-w-[220px]" ...>
      {nextTitle} →
    </Link>
  )}
</div>
```

- `flex-wrap` lets the second link drop to a new line if both can't fit on one.
- `min-w-0 flex-1` on each child allows them to shrink below their content's natural width. Tailwind's `min-w-0` defeats the default `min-width: auto` on flex items, which is what currently prevents shrinking. `flex-1` gives each link an equal share of the available row width.
- `sm:flex-initial sm:max-w-[220px]` restores the desktop sizing at ≥640 px.

Preserve any existing classes for padding, border, hover state, and text truncation. The current pill styling uses `truncate` — keep it, since shorter post titles still want ellipsis when squeezed.

Manual verification: load demos 2 and 3 at 375, 390, 414 px viewport widths. Both nav links should be fully visible (either side-by-side on a single row with ellipsis, or stacked into two rows; either is acceptable).

---

## 4. M04-1 — `LatencyHistogram` legend below chart on narrow widths

**File:** `site/src/components/charts/LatencyHistogram.tsx`.

The chart reserves a 120 px right margin for the legend (`margin.right = 120` in both `renderCCDF` and `renderPDF`). On mobile this consumes most of the SVG width and the legend text still overruns. Fix: at narrow widths, drop the right margin to a minimum and render the legend stacked below the chart instead.

### 4.1 Width-aware margin

The chart already reads `clientWidth` at render time. Branch the margin definition on the measured width:

```ts
const isNarrow = width < tokens.chart.mobileBreakpoint; // see §7 for the constant

const margin = isNarrow
  ? { top: 16, right: 16, bottom: 80, left: 56 } // legend goes in expanded bottom margin
  : { top: 16, right: 120, bottom: 40, left: 56 }; // legend goes in right margin (existing)
```

The narrow-mode `bottom: 80` reserves room for ~3 stacked legend lines beneath the axis. If a particular renderer (CCDF vs PDF) has a different legend item count, tune the value per call site — the exact number is whatever fits the actual item count plus the axis label.

### 4.2 Legend position branch

The chart calls `appendLegendLines` (or `appendLegendRects`) from `d3helpers.ts` at `(margin.left + inner.w + 8, margin.top)`. Branch the position so the legend lives below the chart on narrow widths:

```ts
const legendX = isNarrow ? margin.left : margin.left + inner.w + 8;
const legendY = isNarrow ? margin.top + inner.h + 36 : margin.top;
//                                              ^ gap below x-axis label

appendLegendLines(g, items, { x: legendX, y: legendY }, colors);
```

Vertical stacking is preserved in both modes — only the position changes. The existing `d3helpers.ts` signature from brief 07 supports this without modification. No helper change required.

### 4.3 Both CCDF and PDF renderers

Apply the same branching to `renderCCDF` and `renderPDF`. Two `LatencyHistogram` instances render on demo 04's post page (paced-mode CCDF, saturated-mode CCDF); both inherit the fix.

Manual verification: at 375 px viewport, all legend labels including "lockfree-handrolled" are visible in full beneath the histogram. At ≥640 px viewport, the legend renders to the right of the chart as before (no regression).

---

## 5. M04-2 — `LatencyVsLoad` tick density

**File:** `site/src/components/charts/LatencyVsLoad.tsx`.

Two changes — reduce x-axis tick count, and reduce grid-line density. Also apply the §4 width-aware margin/legend pattern if this chart's legend suffers similar cramping; verify first, since the legend item count and label width here may differ. If the legend fits acceptably at all tested widths, skip the §4 work for this file.

### 5.1 Reduce x-axis tick count

D3's default `.ticks()` on a log scale generates a tick per decade plus minor sub-decade ticks. The current chart renders five major ticks (10k, 100k, 1M, 10M, 100M). Five into 133–172 px inner width is too many. Reduce to four by explicitly listing tick values, skipping 10M:

```ts
const xAxis = axisBottom(x)
  .tickValues([1e4, 1e5, 1e6, 1e8])
  .tickFormat((d) => formatSI(d));
```

This drops "10M" and leaves a visible gap between "1M" and "100M". Verify the underlying data range still spans these decades; if the chart's actual data ends at 10M (not 100M), drop "100M" instead and keep "10M".

If the data range varies per dataset and explicit tick values are too brittle, the alternative is `.ticks(4)` and accept whatever decade D3 picks. Prefer explicit `tickValues` for the deterministic visual.

### 5.2 Reduce grid-line density

The grid lines are emitted by `appendGrid` from `d3helpers.ts` (brief 07). The helper uses `y.ticks()` and (when both axes are passed) `x.ticks()` to determine line counts.

The cleanest fix is at the scale level: reduce the count `.ticks(n)` returns on the scales passed in. D3 axes inherit tick counts from the scale's `.ticks()` method, and brief 07's `appendGrid` reads the same. Reducing tick count at the scale propagates to both axis labels and grid lines without helper changes.

```ts
// Before passing scales to axes and appendGrid, dial down counts:
const yTickCount = isNarrow ? 4 : 8;
const xTickCount = isNarrow ? 4 : 6;
// y is a linear scale here; for axes consuming these scales, .ticks(n) suffices
```

Expected DOM impact: the LatencyVsLoad SVG currently emits ~10 horizontal grid lines and ~5 vertical decades plus minor ticks. Reducing to ~4 horizontal and 4 vertical drops the grid line count from ~50 to ~16 elements, plus eliminated minor-tick text nodes. Combined with §5.1, expect a 30–40% DOM reduction on this SVG — enough to push the post-04 page below the Lighthouse 1,000-element threshold.

Manual verification: at 375 px viewport, x-axis labels have visible gaps between them; "1M" and "100M" do not touch. Lighthouse re-run on demo 04 reports DOM size <1,000 elements.

---

## 6. M04-3 — `ThroughputBars` variant labels

**File:** `site/src/components/charts/ThroughputBarsChart.tsx` (verify against `ThroughputBars.tsx`; whichever holds the x-axis tick-label rendering).

The x-axis under a band scale renders one tick label per band. With three bands and ~110–160 px of inner width at mobile, each band gets ~37–53 px — narrower than the "Lockfree-handrolled" label width. Fix: rotate labels at narrow widths.

### 6.1 Width-aware label rotation

```ts
const isNarrow = width < tokens.chart.mobileBreakpoint;

g.append("g")
  .attr("transform", `translate(0, ${inner.h})`)
  .call(axisBottom(x))
  .selectAll("text")
  .style("text-anchor", isNarrow ? "end" : "middle")
  .attr("transform", isNarrow ? "rotate(-30) translate(-6, 0)" : null)
  .attr("dy", isNarrow ? "0.3em" : null);
```

`-30°` is enough to clear the 14 px overlap measured at 375 px without making labels hard to read. `text-anchor: end` aligns the rotated label so its right edge sits under the band centre. `dy` offset nudges the rotated baseline so the text doesn't clip the axis line.

### 6.2 Bottom margin adjustment

Rotated labels need more vertical space. Expand `margin.bottom` at narrow widths:

```ts
const margin = {
  top: 16,
  right: 16,
  bottom: isNarrow ? 60 : 40,
  left: 56,
};
```

Manual verification: at 375, 390, 414 px viewport, all three variant labels are visible, rotated, and readable. Labels do not overlap each other or the axis line. At ≥640 px viewport, labels render horizontally with no regression.

---

## 7. Shared mobile-breakpoint constant

The `mobileBreakpoint = 480` threshold appears in three chart files (LatencyHistogram, LatencyVsLoad, ThroughputBarsChart). Extract to a shared location to avoid drift.

**File:** `site/src/lib/design-tokens.ts` — add to `tokens.chart`:

```ts
chart: {
  // … existing
  mobileBreakpoint: 480,  // SVG width threshold for narrow-layout adjustments
}
```

Export via `theme.ts` and import where needed. Single source of truth for "narrow" across charts; future charts inherit the convention.

Note for brief 09 compatibility: if brief 09 §3.1 (N-01, chart font-size tokens — `annotationSize`, `captionSize`) has already added other entries to `tokens.chart`, this brief slots `mobileBreakpoint` alongside them. If brief 09 has not yet landed, both this brief and brief 09 add fields to the same object — CC should sequence their edits to avoid conflicts.

---

## 8. Out of scope

- The `remark-gfm` table-rendering gap (cross-cutting MDX pipeline) — folded into brief 09 §3.10.
- The Lighthouse Umami preconnect and legacy-JS polyfill items — also brief 09 (§3.8, §3.9).
- The Lighthouse D3 wildcard imports (M-02) — brief 08.
- The sub-pixel 7 px body overflow on demo 04 at 375 px only — `pre-demo-5-mobile-findings.md` explicitly flagged not for remediation (sub-pixel rounding artifact, not visually perceptible).
- Responsive behaviour of `<CodeCompare>` — passes the audit at all three widths (deliberate horizontal-scroll panels).
- Markdown tables rendering as pipe-separated text — also brief 09 §3.10 (root-caused to missing `remark-gfm`, not mobile-specific).

---

## 9. Acceptance checklist

### Post-nav

- [ ] **M02-1 / M03-1**: Demo 2 and demo 3 pages at 375, 390, 414 px viewport widths show both prev and next links fully visible (no clipping by viewport edge).
- [ ] At ≥640 px viewport, post-nav renders side-by-side with the original `max-w-[220px]` sizing — no desktop regression.
- [ ] Demo 1 (only next link) and demo 4 (only prev link) still render correctly at all tested widths.

### LatencyHistogram

- [ ] **M04-1**: At <480 px SVG width, legend renders below the chart with all labels (including "lockfree-handrolled") visible in full.
- [ ] At ≥480 px SVG width, legend renders to the right of the chart as before.
- [ ] Both CCDF and PDF renderers behave identically; both `LatencyHistogram` instances on demo 04 inherit the fix.

### LatencyVsLoad

- [ ] **M04-2**: At 375 px viewport, x-axis labels have visible gaps; "1M" and "100M" (or whichever decades remain) do not touch.
- [ ] Grid-line and tick density reduced; Lighthouse on demo 04 reports DOM size <1,000 elements.
- [ ] If §4 pattern applied here, legend behaviour matches LatencyHistogram acceptance. Otherwise, legend renders without regression at any width.

### ThroughputBars

- [ ] **M04-3**: At 375, 390, 414 px viewport, all three variant labels are visible, rotated, and non-overlapping.
- [ ] At ≥640 px viewport, labels render horizontally with no regression.

### Shared

- [ ] `tokens.chart.mobileBreakpoint` defined in `design-tokens.ts`; all three chart files import the value (no in-file literal `480` remains).
- [ ] All four shipped post pages render correctly at desktop widths (regression check vs pre-fix state — `npm run build` followed by visual diff).
- [ ] `npm run build` succeeds; static export clean.
- [ ] Lighthouse on demos 2, 3, 4 shows no Performance score regression vs the brief 08 results (post-04 should improve from DOM-size reduction).

---

## 10. Open items for CC to flag

- If during implementation the LatencyVsLoad legend turns out to need the §4 below-chart pattern, factor the width-aware legend logic out into a small helper rather than duplicating between LatencyHistogram and LatencyVsLoad. The helper signature could be: `legendPlacement(width, margin, inner) → { x, y }`.
- If `tokens.chart.mobileBreakpoint = 480` proves wrong (charts still cramped above it, or unnecessarily switching modes below it), tune the value once in `design-tokens.ts` rather than per chart.
- If post-04 DOM size doesn't drop below 1,000 after §5 changes, report back rather than chasing further D3-side reductions in this brief — the gap may indicate other DOM sources (e.g. `<CodeCompare>` Shiki output, or the post body itself) that warrant their own follow-up.
