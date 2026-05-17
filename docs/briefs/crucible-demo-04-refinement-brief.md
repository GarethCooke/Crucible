# Crucible — Demo 04 (SPSC) refinement brief

Companion to `crucible-demo-04-fixup-brief.md` and `crucible-demo-04-sweep-json-fix-brief.md`. The first fix-up made the headline measurement defensible; the JSON-emission patch made the data parseable. This brief addresses the second skeptical-review pass on the resulting data and post.

Scope: one harness change (extend the sweep range with a tighter pacer so the mutex variant actually saturates within the swept range), two small data-emission fixes, and nine prose edits to the MDX. One rerun on the rig.

## Why this revision

The second review pass surfaced four substantive issues plus a handful of polish items. The substantive issues:

1. The post claims "queue near-empty in all variants" at 1 MHz paced, but the mutex variant runs at avg depth 1.76 (vs ~0.12 for lock-free). It's an order of magnitude lower than saturated, but it isn't "near-empty."
2. The post claims the mutex curve "hockey-sticks" in the load sweep. The actual sweep data doesn't show this — at the 25 MHz target the mutex variant achieves 4.5 M/s with p50 = 3 µs, far below saturated mode's 6 M/s and p50 = 168 µs. The pacer's per-iteration overhead caps the producer below the mutex variant's true saturation point. The hockey-stick exists, it just isn't visible within the swept range.
3. Mutex p99.9 is _worse_ at 100 kHz (23 µs) than at 1 MHz (3.8 µs) — a non-monotonic hump on the left of the chart that the post doesn't explain.
4. `isolated_cpus: "0-7"` in the JSON contradicts the user's understanding that cores 1–7 are isolated and core 0 is not. Source field says `cmdline`; reconciliation needed.

Issue 2 is the only one requiring a code+rerun change. The rest are MDX edits plus two small JSON-emission corrections.

## C++ changes

### `bench/demos/04-spsc-queue/benchmark.cpp` — tighter pacing helper

The current pacing loop uses `rdtscp_ordered()` (which includes `lfence` serialisation) for the per-iteration "are we at the deadline yet" check. Each call costs ~30 cycles of pipeline serialisation. At 25 MHz target (40 ns inter-arrival ≈ ~150 cycles on Zen 2 at 3.9 GHz), that's a significant fraction of the budget — enough to cap achievable throughput below the mutex variant's saturation point.

Replace with a two-tier pattern:

```cpp
// Pre-computed once per run:
const uint64_t period_cycles = static_cast<uint64_t>(
    1e9 / target_rate_hz / ns_per_cycle);
uint64_t next_release_cycles = rdtscp_ordered();  // calibration anchor

for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
    // Cheap deadline check: rdtsc only, no lfence.
    // Skips the busy-wait entirely when behind schedule.
    while (__rdtsc() < next_release_cycles) {
        _mm_pause();
    }
    // Measurement timestamp: full serialising rdtscp + lfence.
    enq_ts[i] = rdtscp_ordered();
    while (!q.try_push(make_tick(i))) { /* spin */ }
    next_release_cycles += period_cycles;
}
```

Two changes from the current code:

1. **Pacing check uses `__rdtsc()` (non-serialising) instead of `rdtscp_ordered()`.** Pacing only needs approximate timing; measurement timestamps still use the serialising path. This removes the per-iteration `lfence` cost from the deadline check.
2. **Per-iteration `next_release_cycles += period_cycles`** rather than recomputing from a base. Keeps the deadline rolling forward at exactly the requested period regardless of jitter.

When `target_rate_hz` is so high that `__rdtsc() >= next_release_cycles` on the very first check, the inner loop runs zero times and the producer goes flat-out — converging cleanly to saturated behaviour. This is the desired property: at high target rates, the sweep should reproduce saturated mode rather than capping below it.

Apply this rewrite to all three variant runners (`run_lockfree_handrolled`, `run_lockfree_boost`, `run_mutex_condvar`).

### Sweep range extension

Current sweep: 100 kHz → 25 MHz in 8 log-spaced steps. Replace with 100 kHz → 50 MHz in 12 log-spaced steps. The upper end must be high enough that all three variants demonstrably saturate (achieved rate flattens, queue depth ~= capacity, latency = depth × consumer_period). With the tighter pacer above, the mutex variant should reach its ~6 M/s saturated state within the sweep — visible as a clear hockey-stick in p50 around 6 M/s offered load.

Suggested rate points (log-spaced, rounded for readability):

```
100k, 200k, 400k, 800k, 1.5M, 3M, 6M, 12M, 18M, 25M, 35M, 50M
```

Equivalently: pass `--rate-from 100000 --rate-to 50000000 --steps 12` and let the existing log-spacing routine pick the points.

The lock-free variants should saturate around 16–20 M/s; the mutex variant around 6 M/s. With 12 points spanning 100k → 50M, each saturation point has at least 2–3 measurement points on either side.

### `bench/common/machine_info.h` — reconcile `isolated_cpus` reporting

Current behaviour: read `isolcpus=` from `/proc/cmdline`, emit verbatim. This produced `"0-7"` on the reference machine, contradicting the user's claim that only cores 1–7 are actually isolated.

Both readings can be correct simultaneously: the cmdline can request `isolcpus=0-7` while the kernel only honours it for cores 1–7 (core 0 is typically reserved for boot/interrupt handling and can't be fully isolated). The reporting should distinguish.

Schema change to the `machine` block (additive):

```json
"machine": {
  ...
  "isolated_cpus_requested": "0-7",     // from /proc/cmdline
  "isolated_cpus_effective":  "1-7",    // intersection with cores that show
                                        //  no scheduler activity from non-bench
                                        //  tasks in /proc/<pid>/stat snapshot
  "isolated_cpus_source": "cmdline+probe",
  ...
}
```

The "effective" value is harder to compute reliably. Pragmatic approach: at machine-info collection time, read `/sys/devices/system/cpu/isolated` (the kernel's view of which cores are actually in the isolated set, distinct from the cmdline request). If that file exists and is non-empty, report its contents as `isolated_cpus_effective`. If it's empty or absent, omit the effective field and only report the cmdline value.

Acceptance test: on the reference rig, `cat /proc/cmdline` and `cat /sys/devices/system/cpu/isolated` should produce two different strings, and the JSON should reflect both.

Deprecate `isolated_cpus` (no suffix) — leave it present for backward compatibility, set equal to `isolated_cpus_effective` when available, else `isolated_cpus_requested`. The site front-end can switch to the new fields when ready.

### `bench/demos/04-spsc-queue/benchmark.cpp` — `offered_rate_hz` for saturated mode

Current behaviour: saturated-mode runs emit `"offered_rate_hz": null`. The fix-up brief specified this field must be present and non-null for schema uniformity.

Fix: for saturated-mode runs, emit `"offered_rate_hz": 0`. Zero means "no pacing target was applied" — distinct from any real offered load. The site `<Benchmark>` filter treats `offered_rate_hz=0` as the saturated-mode selector.

If a future variant needs to report the empirically achieved rate as the offered rate (it doesn't currently), that goes in the existing `ops_per_sec` field.

## MDX changes — `site/src/posts/04-spsc-queue.mdx`

Nine edits, all prose. No rerun needed for any of these once the C++ changes above produce updated data.

### Issue 1 — "near-empty" overclaim

Current (lines 106–108):

> At 1 MHz offered load the queue is near-empty in all variants — the latency difference is genuinely the cost of the kernel boundary, not an artefact of queue depth.

Replace with:

> At 1 MHz offered load the lock-free variants leave the queue effectively empty (≈0.1 items by Little's law). The mutex variant runs about 1.8 items deep on average — each item's wake-up cycle takes slightly longer than the inter-arrival period, so a small amount of residency accumulates. Even so, the latency gap is dominated by kernel-boundary cost rather than depth: queue residency contributes under 2 µs while the p99.9 difference between mutex and lock-free is tens of microseconds.

### Issue 2 — hockey-stick framing in load sweep

After the rerun, the mutex variant should now actually saturate within the swept range. The hockey-stick the section describes should be plainly visible in the chart.

Rewrite the load-sweep prose (lines 138–148) to match what the chart now shows. Approximate template — adjust numbers to the actual rerun data:

> Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points from 100 kHz to 50 MHz. The mutex variant saturates first, around 6 MHz offered load — beyond that, its consumer can't drain fast enough and the queue fills toward capacity. Once saturated, latency scales as `queue_depth × consumer_period` rather than per-op cost plus wake-up overhead, producing the steep climb visible on the right of the mutex curves.
>
> The lock-free variants stay flat much further. The hand-rolled implementation saturates around 16–20 MHz; Boost is similar. Their consumers spin on the producer's `tail_` store via cache coherence and proceed without kernel involvement, so they keep up until the producer's per-push cost itself becomes the bottleneck.

### Issue 3 — non-monotonic mutex tail at low load

Add a new paragraph immediately after the load-sweep prose:

> One wrinkle visible on the left of the chart: the mutex p99.9 curve has a hump at very low offered load — its tail is _worse_ at 100 kHz than at 1 MHz. This is the consumer sleeping deeper between items. Longer idle periods let the kernel deschedule the consumer thread further (and on Zen 2 with `performance` governor, even let it slide into shallower C-states), so wake-up cost on the next item is larger. It's a known property of condvar-based queues and an additional argument against them for sporadic workloads.

### Issue 6 — Boost comparison hedge

Current (lines 187–195):

> ...Under 1 MHz paced load, Boost should track the hand-rolled implementation within ±20% at both p50 and p99.9 — a useful credibility check that the hand-rolled version isn't leaving anything obvious on the table. If the post data shows Boost diverging beyond that, the notes section of this page will say so.

Replace with (numbers from the current JSON; update to the post-rerun values if they shift):

> Under 1 MHz paced load, the hand-rolled implementation comes in at 132 ns p50 vs Boost's 122 ns — within 8%. p99.9 is similarly close: 172 ns hand-rolled vs 148 ns Boost. That's the credibility check: the hand-rolled version isn't leaving anything obvious on the table relative to a battle-tested production library, and conversely Boost isn't doing anything clever in its hot path that the 50-line version misses.

### Issue 7 — duplicate summary and opening

Current frontmatter summary (line 4) and body line 7–9 are identical sentences. Pick one to rewrite.

Suggested: keep the summary as-is for the metadata. Rewrite the body opening to lead with the setup rather than restating the summary:

> A market-data thread produces 16-byte ticks; a strategy thread consumes them. End-to-end enqueue-to-dequeue across three implementations of the same queue API — a hand-rolled lock-free ring, the same ring from Boost, and a `std::queue` protected by a mutex and condvar. Same hardware, same item, same threading topology. At moderate offered load all three look similar at the median; the tail and the breakdown rate are where they diverge by orders of magnitude.

### Issue 8 — self-undermining footer note

Remove lines 223–225 ("Footer regenerated from `latency_ns.stats`; verify against the JSON before citing.") entirely. The chart components do their own regeneration; there's no separate numerical footer for a reader to verify. The note describes a thing that no longer exists and reads as low-confidence.

If a methodology pointer is wanted in its place, use:

> _Percentile values shown in charts above are computed from raw histograms in the corresponding JSON entries: log₂-subbucket-16 binning, bucket-midpoint percentile convention. Top-bucket counts and TSC drift across all 30 runs were zero. See [Methodology] for the rdtscp calibration path._

### Issue 9 — "tens of nanoseconds" → measured value

Current (line 179):

> ...that cache-coherence round-trip is measured in tens of nanoseconds.

Replace with:

> ...that cache-coherence round-trip plus the buffer load and store completes in roughly 100–130 nanoseconds on Zen 2 within a CCX — the floor visible in the p50 numbers above.

### Issue 10 — publication date

Frontmatter `date: "2026-05-14"` predates the captured run by three days. Update to match the new `captured_at` field after rerun.

### Issue 11 — "fits in L1d" framing

Current (lines 124–126):

> The lock-free distribution is sharply peaked — most items transit at nearly the same latency, with the ring buffer fitting entirely in L1d (16 KB for 1024 × 16-byte entries).

Replace with:

> The lock-free distribution is sharply peaked — most items transit at nearly the same latency. The 16 KB ring buffer fits in each core's 32 KB L1d, and the inter-core handoff is serviced by the shared CCX1 L3 slice without crossing the Infinity Fabric.

## Acceptance criteria

- `cmake --build build --target bench_04_spsc_queue` succeeds.
- `bench_04_spsc_queue lockfree-handrolled --mode sweep --rate-from 100000 --rate-to 50000000 --steps 12` produces 12 sweep runs.
- For the mutex-condvar sweep, the achieved rate at the top 1–2 sweep points equals (within 10%) the saturated-mode `ops_per_sec`. This is the test that the tighter pacer can actually drive mutex into saturation.
- Mutex sweep p50 at the top of the range matches (within an order of magnitude) the saturated-mode p50 of ~168 µs. Currently it's 3 µs at 25 MHz — that's the gap this rerun closes.
- All three variants' sweep curves show a clear knee in p50 or p99 within the swept range.
- `machine.isolated_cpus_requested` equals `/proc/cmdline`'s `isolcpus=` value verbatim. `machine.isolated_cpus_effective` equals `/sys/devices/system/cpu/isolated`'s contents (or is omitted if that file is empty).
- All saturated-mode runs have `offered_rate_hz: 0` (not `null`).
- `latency_ns.stats.max >= latency_ns.stats.p99_9` for every run (regression guard).
- All MDX changes 1, 3, 6, 7, 8, 9, 10, 11 land. Change 2 (load-sweep rewrite) reflects the actual post-rerun shape, not the pre-rerun numbers.
- Lighthouse perf on the post page still ≥ 90.

## Out of scope

- Cross-CCX measurement. Still deferred.
- Sweeping queue depth (still 1024 only).
- Investigating _why_ the mutex condvar wake-up gets worse at very low load — the MDX paragraph names the mechanism; quantifying it would need a separate harness (cpuidle/perf attached to the consumer thread).
- Re-checking whether the original `_mm_pause` spin was the actual bottleneck on the pacer vs the per-iteration `lfence`. The new code removes both; if performance is still pacer-limited after the rewrite, that's a follow-up.

## Notes for CC

- Don't touch the histogram percentile convention. It's correct now (`max >= p99_9` holds across all 30 current runs).
- Don't reintroduce the `null` offered_rate_hz "for cleanliness" — schema needs a real number, including `0` for saturated.
- After the rerun, run the load-sweep prose update with the new numbers in hand. The current draft template uses approximate numbers ("around 6 MHz", "16–20 MHz") that will need exact values from the new JSON.
- The pacing-helper rewrite uses `__rdtsc()` — that's the GCC builtin, declared in `<x86intrin.h>`. Already included transitively via the existing tick.h infrastructure, but verify the include is present.
