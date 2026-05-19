# Crucible — Lighthouse audit findings

**Audit date:** 2026-05-19  
**Tool:** Lighthouse 12.8.2 via `npx lighthouse`  
**Preset:** Mobile (default — simulated mobile throttling, Moto G Power emulation)  
**Categories:** Performance, Accessibility, Best Practices, SEO  
**URLs audited:** `crucible.garethcooke.com/posts/01–04`

---

## Score table

| Page | Performance | Accessibility | Best Practices | SEO |
|------|:-----------:|:-------------:|:--------------:|:---:|
| 01-branch-prediction *(reference)* | **82** | 96 | 96 | 100 |
| 02-false-sharing | **84** | 96 | 96 | 100 |
| 03-simd-blackscholes | **89** | 96 | 96 | 100 |
| 04-spsc-queue | **86** | 96 | 96 | 100 |

Accessibility, Best Practices, and SEO are identical across all four pages and pass comfortably. Every performance score is sub-90.

---

## Performance diagnosis (all four pages — shared root cause)

### Common findings across all pages

All four posts fail Performance (82–89) for the same underlying reason: the LCP element on every post page is the `/iguana.svg` logo in the TopNav, and 86–87% of LCP time is classified as **Render Delay** — not Load Time. This means the SVG bytes arrive quickly (it is a tiny file served from the same origin), but the browser cannot commit the paint because the main thread is occupied evaluating JavaScript. The LCP breakdown is identical in structure across all four pages:

| LCP phase | Duration | % of LCP |
|-----------|----------|----------|
| TTFB | ~450–520 ms | 13–14% |
| Load Delay | 0 ms | 0% |
| Load Time | 0 ms | 0% |
| **Render Delay** | **~2,900–3,170 ms** | **86–87%** |

The render delay is caused by D3 initialisation blocking the main thread during React hydration. Every chart component begins with `import * as d3 from 'd3'`, which is a namespace import that disables tree-shaking; the full D3 v7 bundle is parsed and executed before any chart effect can run. This also inflates Total Blocking Time (TBT):

| Page | TBT | LCP |
|------|-----|-----|
| 01-branch-prediction | 180 ms | 3.7 s |
| 02-false-sharing | 160 ms | 3.6 s |
| 03-simd-blackscholes | **50 ms** | **3.3 s** |
| 04-spsc-queue | 160 ms | 3.5 s |

Post 03 scores best (89) because it renders a single `ThroughputBarsChart` — the lightest of the five chart components — giving it the lowest TBT and the shortest render delay. Posts 01 and 02 score worse (82, 84) because each page mounts two chart components (`ThroughputBars` + `CounterOverlay` / `BranchMissOverlay`), doubling the D3 initialisation work. Post 04 (86) also mounts two heavy charts (`LatencyHistogram` + `LatencyVsLoad`) and adds a DOM size penalty (see below).

Secondary firing audits, identical across all four pages:

| Audit | Detail | Wasted |
|-------|--------|--------|
| Render-blocking CSS | `_next/static/css/d0b6cc6297f37c4a.css` | ~170–240 ms |
| Legacy JavaScript | `chunks/117-97eb69f4c55816f2.js` | ~11 KB |
| Unused JavaScript | `chunks/fd9d1056-9b1ffcc4dc898c0e.js` | ~20 KB |
| Preconnect missing | `https://api-gateway.umami.dev` (Umami analytics) | ~300 ms est. |

CLS = 0 on all four pages (score: 1.0). The logo `<img>` carries `width="1500" height="1700"` intrinsic dimensions in the live HTML (the browser uses these to compute the aspect ratio and reserve space), so C-03's predicted CLS did not materialise. FCP is 1.7–1.8 s across all pages.

---

## Per-page diagnosis for sub-90 scores

### 01-branch-prediction — Performance 82

The heaviest of the four. TBT is 180 ms — the worst of the set — because the page mounts both `ThroughputBarsChart` (for the main throughput chart) and `BranchMissOverlayChart` (the counter overlay), triggering two full D3 initialisation cycles on page load. LCP render delay is 3,167 ms; the LCP element is the iguana.svg logo (`div.topnav-brand > a.topnav-logo > img`). The `fd9d1056-*.js` chunk carries 20 KB of unused code (unshaken D3 sub-modules), and `117-*.js` contains 11 KB of legacy polyfills. The single site-wide CSS file blocks rendering for 240 ms, the longest blocking time of any page.

**Fix:** Replace `import * as d3 from 'd3'` with named sub-package imports in all chart components (M-02 remediation) — this eliminates the unused 20 KB and reduces parse/eval time. Add `<link rel="preconnect" href="https://api-gateway.umami.dev">` in `layout.tsx`. The CSS blocking time is a Next.js build concern; the quickest win is the D3 tree-shaking change.

---

### 02-false-sharing — Performance 84

Nearly identical profile to post 01. TBT is 160 ms; the page mounts `ThroughputBarsChart` + `CounterOverlayChart` (false-sharing P&L overlay). Lighthouse additionally fires a "Forced reflow" diagnostic (not scored, but noted as a performance hint) — a JavaScript-triggered layout recalculation during D3's `getBoundingClientRect`-style measurement passes inside the resize observer or SVG sizing logic. LCP render delay is 3,104 ms; render-blocking CSS costs 242 ms.

**Fix:** Same as post 01 (D3 named imports + preconnect). Investigate the forced reflow: it likely comes from D3 reading `clientWidth` inside a `.call()` chain after writing to the DOM — restructure chart init to read dimensions before any DOM mutations (batch reads before writes).

---

### 03-simd-blackscholes — Performance 89

Closest to the ≥90 threshold; 1 point short. Only a single chart component (`ThroughputBarsChart`) mounts on this page, giving TBT of just 50 ms — well within the "good" range. The render delay (2,865 ms) is still present but shorter because D3 executes only once. Render-blocking CSS costs 179 ms. The legacy JS and unused JS audits fire but are in the "not scored" band at this page's performance level.

**Fix:** This page would likely clear 90 with D3 tree-shaking alone, since TBT=50 ms is already low; the remaining LCP delay would shrink significantly once the D3 bundle is trimmed.

---

### 04-spsc-queue — Performance 86

Two distinct issues beyond the shared root cause. TBT is 160 ms from two heavy charts (LatencyHistogram CCDF+PDF renderers and LatencyVsLoad sweep chart). Additionally, Lighthouse flags **DOM size = 1,205 elements** — the largest of any page. The deepest DOM path (depth 12) terminates at an SVG grid tick `<line>` element inside the LatencyVsLoad chart, and the widest parent has 120 child elements (a D3-generated axis group). Every grid line, axis tick, and data point D3 appends is a real DOM node; with 12 rate steps × multiple variants × histogram bins, the SVG DOM grows large. This adds parse and layout cost on top of the main-thread JS blocking.

**Fix:** D3 named imports (reduces the JS eval and TBT). For DOM size: reduce axis tick density in D3 (`.ticks(6)` instead of auto), and consider merging the CCDF and PDF renderers' legend/grid nodes so they are not duplicated across two SVG trees on the same page. The LatencyVsLoad sweep chart has 12 rate points × 3 variants = 36 data series paths; reducing grid-line count from D3's default (~10 per axis) to 5 would cut SVG DOM by ~30%.

---

## Reference comparison (post 01 vs posts 02/03/04)

Post 01 was the original acceptance-criterion holder for ≥90. It now scores 82 — 8 points below target. Posts 02–04 range from 84–89. Post 01's lower score relative to the others is explained by its two-chart layout producing the highest TBT (180 ms); it is not worse in any other metric dimension. The drift pattern across the four posts is purely a function of chart count and D3 complexity per page, not post-specific markup or content changes. The shared root cause (full D3 bundle, non-preconnected analytics, render-blocking CSS) means any fix applied at the component or layout level will lift all four scores simultaneously.

**Recommended fix priority order:**
1. D3 named sub-package imports (eliminates unused JS, reduces TBT and render delay on all pages — high leverage, one change affects all charts)
2. Preconnect to `api-gateway.umami.dev` in `layout.tsx` (300 ms saved, 2-line change)
3. Post 04 D3 tick density reduction (DOM size — page-specific, moderate effort)
4. Legacy JS polyfills (update `browserslist` / Next.js transpile target)
