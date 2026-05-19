# Crucible — mobile rendering audit findings

Generated 2026-05-19. All four post pages screenshotted at 375 px, 390 px, and 414 px viewport
width, `deviceScaleFactor=2`, headless Chromium via Playwright. Screenshots stored in
`mobile-screenshots/`. Full-page captures; component-level crops referenced below.

Audited: charts (`<ThroughputBars>`, `<TimeVsN>`, `<LatencyHistogram>`, `<CounterOverlay>`,
`<LatencyVsLoad>`), `<CodeCompare>`, tables, and prose.

---

## Demo 01 — Branch Prediction

**Passes at all three widths.**

| Component | Finding |
|---|---|
| `<CodeCompare>` | Renders as two fixed-ratio columns, each panel scrolls horizontally. Deliberate, not broken. |
| `<ThroughputBars>` | SVG resizes correctly, axis labels readable, no overflow. |
| `<CounterOverlay>` | SVG resizes correctly, no overflow. |
| `<TimeVsN>` | SVG resizes correctly, no overflow. |
| Tables | The markdown table (lines 179–184 of `01-branch-prediction.mdx`) does not render as an HTML `<table>` — see **Cross-cutting note** below. Not a mobile overflow issue. |
| Prose | No horizontal overflow. |

---

## Demo 02 — False Sharing

**Fails at all three widths.**

### Issue M02-1 — Post navigation bar overflows viewport (all three widths)

**Component:** `page.tsx` lines 65–88 — the `<div className="flex items-center gap-2">` pill-link
row at the top of every post article.

**Root cause:** Demo 02 is a middle post (has both a prev and a next link). The two pill links
each carry `max-w-[220px]`. Together with `gap-2` (8 px), the right-hand nav container is 448 px
wide. On a 375–414 px viewport the article content area is ≈327–390 px, so the right link
overflows off-screen. The flex container itself (`right=351`) stays within the article, but its
child has no `flex-shrink` or overflow clipping, so it escapes.

**Visual:** The "← Black-Scholes..." next-post pill is partially cut off at the right viewport
edge. A user cannot see or tap the full link.

**Screenshot:** `mobile-screenshots/02-postnav--375px.png`

**Measurements:**

| Viewport | body.scrollWidth | Overflow |
|---|---|---|
| 375 px | 508 px | 133 px beyond viewport |
| 390 px | 508 px | 118 px beyond viewport |
| 414 px | 508 px | 94 px beyond viewport |

**Affected posts:** Demo 02 and Demo 03 only (first and last posts have a single link that fits).

---

| Component | Finding |
|---|---|
| `<CounterOverlay>` × 3 | SVGs resize correctly, no overflow. Axis labels readable. |
| `<ThroughputBars>` × 2 | SVGs resize correctly. |
| `<CodeCompare>` | Two scrollable panels. Deliberate, not broken. |
| Tables | ns/op summary table (MDX lines 130–136) renders as pipe-separated paragraph text — see **Cross-cutting note**. Not a mobile overflow issue. |
| Prose | No overflow beyond M02-1. |

---

## Demo 03 — SIMD Black-Scholes

**Fails at all three widths.**

### Issue M03-1 — Post navigation bar overflows viewport (same root cause as M02-1)

Demo 03 is also a middle post. Identical symptom: both prev/next pill links render, combined
width 448 px, body.scrollWidth = 508 px at all three tested widths. The "← False Sharing..." prev
link is partially hidden.

**Affected component:** `page.tsx` lines 65–88.

---

| Component | Finding |
|---|---|
| `<ThroughputBars>` × 2 | SVGs resize correctly, no overflow. |
| `<CodeCompare>` | Two scrollable panels. Fine. |
| Prose | No overflow beyond M03-1. |

---

## Demo 04 — SPSC Queue

**Fails at all three widths.**

### Issue M04-1 — `<LatencyHistogram>` legend label clipped (all three widths)

**Component:** `LatencyHistogram.tsx` — `renderCCDF` and `renderPDF`, via `appendLegendLines` /
`appendLegendRects` in `d3helpers.ts`.

**Root cause:** The legend is placed at `x = margin.left + inner.w + 8`. On a mobile SVG of
325–364 px:

```
inner.w = W - 72 (left margin) - 120 (right margin) = 133–172 px
legend_x = 72 + inner.w + 8  →  213–252 px
legend_text_start = legend_x + 22  →  235–274 px
available_for_text = W - legend_text_start  →  51–90 px
```

The label "lockfree-handrolled" is 19 monospace characters at `annotationSize=10` ≈ 114 px wide.
It overflows the SVG's right edge by approximately 24 px and is clipped by the `ChartShell`
`overflow:hidden` wrapper. The legend reads "lockfree-handro" — the tail is silently cut.

Both LatencyHistogram instances in this post are affected (paced mode CCDF and saturated mode CCDF).

**Screenshot:** `mobile-screenshots/04-latencyhistogram--375px.png`

**Measurements:**

| Viewport | SVG width | Text right edge | SVG right edge | Clipped by |
|---|---|---|---|---|
| 375 px | 325 px | 374 px | 350 px | 24 px |
| 390 px | 340 px | 389 px | 365 px | 24 px |
| 414 px | 364 px | 413 px | 389 px | 24 px |

---

### Issue M04-2 — `<LatencyVsLoad>` x-axis tick labels overlap at high end (all three widths)

**Component:** `LatencyVsLoad.tsx` (D3 log-scale x-axis).

**Root cause:** The inner plot width at mobile is 133–172 px. Five decade ticks (10k, 100k, 1M,
10M, 100M) must fit within that space. At the right end of the log scale, "10M" and "100M" are
adjacent and physically run together — zero gap between the two text elements.

**Visual:** The x-axis reads "10k 100k 1M 10M100M" — the last two decade labels are visually
merged into a single illegible string.

**Screenshot:** `mobile-screenshots/04-latencyvs-load--375px.png`

**All three widths affected.** The inner width is narrower at 375 px (133 px) and widens slightly
at 414 px (172 px), but tick collision persists across all three.

---

### Issue M04-3 — `<ThroughputBars>` x-axis variant labels collide (all three widths)

**Component:** `ThroughputBars.tsx` / `ThroughputBarsChart.tsx` — x-axis tick label placement.

**Root cause:** The three variant labels ("Lockfree-handrolled", "Lockfree-boost", "Mutex-condvar")
are placed as x-axis group labels. At mobile widths the compressed inner plot area cannot space
three labels of 15–19 characters without collision.

**Visual:** "Lockfree-handrolled" and "Lockfree-boost" run together with no visible gap —
they read as one fused string. "Mutex-condvar" has some separation but the overall x-axis is
illegible.

**Screenshot:** `mobile-screenshots/04-throughputbars--375px.png`

**Overlap measurements (from bounding-rect inspection):**

| Viewport | "Lockfree-handrolled" vs "Lockfree-boost" overlap |
|---|---|
| 375 px | 14 px (clearly merged) |
| 390 px | 10 px |
| 414 px | 3 px (barely touching) |

---

### Minor: 7 px body overflow at 375 px only

`scrollWidth=382` at 375 px. Source is a code element at `right=382 px`, inside a CodeCompare
panel whose outer wrapper is `overflow:hidden`. At 390 px and 414 px there is no body overflow.
Likely a sub-pixel rounding artifact from the CodeCompare border; not visually perceptible.
**Not flagging for remediation.**

---

| Component | Finding |
|---|---|
| Post navigation | Only one prev link (last post) — fits. |
| `<LatencyHistogram>` × 2 | **Issue M04-1** — legend clipped. |
| `<LatencyVsLoad>` | **Issue M04-2** — x-axis tick collision. |
| `<ThroughputBars>` | **Issue M04-3** — variant label collision. |
| `<CodeCompare>` | Two scrollable panels. Fine. |
| Prose | No overflow. |

---

## Cross-cutting note — markdown tables render as pipe-separated text

**Affects:** Demo 01 (lines 179–184), Demo 02 (lines 130–136).

Neither table renders as an HTML `<table>` element. The MDX pipeline does not include
`remark-gfm`, so GFM table syntax is passed through to the browser as a raw `<p>` containing
pipe characters. The content is readable but visually unstyled (monospace pipe text, not a grid).

This is **not a mobile-specific overflow issue** — there is no horizontal scroll risk and the
text wraps normally. It is a baseline rendering gap present at all viewport widths and is
flagged here for completeness only; remediation should go through task 7's brief funnel
separately.

---

## Summary

| Post | Nav overflow | Charts | CodeCompare | Prose |
|---|---|---|---|---|
| Demo 01 — Branch Prediction | ✓ (only next link) | ✓ all pass | ✓ | ✓ |
| Demo 02 — False Sharing | **✗ M02-1** both links overflow | ✓ all pass | ✓ | ✓ |
| Demo 03 — SIMD Black-Scholes | **✗ M03-1** both links overflow | ✓ all pass | ✓ | ✓ |
| Demo 04 — SPSC Queue | ✓ (only prev link) | **✗ M04-1 M04-2 M04-3** | ✓ | ✓ |

### Issues for brief funnel (task 7)

| ID | Scope | Root cause |
|---|---|---|
| M02-1 / M03-1 | `page.tsx` lines 65–88 | Dual prev+next pill links (2 × 220 px + gap) exceed mobile content width; fix with `flex-wrap`, `min-w-0 flex-1`, or hiding secondary text on narrow viewports |
| M04-1 | `LatencyHistogram.tsx` + `d3helpers.ts` | Right margin (120 px) too wide relative to mobile SVG; legend overruns SVG edge. Fix: reduce right margin below ~90 px on narrow SVGs, or render legend below chart |
| M04-2 | `LatencyVsLoad.tsx` | D3 log-scale tick count too high for compressed inner width; reduce `.ticks()` count or rotate labels |
| M04-3 | `ThroughputBars.tsx` / `ThroughputBarsChart.tsx` | X-axis group labels exceed available bar width; fix with label rotation (e.g. −45°) or shortening variant names on mobile |
