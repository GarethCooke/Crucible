# Crucible — Demo 04 spike diagnostic: consumer-stall instrumentation

Patch brief for Claude Code, with a reference-machine rerun step for Gareth. Companion to `crucible-demo-04-throughput-attribution-brief.md`, which corrected the spike paragraph's *mechanism* (a consumer-side stall, not the producer filling the queue) but left the *frequency* open: is the 16 MHz hand-rolled p99.9 spike a one-off measurement contaminant or a reproducible feature? This brief adds the instrumentation to answer that and hands the measurement to Gareth. It does **not** finalise the post wording — that's a follow-up prose brief once the data is in.

## Context

The physics is settled: the hand-rolled consumer drains faster than the producer's flat-out ~14.7 M/s rate (the variant is producer-bound, queue near-empty), so the producer cannot build a deep queue. A 42 µs residency at the 16 MHz sweep point implies the queue reached several hundred deep, which can only happen if the **consumer** briefly stopped draining — a stall of tens of µs while the producer kept filling.

What's unresolved is how often that happens, and it hinges on two facts neither the throughput-attribution brief nor the review settled:

1. **The actual sample count behind that p99.9.** If the sweep point is a single 1M run, p99.9 is the 1000th-worst sample and ~1000 elevated items from one stall lands there — contaminant plausible. If it's 5 runs × 1M merged (5M), p99.9 is the 5000th-worst, and — critically — for the spike to *survive the merge* the elevated condition must recur across most of the five runs, which is the opposite of a one-off. The CC review asserted 5M-merged; the `crucible-demo-04-sweep-json-fix-brief.md` acceptance criteria describe "24 sweep runs (3 variants × 8 steps)", i.e. **one run per sweep point**, which would be 1M. These disagree. The JSON is ground truth.

2. **Whether a stall is actually present at that point, and on which side.** The published JSON carries only the binned histogram, not the raw `enq_ts`/`deq_ts` arrays, so the existing spike can't be analysed retroactively. The diagnostic has to be added and the point re-run.

The diagnostic is a post-run pass over arrays the benchmark already fills. It does not touch the measured hot loop.

## Tasks

### 1. Read the sample count for the 16 MHz hand-rolled sweep entry (CC, no rerun)

In `site/src/data/perf/04-spsc-queue.json`, find the `runs[]` entry for `variant: lockfree-handrolled`, `mode: sweep`, at (or nearest) `offered_rate_hz` = 16 MHz. Report:

- Its `iterations` field (and `items_measured`).
- The total count summed across its `latency_ns` histogram buckets.

State plainly whether the p99.9 = 42 µs is computed over ~1M or ~5M samples. This single number decides which way the "contaminant vs reproducible" question leans before any rerun, so report it first and explicitly.

If the count is ~5M (merged), that contradicts the one-run-per-step structure in the sweep-fix brief — **flag it** and report how sweep-point merging actually works in `assemble_results_04.py` / `run_one.sh`, because that changes the interpretation of every sweep-point percentile in the post, not just this one.

### 2. Add the post-run stall diagnostic (CC)

**File:** `bench/demos/04-spsc-queue/benchmark.cpp`, in the post-run analysis loop that converts timestamps to latencies (around line 460, where `bin_run(result, deq_ts[i] - enq_ts[i])` is called per the N1 finding). This is post-measurement — **do not add anything to the producer or consumer hot loops.**

Over the measured items, compute and report three quantities (convert cycles → ns via the existing `tsc_ns_per_cycle`):

- `max_enq_gap_ns` = max over `i` of `(enq_ts[i] - enq_ts[i-1])` — largest pause on the producer side.
- `max_deq_gap_ns` = max over `i` of `(deq_ts[i] - deq_ts[i-1])` — largest pause on the consumer side. (Dequeue order equals seq order for this FIFO SPSC queue, so `deq_ts` is monotonic in `i` and no sort is needed.)
- `backlog_at_max_deq_gap` = count of items `j` with `deq_ts[i*-1] < enq_ts[j] <= deq_ts[i*]`, where `i*` is the index of the largest dequeue gap — i.e. how many items piled into the queue during that gap. This should land near the `q_depth` figure the prose cites.

Emit one line to **stderr** per variant run, in the same spirit as the existing top-bucket / TSC-drift WARN lines, e.g.:

```
DIAG lockfree-handrolled @offered=16000000Hz: max_enq_gap=NNN ns  max_deq_gap=NNN ns (at item i*)  backlog=NN items
```

Add a WARN if `max_deq_gap_ns` exceeds a clear multiple (say 50×) of the run's median inter-dequeue interval — that's the contamination signal.

Skip the first measured item (no valid predecessor). If any `deq_ts[i] == 0` for hand-rolled (should not occur — the stress test verifies zero losses), exclude it from the gap computation and flag the count; that path matters for the mutex variant, not this one.

Keep the diagnostic **stderr-only**. Do **not** add a field to the published JSON schema in this brief (see Open items for the publish decision).

### 3. Build and verify computation locally (CC)

- `cd bench && cmake -B build && cmake --build build` builds clean; all prior demos still build.
- Run the hand-rolled variant once locally (any mode) and confirm the `DIAG` line prints with plausible, non-negative values.
- Confirm the measured hot loops are byte-for-byte unchanged: `git diff` shows edits only in the post-run analysis region, nothing in the producer/consumer loops or the timestamping.

A local run only verifies the diagnostic *computes* correctly. CC's box is not the isolated rig and will not reproduce (or rule out) the stall — that's the rerun in the next section.

## Reference-machine rerun (Gareth — out of scope for CC)

After the diagnostic lands, on the reference rig under `cset shield`:

- Re-run the 16 MHz hand-rolled sweep point ~10 times, capturing stderr each time. Record the `DIAG` values.
- Optionally re-run the full sweep 2–3 times and watch whether a comparable ~40 µs spike appears at a *different* offered-load point (a wandering spike confirms contaminant).

Interpretation (folds into the follow-up prose brief):

- Large `max_deq_gap` with small `max_enq_gap`, present in most reruns → reproducible consumer stalls; the "one-off contaminant" label is wrong and the post says so.
- Large `max_deq_gap` in some reruns, clean in others / spike wanders across points → one-off contaminant; current label stands.
- No large gap on either side but the spike persists → the stall model is incomplete; **stop and reconsider** before publishing any mechanism.

## Acceptance criteria

- Task 1's sample count is reported as a concrete number with the ~1M-vs-~5M question answered explicitly.
- `bench/demos/04-spsc-queue/benchmark.cpp` builds clean; all prior demos build.
- A local hand-rolled run prints exactly one `DIAG` line per run with the three quantities, all non-negative, `backlog` ≥ 0.
- `git diff` confirms no edits to the producer/consumer hot loops or the per-item timestamping — only the post-run analysis region.
- Local p50 for the hand-rolled variant is within run-to-run noise of a pre-change build (sanity that nothing in the measured path moved).
- No change to the emitted JSON: `./bench/scripts/run_one.sh 04-spsc-queue` (if run) produces a `04-spsc-queue.json` that validates against the existing schema with no new fields.

## Out of scope

- **Final post wording.** The spike paragraph's frequency framing depends on the rerun outcome; it's a follow-up prose brief, not this one. Leave the post prose as the throughput-attribution brief left it.
- **The rig rerun itself.** Reference-machine task for Gareth; CC adds the instrumentation only.
- **Publishing the metric to the JSON schema** (see Open items).
- **Applying the diagnostic to other demos or other sweep points/variants.** If Gareth wants it harness-wide later, that's a separate refactor.
- **Re-running or modifying any other demo's data.**

## Open items for CC to flag

- **Publish to JSON, or stderr-only?** Default here is stderr-only — no schema touch, matching the top-bucket/TSC-drift guards. If Gareth wants `max_deq_gap_ns` as a published per-run field for future contamination auditing, that's a deliberate schema addition (optional sibling, existing demos unaffected) and should be its own decision. Surface the choice rather than deciding it.
- **If Task 1 shows ~5M merged**, the single-run-per-step assumption in the sweep-fix brief is wrong; confirm the merge path and note that every sweep percentile in the post is a merged statistic, which the prose may not currently reflect.
- **If hand-rolled `deq_ts` contains zeros**, that contradicts the zero-loss stress-test guarantee — flag it, don't just skip silently; it would mean items are being dropped.

## Notes for CC

- The whole diagnostic is post-run and O(N); it reuses the loop that already walks `enq_ts`/`deq_ts` to bin latencies. Hook in there, not anywhere upstream.
- The point of computing *both* gaps is direction: a consumer stall is a dequeue gap with no matching enqueue gap (the producer kept stamping items the whole time), and the `backlog` count is the pile-up that produces the tail.
- Don't infer anything from a local run beyond "the numbers compute." The stall, if real, lives on the isolated rig under load.
