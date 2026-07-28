# Crucible — demo 10 §5 chart scope: `<LatencyMatrix>` (CCX heatmap)

Opus scope → CC to implement, on `feat/demo-10-core-to-core`. This is the §5 deliverable: the D3 component that renders the core-to-core RTT matrix as a heatmap with the CCX seam legible at a glance. The data contract is the `latency_matrix` block in `site/src/data/perf/10-core-to-core.json` (locked, two corroborated captures committed). This scope has no hardware dependency.

**Build on the existing chart stack — do not introduce a new D3 import or a bespoke SVG scaffold.** The house pattern (confirmed in `ThroughputBarsChart.tsx`, `LatencyHistogram.tsx`, `QuantumProbChartClient.tsx`) is: named `d3-*` sub-package imports (never `import * as d3`), `useChartEffect` for the render effect, `setupSVG` + `appendXAxis`/`appendYAxis` + `getColors()` (CSS vars read at draw time — dark-only) from `d3helpers.ts`, `typography`/palette from `theme.ts`, wrapped in `ChartShell` (title, `role="img"`, aria-label) inside `ChartZoom`. A heatmap is a new *shape*, but it uses these same primitives.

## Context — what the data is, and the two honesty constraints it forces

The matrix is 28 unordered pairs over 8 cores, plus per-core baselines and CCX labels. Cross-CCX cells sit ~160 ns, intra-CCX ~72 ns, a clean 2.24× seam with an ~85 ns gap and zero overlap. Two things the capture data makes non-negotiable for how this renders:

1. **Intra cells are quantized, not continuous.** Per-placement medians land on a discrete ~5-rung ladder (70.85 / 71.11 / 72.11 / 73.16 / 73.42 ns — roughly 1–4 cycles apart at 0.2564 ns/cycle). So unrelated intra pairs report byte-identical values, and a 70.86-vs-73.42 difference between two intra cells is **measurement quantization, not topology**. The chart must not invite a reader to compare one intra cell against another. All intra is "≈72 ns at the resolution floor."
2. **Cross cells carry a real ~3–5 ns slice-placement wobble** (the across-frame IQR), which *is* physical but is second-order to the seam. Fine to show on hover; must not drive the colour scale hard enough to create spurious structure within the cross block.

The finding is the **seam** — two flat blocks a multiple apart — not the within-block texture. The visual encoding must make the seam the thing you see and must not manufacture within-block gradients that read as structure when they're quantization or slice noise. This is the whole design problem; everything below serves it.

## Tasks

### Task 1 — Component skeleton, house-conformant

Create `site/src/components/charts/LatencyMatrixChart.tsx` (client component), mirroring the structure of `LatencyHistogram.tsx`:

- Named `d3-*` imports only (`d3-scale`, `d3-selection` via `setupSVG`, `d3-axis` if needed). No `import * as d3`.
- `useChartEffect((el) => { … }, [deps])` for the render.
- `setupSVG(el, W, H, margin, title)` for the SVG + `colors` from `getColors()`.
- Return `<ChartZoom><ChartShell ref={ref} title={title} ariaLabel={title ?? 'Core-to-core latency matrix'} /></ChartZoom>`.
- Responsive width via `el.clientWidth`, `isNarrow` at `tokens.chart.mobileBreakpoint` (heatmaps are square-ish — see Task 4 for the mobile behaviour).

### Task 2 — Types and data loading

- Add the `latency_matrix` types to `@/lib/perf-types.ts` (house location for perf schema types): `LatencyMatrixCore`, `LatencyMatrixPair` (with the six-field-plus-`iqr` `rtt_ns` stats — reuse the existing stats type; note demo 10 has no `p99`, so the field is optional in the shared type or a matrix-specific stats type is fine), `LatencyMatrixBaseline`, and the block wrapper. Do not make `p99` required anywhere.
- **Mirror the 28 unordered pairs into the full 8×8.** The JSON stores each unordered pair once; the component builds `cell[a][b] = cell[b][a] = pair.rtt_ns`. The diagonal is not stored — render it per Task 3.
- Order rows/cols by CCX then core id: `0,1,2,3` then `4,5,6,7` (they already are, but sort explicitly so the CCX blocks are contiguous regardless of JSON order). Read CCX membership from the `cores` block, never infer from index.

### Task 3 — The heatmap render

- **Grid:** 8×8 `scaleBand` on both axes, square cells. Row and column tick labels are core ids; annotate each axis with its CCX grouping (a bracket or a subtle divider between core 3 and core 4 on both axes — see Task 5 for the seam line).
- **Diagonal (self-pairs):** not measured. Render as a visually distinct null (e.g. a neutral `colors.border`-toned cell with a small dash or "—"), never as 0 or baseline — a 0 would read as "instant" and distort the scale. Do not colour it on the RTT scale.
- **Colour scale — this is the load-bearing decision.** Use a **two-anchor sequential scale keyed to the two physical regimes, not a continuous min→max ramp.** A naive `scaleSequential([min,max])` would spend most of its dynamic range inside the meaningless intra quantization and the cross slice-wobble, manufacturing gradients that read as structure. Instead:
  - Anchor the scale so the intra block reads as one flat cool band and the cross block as one flat warm band, with the ramp between them placed across the empty ~73→~158 ns gap where no data lives.
  - Concretely: a sequential scale whose perceptual midpoint sits in the gap (~115 ns), so ~72 ns cells are uniformly at the cool end and ~160 ns cells uniformly at the warm end, and the ±3 ns within each block maps to a within-band colour delta small enough not to read as structure. `scaleSequential` with a clamped domain and a deliberately chosen interpolator, or a `scaleThreshold`/two-plateau scale, both work — pick whichever renders the two blocks flattest.
  - **Acceptance-testable intent:** a viewer sees two flat blocks and a seam. They do *not* see a gradient across the intra block or a gradient across the cross block.
- Palette from `theme.ts` (the dark-only CSS-var colours via `getColors()`); do not hardcode hex. Warm/cool must remain legible on the dark card background and distinguishable for common colour-vision deficiencies (avoid a pure red/green split — a blue→orange/yellow ramp is safer and matches the house palette better; confirm against `theme.ts`).

### Task 4 — Cell content and interaction

- **Cell label:** print the median ns in each cell, at `typography` caption size, colour chosen for contrast against the cell fill. Round to the display precision the other demos use (whole ns or one decimal — match the house convention; given quantization, whole ns is honest and less cluttered). If cells get too small at narrow widths to hold a label, drop the labels below `isNarrow` and rely on colour + hover.
- **Hover/tooltip:** on cell hover, show core pair, same/cross-CCX, median, and the across-placement IQR (`iqr_lo`–`iqr_hi`) and `max`. The `max` matters — it carries the rare slow-slice excursion the median hides, and the audience is tail-sensitive. Reuse the existing tooltip pattern if one exists in the chart stack; otherwise a minimal SVG-title or a positioned div consistent with `ChartShell`.
- **No per-cell precision theatre.** Do not render error bars per cell or decimals that imply sub-quantum resolution on intra cells. The tooltip carries the spread; the cell carries the rounded median.

### Task 5 — The seam, made explicit

- Draw a visible divider line between the CCX0 block (`0-3`) and the CCX1 block (`4-7`) on both axes — a 1px `colors.accent`/`cyan` rule at the core-3/core-4 boundary, horizontally and vertically, so the four quadrants (intra-CCX0, intra-CCX1, and the two cross blocks) are framed. This is the finding; make it structural in the image, not something the reader has to infer from colour alone.
- A short caption or annotation naming what the seam is (Infinity Fabric / IO-die crossing) is welcome but can also live in the MDX prose (§7) — keep the component's built-in text minimal; the post carries the narrative.

### Task 6 — `<Benchmark>` / MDX wiring

- Follow the existing `<Benchmark slug=… chart=… />` dispatch (see `Benchmark.tsx`): add a `latency-matrix` chart kind that loads `10-core-to-core.json` and renders `<LatencyMatrixChart>`. If the matrix doesn't fit the `<Benchmark>` variant/filter model cleanly (it has no `variants`/`threads`/`n` axis — it's a fixed 8×8), a direct `<LatencyMatrix slug="10-core-to-core" />` export is acceptable and arguably cleaner; match whatever demos 3–4 did for their bespoke charts. Flag which path you took.
- Wire the `<NoData />` fallback (the established pattern) for the case where the JSON lacks a `latency_matrix` block, so an accidental invocation on another demo's data degrades gracefully rather than throwing.

## Acceptance

- **Stack conformance:** `grep -c 'import \* as d3' site/src/components/charts/LatencyMatrixChart.tsx` → 0; the component imports `setupSVG`/axis helpers from `d3helpers` and `getColors`/`typography` from `theme`, and renders inside `ChartShell` + `ChartZoom` (grep each).
- **Types:** matrix types live in `@/lib/perf-types.ts`; `p99` is not required anywhere; build and `tsc --noEmit` clean.
- **Mirroring:** the 28 stored pairs render as a symmetric 8×8; `cell[a][b]===cell[b][a]`; diagonal rendered as null, not 0.
- **Seam legibility (the core one):** rendered against the committed JSON, the intra blocks read as one flat band and the cross blocks as another, with the CCX divider lines drawn — i.e. the seam is the salient feature and there is no spurious within-block gradient. (Manual visual check; call it out in the PR with a screenshot.)
- **CCX labels from data:** grouping is read from the `cores` block; swapping two cores' `ccx` in a local test JSON moves them in the render (proves it's not index-hardcoded).
- **Honesty:** no per-cell error bars; intra medians shown at whole-ns (or house) precision; hover exposes `iqr_lo`–`iqr_hi` and `max`.
- **Graceful degradation:** a JSON without `latency_matrix` yields `<NoData />`, not a throw; narrow-width render stays legible (labels drop, colour+hover carry it).
- **Theme:** no hardcoded hex; colours via `getColors()`; legible on the dark card and not reliant on a red/green distinction alone.

## Out of scope

- The MDX post body, the seam narrative prose, the reconciliation section, cross-links to demos 02/05 — §7.
- The slice-sweep and protocol exhibits' own charts, if any — decide in §7 whether they need bespoke visualisations or inline figures; not this component.
- The hostile cross-read — §8.
- Any change to the `latency_matrix` schema — it's locked and corroborated; the chart consumes it as-is.
- The owed `bench/scripts/` hardening brief and the `notes` "70-80 ns" fossil fix (that's a harness-side one-word edit, tracked separately).

## Open items for CC to flag

1. **Colour-scale mechanism** — report which construction you used (clamped `scaleSequential` with a gap-centred midpoint, two-plateau threshold, etc.) and confirm by eye that neither block shows an internal gradient. If the two-anchor approach fights the house palette, flag it rather than falling back to a naive min→max ramp.
2. **`<Benchmark>` fit** — report whether the matrix went through `<Benchmark>` or a direct `<LatencyMatrix>` export, and why.
3. **Tooltip pattern** — say whether you reused an existing chart tooltip or added one; if added, keep it consistent with the stack.
4. **Diagonal treatment** — confirm the diagonal is excluded from the colour domain (a self-pair rendered on the RTT scale would skew it).
5. **Narrow-width behaviour** — an 8×8 grid of labelled cells is tight on mobile; report what you did (drop labels, shrink, or scroll) and confirm the seam stays legible.

## After this lands

§7 is the MDX post: the seam narrative, the honesty framing this scope enforces (intra is "≈72 ns at the resolution floor," not a set of distinct per-pair numbers; the rare slow-slice excursion in `max`; exchange-vs-twoflag from the protocol exhibit; the dead CCX-asymmetry as a cautionary aside on how the single-frame artifact nearly became a finding), the FCLK/Matisse caveats, and the reconciliation section against demos 02/05 from the A5 inventory. Then §8 hostile cross-read, §9 pre-merge review, §10 merge. The chart is the last new component; after it, demo 10 is all prose and verification.
