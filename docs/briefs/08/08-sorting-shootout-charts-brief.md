# Crucible — Demo 08 Task 5: chart-component check

Implementation brief for Claude Code. Lands on the demo 8 feature branch (`demo-8-sorting-shootout` or equivalent). Implements §5 of `demo-08-plan.md` — the CC-apply half of a task scoped "Opus scope, CC apply." The chart decisions below are settled; this brief is the apply.

## Context

- `demo-08-plan.md` §5 — the task this brief implements.
- `08-sorting-shootout-brief.md` — the demo brief. Open items 1 (`ns_per_op` unit), 2 (tuned-library radix line), 3 (chart-2 shape) and 8 (chart-1 left edge) are resolved here or below.
- `demo-08-json-audit-findings.md` — the capture audit. **F-1 is load-bearing for chart 1** (see Task 2).
- `08-sorting-shootout.mdx` (the §7 draft) — already contains the chart invocations with *assumed* prop names (`distribution`, `keyType`, `cacheBands`, `groupBy`, `n`, `variants`, `stat`). Reconciling those assumed props against the real component contracts is part of this brief (Task 4).
- `BRIEF.md` "Component contracts" — the canonical `<TimeVsN>` / `<ThroughputBars>` signatures.
- The capture: `site/src/data/perf/08-sorting-shootout.json` (66 runs; axes `variant` × `n` × `distribution` × `key_type`).

`<TimeVsN>` already gained cache-tier band markers in demos 6/7; demo 8 reuses that work. The only genuinely new component code is the chart-2 grouped view (Task 3), and it must be an extension, **not** a new component.

Two new per-run axes exist in demo 8's JSON that demos 6/7 did not have: `distribution` and `key_type`. The charts must filter on them. Demos 1–7 JSON does not carry these fields, so any new filter prop must be additive and default to "no filter" so the shipped charts are untouched.

## Tasks

### 1. Confirm `<TimeVsN>` consumes demo 8's JSON, add distribution/key_type filtering

Chart 1 is `<TimeVsN>` over demo 8's JSON, filtered to `distribution == "random"` and `key_type == "u32"`, three lines (`std_sort`, `pdqsort`, `radix_lsd`).

- Demo 8's `runs[]` mixes five distributions and two key types in one array. Determine whether `<TimeVsN>` currently filters by `distribution`/`key_type`. Demos 6/7 had a single distribution and key type, so it almost certainly does **not**.
- Add `distribution` and `keyType` filter props to `<TimeVsN>`. Additive; when absent, behaviour is unchanged (no filtering) so demos 6/7 render identically. When present, the component selects only matching `runs[]` before plotting.
- Confirm the value plotted is per-element nanoseconds and that demo 8 stores per-element nanoseconds in `ns_per_op` — so no conversion happens (resolves brief Open item 1). If demos 6/7 instead store total ns and convert in-component, demo 8's aggregator output must match that storage convention; if it doesn't, **stop and flag** — the fix is in the §3 aggregator, not here.

### 2. Cache-tier band markers, and do NOT trim the left edge

- Reuse the demo 6/7 cache-tier band feature as-is. Position the bands at the **data** working-set thresholds for a u32 array (key size 4 B): L1d 32 KB ≈ 8 K elements, L2 512 KB ≈ 128 K, L3 16 MB ≈ 4 M. These are the same band positions a reader reasons about ("N elements of 4 bytes"), consistent with demos 6/7.
- **Left edge: render from N = 2¹⁰ (1024). Do not trim.** Per audit finding F-1, radix loses to `pdqsort` in a narrow window at N = 4096–8192 — radix's two-buffer working set crosses L1 there while the in-place sorts don't. This window is a deliberate story beat in the post; the chart must show it. This overrides brief Open item 8's conditional trim.
- The radix line's knee sits near the L3 band because radix's footprint is ~2× the data (it ping-pongs two N-element buffers). The bands mark the single-buffer data size; the post caption explains the radix offset. Do not try to draw per-variant band positions — see Open item 2.

### 3. Chart 2 — grouped-bar view as a `<ThroughputBars>` extension

Chart 2 shows distribution sensitivity: fixed N = 2²² (4 194 304), `key_type == "u32"`, all five distributions, three variants. The decision (Opus): **one grouped-bar view**, x-axis = distribution (five groups), three bars per group (one per variant). This tells the whole thesis in one glance — radix's flat row of short bars against the comparison sorts spiking on random/sawtooth and collapsing on sorted/reverse. Repeated single-distribution charts split that pattern across five panels and lose it.

- Extend `<ThroughputBars>` with a `groupBy="distribution"` mode. Additive: when `groupBy` is absent, current single-group behaviour is unchanged so demos 1–7 render identically. When `groupBy="distribution"` is set, the component groups bars by the named field and renders one cluster per distinct value, ordered `random, sorted, reverse, few_unique, sawtooth`.
- Filter to `n == 4194304` and `key_type == "u32"` before grouping.
- **Resist forking a bespoke "SortChart" or "GroupedBars" component.** If the `groupBy` extension turns out to fight `<ThroughputBars>`' architecture badly enough that it's no longer a small change, fall back to five stacked `<ThroughputBars>` calls (one per distribution, each filtered) and **surface the choice in the PR** with a one-line reason. Do not invent a new component without flagging.

### 4. Reconcile the MDX invocations with the final contracts

`08-sorting-shootout.mdx` was drafted with assumed prop names. Once Tasks 1–3 settle the real contracts, update the two chart tags in the MDX to match exactly:

- `<TimeVsN>` — `slug`, the `distribution`/`keyType` filter props from Task 1, `variants`, and whatever the real cache-band prop is from Task 2 (the draft's `cacheBands="radix_lsd"` is a placeholder; replace with the actual API).
- `<ThroughputBars>` — `slug`, `n`, `keyType`, the `groupBy` prop from Task 3, `variants`, `stat`.

Edit only the two component tags. Do not touch the prose or the numerals in the MDX — those are §7's and are derived from the JSON.

### 5. Render verification on the branch preview

- Both charts render on `/posts/08-sorting-shootout` with no console errors.
- Demos 1–7 post pages still render their charts unchanged (regression check on the additive props from Tasks 1 and 3).

## Acceptance

- `cd site && npm run build` produces a clean static export with no errors.
- Chart 1 renders three lines over random u32 from N = 2¹⁰ to 2²⁶, with cache-tier bands at the L1/L2/L3 data thresholds, and the N = 4 K–8 K window where `pdqsort` overtakes `radix_lsd` is visible (not trimmed).
- Chart 2 renders as a single grouped-bar chart, five distribution groups, three bars each, at N = 4 194 304 — **or** five stacked `<ThroughputBars>` if the fallback was taken and flagged in the PR.
- `<TimeVsN>` with no `distribution`/`keyType` props, and `<ThroughputBars>` with no `groupBy` prop, render demos 1–7 byte-identically to before (additive-only change confirmed).
- No console errors on `/posts/08-sorting-shootout` or on any demo 1–7 post page.
- Lighthouse Performance ≥ 90 and Accessibility ≥ 90 on `/posts/08-sorting-shootout`, matching the other shipped demos.
- The MDX's two chart tags use only props the components actually expose (no dead props).
- Internal consistency: "five distributions" and "three variants" agree across the MDX, the rendered charts, and the JSON.

## Out of scope

- Any new chart component. `<TimeVsN>` is reused as-is plus additive filter props; `<ThroughputBars>` gains an additive `groupBy` mode. Forking is the fallback-and-flag path only.
- Any change to demos 1–7 chart behaviour, prose, code, or JSON.
- The post prose and all numerals in `08-sorting-shootout.mdx` (§7's domain).
- The forward cross-link edits into demos 1, 6, 7 (separate task).
- A tuned-library radix fourth line on chart 1 (brief Open item 2 — default is the three variants only; do not add a fourth line in this brief).
- Recapturing any JSON.
- The chart-2 `reverse`-vs-`sorted` redundancy decision (brief Open item 4) — render all five; the editorial drop-from-chart call is Opus's, not part of this brief.

## Open items for CC to flag

1. **`ns_per_op` storage convention.** If demos 6/7's `<TimeVsN>` reads total ns and divides by `n` in-component (rather than reading per-element ns directly), confirm demo 8's aggregator emits the same convention. If demo 8 stores per-element while 6/7 store total, the chart will be wrong by a factor of `n` — **stop and flag**; the fix is in the §3 aggregator. This is the single highest-risk item.

2. **Per-variant cache-band footprint.** The bands mark the single-buffer data working set (N × 4 B). Radix's real footprint is ~2× that, so its knee sits left of the L3 band. If the demo 6/7 band feature can only draw one set of bands, leave them at the data thresholds and rely on the caption — do **not** build per-variant band positioning for this. If you think per-variant bands are genuinely needed for the chart to read correctly, flag and propose rather than building it.

3. **`<TimeVsN>` filter-prop names.** Pick `distribution` and `keyType` to match the draft MDX if the component has no existing convention; if demos 6/7 already established different filter-prop names, use theirs and update the MDX to match. Surface the chosen names in the PR.

4. **Grouped-bar fallback.** If the `groupBy` extension isn't small, take the five-stacked-`<ThroughputBars>` fallback and flag it with a one-line reason. Do not press on building a new component.

5. **Distribution group ordering.** The brief specifies `random, sorted, reverse, few_unique, sawtooth`. If the component sorts groups alphabetically by default and overriding the order is non-trivial, flag it — the order is editorial (it puts the headline `random` case first), not load-bearing.

## Notes for CC

- This is small: two additive filter props on `<TimeVsN>`, one additive `groupBy` mode on `<ThroughputBars>`, and the MDX tag reconciliation. Budget well under a day. The risk is not volume; it's the `ns_per_op` unit (Open item 1) silently scaling chart 1 by a factor of `n`.
- The whole point of the additive-prop discipline is that demos 1–7 must render identically afterward. Verify that explicitly — it's an acceptance criterion, not an assumption.
- Chart-shape sanity-checking can use demo 6/7 JSON before relying on demo 8's, per the plan's dependency note.
