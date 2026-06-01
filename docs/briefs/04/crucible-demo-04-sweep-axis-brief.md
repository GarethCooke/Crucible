# Crucible — Demo 04 (SPSC) sweep-axis fix-up brief

Companion to `crucible-demo-04-fixup-brief.md`, `crucible-demo-04-refinement-brief.md`, and `crucible-demo-04-final-pass-brief.md`. Site-only. No C++ change, no recapture — the data needed already exists in the shipped JSON. Lands on the demo-04 branch (or directly, if demo 04 is on main) alongside the existing load-sweep chart.

## Context

The load-sweep chart (`chart="latency-vs-load"`) plots latency against **offered** load — the rate the pacer requests — on the x-axis. At the right edge of the boost (`lockfree-boost`) curve, p50 climbs to a peak and then **comes down** at the highest offered-load point. A p50 that falls as offered load rises is not physically sensible if offered load were the controlled variable: more arrivals cannot lower median queue residency.

The cause is that **offered load decouples from achieved load past a variant's producer throughput ceiling.** Boost's p50 tops out around ~20 µs — roughly ~300 items at its ~67 ns drain period (1 / ~14.9 M/s) — well short of the full-cap residency of 1024 × ~67 ns ≈ 69 µs. Boost never pins its queue at the cap. Contrast the mutex curve, whose p50 climbs and then sits on a flat plateau (~190 µs) across the top points: that _is_ a queue pinned at the 1024 cap, because its slow consumer is trivially and persistently overwhelmed. Boost's faster consumer means its producer cannot sustain enough overload to pin the queue, so the rightmost boost points are in the regime where achieved rate stops tracking the offered-load x-coordinate. Those points are not distinct physical operating points; their ordering on the y-axis is set by run-to-run variance, not by the x-value. The "dip" is the penultimate 5-run point happening to land deeper than the final one — the same variance family as the documented hand-rolled p99.9 transition spike.

A hostile reviewer reads a falling-latency-with-rising-load curve as either a bug or a fudge. The fix removes the non-physical tail without hiding the ceiling that causes it.

## Preconditions — verify before editing

CC must confirm the diagnosis against `site/src/data/perf/04-spsc-queue.json` before changing anything. The whole brief is conditional on these holding.

1. **Achieved-rate field exists on sweep runs.** Each `mode: "sweep"` run must carry an achieved-rate value alongside `offered_rate_hz`. Confirm the field name (`ops_per_sec`, or `achieved_rate_hz`, or similar). If sweep runs carry _no_ achieved-rate field, **stop and flag** — exposing achieved load needs a recapture, which is a user task on the reference machine, and this brief cannot proceed as written.

2. **Decoupling is real, not pure noise.** For the `lockfree-boost` sweep runs, compute `achieved / offered` at each point. The diagnosis holds only if achieved plateaus (boost's saturated `ops_per_sec`, ~14.9 M/s) while offered keeps rising — i.e. the ratio falls below ~0.9 at the top one-to-three points. Record the ratio at every sweep point in the PR. If achieved tracks offered all the way to the top (ratio stays ≈ 1) and the dip is present anyway, the dip is pure 5-run sampling variance, not decoupling — **stop and flag**: the fix is then an annotation, not a clamp, and Opus should re-scope.

3. **Top-of-range rate.** `crucible-demo-04-final-pass-brief.md` specified a 12-point sweep to 50 MHz, but the rendered chart shows points out to ~100 MHz. Read the actual max `offered_rate_hz` and the number of sweep points from the JSON and report both. Any MDX text stating the sweep range must match the JSON verbatim.

## Tasks

### 1 — Mark the offered/achieved decoupling point per variant

In `site/src/components/charts/LatencyVsLoad.tsx`, for each variant compute the saturation/decoupling point as the lowest offered-load sweep point where `achieved / offered` first drops below a threshold (default `0.9`; expose as a prop `decoupleThreshold` defaulting to `0.9`). This is the point past which the offered-load x-coordinate stops being a meaningful operating point for that variant.

The component already specifies "markers indicating each variant's empirical saturation point (where p99 diverges sharply from p50)" — reuse that marker mechanism for this point rather than introducing a second marker style. If the existing marker is computed by a p99/p50-divergence heuristic, replace that heuristic with the achieved/offered test, which is the physically correct definition.

### 2 — Clamp the rendered curve past the decoupling point

By default, render each variant's line only up to and including its first decoupled point; drop the points beyond it from the drawn path (do **not** drop them from the underlying data — they stay in the JSON and remain available). The dropped segment is the non-physical tail.

Add a prop `showDecoupledTail` (default `false`). When `true`, render the dropped points as a faint, dashed, de-emphasised continuation so the full sweep is still inspectable. Default-off keeps the published chart clean; the toggle preserves honesty for anyone who wants the raw shape.

Do **not** clamp at the hand-rolled transition point. The hand-rolled p99.9 spike at the ~16 MHz transition load is a documented, intended feature of the chart (see `crucible-demo-04-honest-prose-brief.md`, Edit 2) and sits _below_ the decoupling point — clamping must not remove it. Confirm the hand-rolled transition-spike point still renders after this change.

### 3 — Annotate the axis honestly

Add a short caption or sub-label to the chart making explicit that the x-axis is offered (requested) load and that each curve is drawn only through the regime where the variant's achieved rate tracks the offered rate. Keep it to one line in the chart's existing caption slot; do not add a new prose block in the component.

### 4 — MDX prose, `site/src/posts/04-spsc-queue.mdx`

In the load-sweep section, add or adjust prose (verbatim numbers filled from the JSON, not from this brief) so it:

- Names that each variant's curve stops where its producer can no longer drive the offered rate — i.e. where achieved load plateaus at the variant's throughput ceiling.
- States boost's ceiling (its saturated `ops_per_sec`) and that boost's p50 tops out short of the 1024-cap residency, so boost never pins its queue — contrasting the mutex, which does pin and plateaus flat.
- Does **not** describe boost p50 as falling at high load. Any sentence implying latency improves with more load is removed.

If the existing sweep prose already states the boost saturation rate (~28 MHz offered in `crucible-demo-04-honest-prose-brief.md`), reconcile it: ~28 MHz is the _offered_ knee; the _achieved_ ceiling is ~14.9 M/s. Both numbers may appear, but the prose must not conflate them — offered (MHz, what the pacer requests) and achieved (M/s, what the consumer drains) are different quantities and must be labelled as such everywhere they appear.

## Acceptance

- **Chart, default render:** for the published page (`showDecoupledTail` unset/false), the `lockfree-boost` p50 line is monotonic non-decreasing across every rendered point. No drawn p50 segment for any variant decreases with increasing x. Verify by reading the rendered series, not by eye.
- **Marker:** each variant shows exactly one decoupling marker, positioned at the JSON sweep point where `achieved / offered` first drops below `decoupleThreshold`.
- **Tail toggle:** with `showDecoupledTail={true}`, the dropped points render as a visually distinct (dashed/faint) continuation; with it false, they are absent from the drawn path. The underlying data array passed to the component is identical in both cases.
- **Hand-rolled spike preserved:** the hand-rolled p99.9 transition spike point still renders in the default view. `grep` the MDX for the transition-spike paragraph; it is unchanged.
- **Prose ↔ JSON:** every rate in the load-sweep prose (offered knees in MHz, achieved ceilings in M/s, sweep range, point count) matches `04-spsc-queue.json` to the stated precision. No sentence states boost latency falls as load rises.
- **Units discipline:** every offered-load figure in the section is labelled as offered/requested (Hz or MHz); every achieved figure as throughput (M/s). No bare "rate" that could be read as either.
- **No data change:** `git diff` touches no `.json` under `site/src/data/perf/`. `04-spsc-queue.json` is byte-identical.
- **No C++ change:** `git diff` touches nothing under `bench/`.
- **Build + render:** `npm run build` (or the project's build command) succeeds; the load-sweep chart renders with no console errors; Lighthouse Performance on `/posts/04-spsc-queue` stays ≥ 90.

## Out of scope

- Any recapture or rerun on the reference machine. If the preconditions show a recapture is needed, this brief stops and the rerun becomes a separate user task.
- Any C++ change to `bench/demos/04-spsc-queue/` — the sweep data is sufficient as captured.
- The paced-mode headline charts (latency CCDF / PDF at 1 MHz). Untouched.
- The hand-rolled transition-spike commentary and its data point.
- Any other demo's prose, code, JSON, or chart components.
- Re-deriving boost's drain rate from a consumer-only microbench (see open item 2) — out of scope here; if wanted, it is its own brief.
- Switching the x-axis to achieved load globally. Considered and rejected as the default (see open item 1); the clamp-plus-marker approach is the chosen fix.

## Open items for CC to flag

1. **Clamp vs achieved-load x-axis.** This brief chooses to keep offered load on the x-axis and clamp the non-physical tail, because the surrounding prose is written in offered-load terms and plotting achieved load collapses the over-saturated points into a vertical smear at the ceiling. If, after implementing the clamp, the result still reads as evasive — e.g. a reviewer can't see that boost hit a ceiling — flag it and propose an achieved-load x-axis variant as a follow-up rather than switching unilaterally.

2. **The ~3× consumer-speed claim.** If the load-sweep prose (or adjacent sections) asserts boost's consumer is ~3× slower than the hand-rolled one, note that this does not fall out of the throughput ceilings — both variants cap near ~14.7–14.9 M/s, but the hand-rolled cap is producer-limited while boost's is consumer-limited, so the numbers coincide for different reasons. The 3× claim needs a consumer-only microbench to support it. Surface the sentence; do not invent the comparison. (Out of scope to measure here.)

3. **Threshold sensitivity.** If `decoupleThreshold = 0.9` puts a variant's marker on a point that visually still looks on-trend (or clamps a point that looks fine), report the achieved/offered ratios and let Opus pick the threshold rather than tuning it silently.

4. **Range discrepancy.** If the JSON's top sweep rate or point count disagrees with what the final-pass brief specified (50 MHz / 12 points) or with what the rendered chart shows (~100 MHz), report the actual values and do not "correct" the data — the MDX text is what gets reconciled to the JSON, not the other way around.
