# Crucible — Demo 07 chart-component check (CC-apply scope)

Scopes demo 7 plan §5 for CC to apply on the demo-7 feature branch. Implements the two `<TimeVsN>` extensions called for by `07-flatmap-vs-hashmap-brief.md` tasks 5 and 7: a workload-mix x-axis for chart 3, and a `variantLabels` prop so legends render readable implementation names instead of raw JSON slugs. Companion docs: `BRIEF.md` (component contracts), `demo-07-plan_1.md` (§5), `pre-demo-5-07-site-chart-refactor-brief.md` (the legend/grid helper layout this builds on). Lands on the feature branch alongside §7's MDX work; does not touch `main`.

## Context

- `<TimeVsN>` (MDX-facing, `site/src/components/charts/TimeVsN.tsx`) and its client render component `<TimeVsNChart>` (`TimeVsNChart.tsx`) already render ns/op-vs-N on a log x-axis, one line per variant, with cache-tier band markers (added demo 6) and a configurable `xAxis` prop (demo 6 added `xAxis="k"`).
- **Chart 1** (5-line staircase, N=16 → ~10⁶, log-x) reuses `<TimeVsN>` unchanged.
- **Chart 2** (throughput bars at three N values) is three `<ThroughputBars>` calls in MDX — no component change.
- **Chart 3** (workload-mix sensitivity) needs `<TimeVsN>` pointed at the workload-mix field on a **linear percent** x-axis.
- Legends currently render the raw JSON `variant` key (e.g. `absl_flat`). Chart 1 and chart 3 both want readable labels (`absl::flat_hash_map`).
- The bench harness (plan §3, shipped) is authoritative for both the workload-mix field name and the variant slugs. Plan §6 headline capture has not run, so `site/src/data/perf/07-flatmap-vs-hashmap.json` may not exist yet — use demo 6's JSON for chart-shape development, per the §5 dependency note.

The workload-mix field is **`modify_pct`** (confirmed against the harness). The `insert_pct` naming in `demo-07-plan_1.md` was stale but has now been updated.

## Tasks

### 1. Use `modify_pct` as the workload-mix axis field. (Resolved.)

The bench harness emits **`modify_pct`** for the per-run workload-mix fraction (confirmed). Pin `<TimeVsN xAxis="modify_pct">`, the JSON field reference, and the chart-3 prose label to `modify_pct` everywhere.

### 2. Confirm the `xAxis` prop generalises to a percent (linear) axis.

Inspect how `<TimeVsNChart>` resolves `xAxis`:

- If it's a switch/enum over known fields (`n`, `k`), add a case for the workload-mix field from Task 1.
- If it reads an arbitrary run field by name, no field plumbing is needed.

In **both** cases verify the x **scale type**. Chart 1's N axis is log; chart 3's mix axis is a percentage and must render **linear, 0–100**. If the scale type is hardcoded to log, lift it to follow the axis (e.g. `xScale?: "log" | "linear"`, defaulting to `"log"` so chart 1 and all shipped `<TimeVsN>` usages are unchanged). Verify the axis title and tick format read as a percentage for chart 3 and are unchanged for chart 1.

Cache-tier band markers are meaningless on the mix axis — suppress them when the axis is not `n` (or gate them behind the existing band prop). If demo 6 already made the scale type configurable for `xAxis="k"`, this task is verification only.

### 3. Add the `variantLabels` prop.

Contract:

```tsx
<TimeVsN
  slug="07-flatmap-vs-hashmap"
  variants={[
    "std_map",
    "std_vec_lower_bound",
    "std_flat_map",
    "std_unordered",
    "absl_flat",
  ]}
  variantLabels={{
    absl_flat: "absl::flat_hash_map",
    std_flat_map: "std::flat_map" /* … */,
  }}
  stat="median"
/>
```

`variantLabels?: Record<string, string>` maps a JSON `variant` slug to its legend display string. Where a slug has no entry, fall back to the raw slug (current behaviour) — the prop is additive and optional, so chart 1 and every shipped post that omits it are unaffected.

Thread it from `<TimeVsN>` into `<TimeVsNChart>` and apply it at the **single** point where the legend label text is set — whether that is inline in `TimeVsNChart.tsx` (~lines 191–209 pre-refactor) or in `appendLegendLines` / `appendLegendRects` in `d3helpers.ts` (post-refactor). Populate the actual slug→label map from the JSON's `runs[].variant` values; do not invent slugs. The five implementations are `std::map`, `std::vector<pair> + lower_bound`, `std::flat_map`, `std::unordered_map`, `absl::flat_hash_map` (plan §3).

## Acceptance

- `grep -rn "insert_pct" site/src/posts/07-flatmap-vs-hashmap.mdx site/src/components/charts` returns zero hits; the chart-3 axis references `modify_pct` only (Task 1).
- Dev render exercising the linear-scale path on demo 6's own sweep axis (its `xAxis="k"` field with `xScale="linear"`) shows a linear x-axis with no cache-tier bands; the `modify_pct` axis itself is verified against 07 JSON once §6 capture lands. (Demo 6 JSON has no `modify_pct` field, so it can only stand in for the scale-type plumbing, not the field.)
- Every shipped `<TimeVsN>` usage (e.g. demo 01, demo 06) renders byte-identically to pre-change — the new props are additive and defaulted.
- Dev render of `<TimeVsN slug="06-aos-vs-soa" xAxis="<mix-field>" xScale="linear" />` (demo 6 JSON as a stand-in, or 07 JSON once captured) shows a linear 0–100 x-axis, a percent-formatted axis title, and no cache-tier bands.
- Dev render with `variantLabels={{ absl_flat: "absl::flat_hash_map" }}` shows `absl::flat_hash_map` in the legend; omitting the prop shows `absl_flat`.
- `npm run typecheck` passes; `variantLabels` and any new `xScale` prop are typed (no `unknown` / `any`).
- `npm run build` produces a clean static export.

## Out of scope

- Chart 2 (`<ThroughputBars>`) component code — three MDX calls, no component change. _But see Open items: chart 2 will still render `absl_flat` on its bars unless `variantLabels` is threaded through `<ThroughputBars>` too. Flag, don't silently fix._
- The §7 MDX post body — separate task. This brief only makes the component capable; it does not author the chart invocations.
- Forking a `MapCrossover` / `WorkloadMix` component — the §5 lesson is extend, not fork.
- Any JSON recapture (§6, user task on the reference machine).
- Demos 1–6 prose, code, or JSON.

## Open items for CC to flag

- **Chart-2 / chart-1 label consistency.** If §7's MDX places chart 1 (`<TimeVsN>` with `variantLabels`) next to chart 2 (`<ThroughputBars>` without), the same implementation reads `absl::flat_hash_map` in one and `absl_flat` in the other. The clean fix is to thread the identical `variantLabels` map through `<ThroughputBars>`, or to centralise one slug→label map per demo. Flag to Opus rather than expanding this brief unilaterally.
- **Refactor state.** If `pre-demo-5-07-site-chart-refactor-brief.md` has not shipped, the legend is still inline in `TimeVsNChart.tsx` and `variantColorByIndex` is local — apply `variantLabels` at the inline site. If it has shipped, apply it in `d3helpers.ts`'s legend helper. Either is fine; note which in the PR.
- **`xAxis="k"` scale type.** If demo 6's `xAxis="k"` uses a log scale and Task 2 makes the scale type configurable, confirm demo 6's post still renders with the correct (log) scale after the change — the default must remain `"log"`.
