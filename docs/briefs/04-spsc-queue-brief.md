# Crucible — Demo 4: Lock-free SPSC vs mutex queue

Implementation brief for Claude Code. Self-contained — no further scoping decisions required beyond the named open items.

## Context

Fourth demo in the Crucible series. Builds on:

- `BRIEF.md` — v1 scaffold, locked schema, methodology, hardware spec.
- Demo 2 (false sharing) — adds cache-miss counter capture and `<CounterOverlay>` to the harness.
- Demo 3 (SIMD Black-Scholes) — adds `compile_flags` to schema, no new components.

This demo:

- Extends the per-run schema with an optional `latency_ns` block (pre-binned log-spaced histogram + tail stats). Locked shape below.
- Adds `bench/common/histogram.h` — log-spaced binning + JSON serialisation, reusable for future tail-latency demos.
- Adds `<LatencyHistogram>` chart component supporting CCDF and PDF views from the same JSON.

No changes to existing schema fields. No changes to existing components.

## Story angle

Single-producer single-consumer queue, end-to-end enqueue→dequeue latency. Lock-free ring buffer vs `std::mutex` + `std::condition_variable`. Headline: the tail collapses dramatically with the lock-free version (the actual multiplier is whatever the measurement says — do not hardcode an expected ratio in the post; let the numbers speak).

Capital-markets framing in one paragraph: market-data thread produces tick updates, strategy thread consumes. p99.9 latency is what determines whether the strategy reacts in time for the trade.

## Workload

- **Item:** 16-byte POD struct representing a market tick:
  ```cpp
  struct MarketTick {
      uint32_t price;
      uint32_t qty;
      uint64_t seq;   // monotonic sequence number, also lets consumer reconstruct ordering
  };
  ```
  Realistic-looking, large enough to not be trivial copy, small enough that 1024 of them fit in L1d. Note in the post that production ticks vary; queue behaviour is independent of payload contents.
- **Queue depth:** 1024 entries. Power of 2 — ring buffer index uses bitmask. Total ring buffer 16 KB, fits L1d on Zen 2 (32 KB).
- **Items measured per run:** 1,000,000.
- **Warmup pre-roll:** 100,000 items before measurement starts. CC verifies empirically by comparing the histogram of items 0–100k against items 100k+ in a debug build — if they differ materially in shape (not just count), warmup is insufficient and should be raised. Lock this in once verified.
- **Runs per variant:** 5 full runs of 1M items each. Histograms merged (count arrays summed elementwise) before publication. Final per-variant histogram contains 5M samples. Top-level stats (p50/p99/p99.9/etc) computed from the merged histogram, not averaged across runs.

## Variants

Three, all built with `-O3 -march=native -std=c++20`:

1. **`lockfree-handrolled`** — own ~50-line SPSC ring buffer in `spsc_queue.h`. Cache-line-padded `head_` and `tail_` (each occupies its own 64-byte aligned cache line). `std::atomic<size_t>` head/tail, with `memory_order_release` for the producer's tail store and `memory_order_acquire` for the consumer's tail load (vice versa for head). Each atomic has exactly one writer. `try_push` and `try_pop` are non-blocking, return bool. Harness spins on `try_pop` returning false.

2. **`lockfree-boost`** — `boost::lockfree::spsc_queue<MarketTick, boost::lockfree::capacity<1024>>`. Header-only. Same harness apart from the queue type. Sanity check on the hand-rolled implementation, not a competing variant.

3. **`mutex-condvar`** — `std::queue<MarketTick>` + `std::mutex` + `std::condition_variable`. Standard deployed pattern: producer locks, pushes, `notify_one`; consumer `wait`s on condvar predicate, locks, pops, unlocks. No artificial slowdowns.

**On the boost comparison.** If the hand-rolled queue tracks boost within roughly ±10% across the distribution (at p50 and p99.9), the post states so plainly — useful credibility check. If hand-rolled is materially slower, the post addresses it head-on rather than hiding it; that's the rigour signal. If hand-rolled is materially **slower** than boost by more than ~15%, flag for review before publication — do not silently re-tune and re-measure without telling Gareth.

## Measurement methodology

### Timestamp source

`rdtscp` with serialising load fence. Captured cycle count converted to nanoseconds via TSC calibration:

- At startup, sample `rdtscp` and `clock_gettime(CLOCK_MONOTONIC_RAW)` over a 100 ms window. Compute `ns_per_cycle`.
- Record `tsc_ns_per_cycle` in the JSON `machine` block.
- Verify `constant_tsc` and `nonstop_tsc` flags are present in `/proc/cpuinfo` at startup. Abort with a clear error if absent.
- Capture the calibration cycle count at start and end of each variant's 5 runs. If drift exceeds 0.1% across the 5 runs, flag in the run output.

CLOCK_MONOTONIC_RAW alone is unsuitable — its syscall overhead is in the same order of magnitude as the lock-free signal we're trying to measure.

### Per-item timestamping, not sampled

Two pre-allocated `std::vector<uint64_t>` buffers per run, each sized `items_measured` (1M), allocated at startup before the hot loop. Producer writes its enqueue cycle into buffer A at index `i`. Consumer writes its dequeue cycle into buffer B at index taken from the tick's `seq` field (which the producer set to `i` before enqueue). Each thread writes sequentially to its own buffer — cache-friendly, no inter-thread traffic from the timestamping itself.

Sampling would truncate the tail at the exact place we care about (p99.9 needs ≥1000 samples in the tail; 1M samples gives ample headroom).

### Latency definition

`latency_i = (dequeue_ts[i] - enqueue_ts[i]) * tsc_ns_per_cycle`, in nanoseconds.

- Enqueue timestamp captured immediately **before** the producer's `try_push` (or condvar variant equivalent).
- Dequeue timestamp captured immediately **after** the consumer's `try_pop` returns true.

State this definition explicitly in the post — the audience will read it pedantically.

### Histogram binning

Log-spaced, 16 sub-buckets per doubling. Bucket function (deterministic, no library dependency):

```
bucket(0)        = 0
bucket(1..15)    = value                   (linear at the low end)
bucket(v >= 16): high_bit = floor(log2(v))
                 sub      = (v >> (high_bit - 4)) & 0xF
                 result   = 16 + (high_bit - 4) * 16 + sub
```

Implementation in `bench/common/histogram.h` using `__builtin_clzll`. Branch-free hot path. Binning happens post-run, not in the hot loop — the hot loop only writes raw timestamps.

- `bucket_count`: 384, covers 1 ns up to ~256 ms.
- Anything that lands in the top bucket is a measurement contaminant (kernel preemption, page fault, scheduler hiccup). CC logs the count to stderr and flags it in the run output; benchmark does not abort.

### Throughput

Saturated only. Both threads loop as fast as they can. Reported as `ops_per_sec = items_measured / total_wall_time_sec`, single number per variant.

Offered-load and bursty workloads explicitly out of scope (mentioned in post's "what this doesn't show").

## Schema additions

The existing per-run schema gains one optional sibling of `ns_per_op` named `latency_ns`. Schema does **not** change for existing demos.

```json
{
  "variant": "lockfree-handrolled",
  "n": 1024,
  "items_measured": 1000000,
  "items_warmup": 100000,
  "iterations": 5,
  "ns_per_op": {
    "median": 47,
    "min": 38,
    "p99": 123,
    "iqr": 5
  },
  "ops_per_sec": 21276595,
  "latency_ns": {
    "scheme": "log2_subbuckets_16",
    "bucket_count": 384,
    "min_bucket_ns": 1,
    "counts": [0, 0, 0, 0, 12, 47 /* ... 384 entries total */],
    "stats": {
      "count": 5000000,
      "min": 38,
      "max": 8201,
      "p50": 47,
      "p90": 65,
      "p99": 123,
      "p99_9": 412
    }
  }
}
```

Notes:

- `ns_per_op.median`, `min`, `p99` duplicate `latency_ns.stats.p50`, `min`, `p99` — kept for compatibility with `<ThroughputBars>` reading from `ns_per_op`. Computed from the same merged histogram.
- The `scheme` field is a string identifier of the bucketing scheme; `"log2_subbuckets_16"` is the only currently defined value. Chart code reconstructs boundaries from `scheme` + `bucket_count` alone. Future schemes can be added without breaking existing data.
- `machine` block gains one field: `"tsc_ns_per_cycle": 0.357` (calibration result).

## Hardware gotchas baked into implementation

- Producer pinned to **core 4**, consumer to **core 5** via `pthread_setaffinity_np`. Both threads verify their affinity at the top of their function via `sched_getcpu()` against an expected value; benchmark aborts on mismatch.
- Cores 4 and 5 are both on **CCX1** of the 3800X (same L3 slice). Same-CCX configuration is the headline. Cross-CCX deferred. Document in post's "what this doesn't show."
- Cache-line size 64 bytes on Zen 2. In `spsc_queue.h`: `head_` and `tail_` each `alignas(64)` and padded with a 64-byte trailing pad. Ring buffer storage `alignas(64)`.
- Memory ordering audit: each `std::atomic` load and store has an explicit `memory_order` argument plus a one-line comment explaining why it's chosen. `acquire`/`release` only — no `seq_cst` in the hot path.
- TSC calibration: verify `constant_tsc`, `nonstop_tsc` in `/proc/cpuinfo`, and `__builtin_cpu_supports("invariant_tsc")`. Abort cleanly with a diagnostic message if any is missing.

## Build / file layout

```
bench/
├── common/
│   ├── perf_wrapper.h            # existing
│   ├── stats.h                   # existing
│   ├── machine_info.h            # existing
│   └── histogram.h               # NEW: log-spaced binning + JSON serialisation
├── demos/
│   └── 04-spsc-queue/
│       ├── CMakeLists.txt
│       ├── README.md
│       ├── tick.h                # MarketTick POD
│       ├── spsc_queue.h          # hand-rolled SPSC ring buffer
│       └── benchmark.cpp         # dispatches all 3 variants
```

CMakeLists locates Boost via `find_package(Boost 1.74 REQUIRED)` (header-only use, but pin a minimum version for reproducibility). Document the Boost installation step in the demo README.

Single binary `04-spsc-queue` accepts the variant name as `argv[1]`: `lockfree-handrolled | lockfree-boost | mutex-condvar`. `scripts/run_one.sh 04-spsc-queue` orchestrates running all three (5 iterations each, merging histograms) and emits the combined JSON to `site/src/data/perf/04-spsc-queue.json`.

## Site additions

- `site/src/data/perf/04-spsc-queue.json` — benchmark output.
- `site/src/posts/04-spsc-queue.mdx` — the post.
- `site/src/components/charts/LatencyHistogram.tsx` — new chart component.

### `<LatencyHistogram>` contract

```jsx
<LatencyHistogram
  slug="04-spsc-queue"
  variants={["lockfree-handrolled", "lockfree-boost", "mutex-condvar"]}
  view="ccdf" // "ccdf" (default) | "pdf"
  markers={["p50", "p99", "p99_9"]} // optional; only honoured for view="ccdf"
/>
```

Both views read from the same `latency_ns` block of the same JSON. Toggling `view` does not refetch. Bucket boundaries reconstructed from `scheme` + `bucket_count` only — never relies on per-variant bucket arrays (which the JSON does not contain). All variants share boundaries by construction.

Uses `components/charts/theme.ts` for palette, typography, axis treatment. No new theme additions required; reuse existing variant colours from prior demos.

**CCDF view** (canonical for tail-latency claims):

- y-axis: `1 − CDF`, log scale, range `1.0` down to roughly `1e-6` (auto-fit to actual data with a sensible floor).
- x-axis: latency in ns, log scale.
- One line per variant. 2 px stroke, no fill.
- Markers: dashed vertical lines at p50 / p99 / p99.9 of the **headline variant** (first entry in `variants`), each labelled at the top with the stat name and its value. Markers help the reader anchor the curve.

**PDF view** (distribution shape):

- y-axis: count per bucket, log scale (since the lock-free variant is sharply peaked and the mutex variant is broad — linear y crushes one or the other).
- x-axis: latency in ns, log scale.
- One area per variant: 20% opacity fill + 1 px stroke, same palette as CCDF.
- No markers.

### `<Benchmark>` MDX wrapper extension

Add `chart="latency-histogram"` as a recognised value. Forward `view` and `markers` props through to the underlying component. Existing wrapper behaviour for other chart types unchanged.

## MDX post structure (`04-spsc-queue.mdx`)

1. **Hook** — "Same queue API. Different tail by [Nx — fill from data]. End-to-end enqueue-to-dequeue, market-data thread to strategy thread."
2. **Setup** — one paragraph: market-data thread → strategy thread, what's being measured (enqueue start to dequeue return), three variants in one sentence each.
3. **Code** — `<CodeCompare lang="cpp" naive={mutexSrc} optimized={lockfreeSrc} labels={["Mutex + condvar", "Lock-free SPSC"]} highlightLines={[...]} />`. Show the hot path of each. Boost variant is one line; mention inline in prose rather than in the code comparison.
4. **Headline numbers** — `<LatencyHistogram slug="04-spsc-queue" view="ccdf" />`. Caption: the visible factor between curves at p99.9, and a pointer at the marker line.
5. **Distribution shape** — `<LatencyHistogram slug="04-spsc-queue" view="pdf" />`. One paragraph on what the PDF view shows that the CCDF doesn't: the lock-free distribution is sharply peaked; the mutex distribution is typically bimodal (fast path when contention is absent, condvar wake-up tail when it isn't).
6. **Throughput** — `<ThroughputBars slug="04-spsc-queue" stat="ops_per_sec" />` as a supporting view. State explicitly that the throughput gap is much smaller than the tail gap — the lock-free win is about determinism, not raw rate.
7. **Mechanism** — short section on why the tail collapses: no kernel transition, no lock fairness queue, no condvar wake-up latency. The mutex hot path is fast; its cold path involves a syscall and a scheduler decision.
8. **Boost comparison** — one paragraph stating how the hand-rolled queue tracks `boost::lockfree::spsc_queue` across the distribution. Honest discussion if they diverge.
9. **What this doesn't show** — same-CCX only, single producer/consumer, saturated throughput only, fixed item size and queue depth, no offered-load or bursty workloads. One line each.
10. **Takeaway** — the lock-free win isn't throughput, it's determinism. For latency-sensitive paths where p99.9 dictates correctness, the lock-free SPSC is non-negotiable.
11. **Methodology link.**

## Acceptance criteria

- `cd bench && cmake -B build && cmake --build build` builds the demo (and all prior demos still build).
- `./scripts/run_one.sh 04-spsc-queue` runs all three variants × 5 iterations, merges histograms, and emits a valid `04-spsc-queue.json` matching the extended schema.
- Standalone stress test for each variant: 10M items round-trip, zero losses, zero out-of-order delivery (verifiable via the `seq` field).
- `latency_ns` block present for all three variants with identical `scheme` and `bucket_count`.
- p99.9 reproducible across reruns to within 20%.
- Top bucket count (bucket 383) is zero across all variants; CC flags otherwise.
- `cd site && npm install && npm run dev` succeeds; `npm run build` produces a clean static export.
- Post page renders the CCDF view, the PDF view, and the throughput supporting chart.
- Markers visible and labelled on the CCDF view.
- Lighthouse performance ≥ 90 on the post page.

## Open items for CC to flag

- `rdtscp` availability and stability on the reference kernel (`constant_tsc` + `nonstop_tsc` in `/proc/cpuinfo`; `__builtin_cpu_supports("invariant_tsc")` returns true). Document the resolved state in the demo README.
- TSC frequency drift across the 5 runs — if measured drift exceeds 0.1%, surface it in the JSON output and the post.
- If hand-rolled SPSC diverges from boost's `spsc_queue` by more than ~15% at either p50 or p99.9, flag for review before publishing.
- Whether `boost::lockfree::spsc_queue<T, capacity<N>>` (fixed compile-time capacity) is the right choice vs the runtime-sized form. Pick one, document.
- Whether to also capture cache-miss counters per variant in the JSON (perf-stat plumbing exists from demo 2). Default: yes if cheap, no if it requires a separate run.

## Out of scope

- MPSC, SPMC, MPMC queue variants.
- Cross-CCX measurement (deferred to a future Zen 2 topology post).
- Cross-language comparisons (Rust, Go, etc.).
- Offered-load and bursty workload scenarios.
- The spin-check-without-condvar mutex variant — separates wake-up cost from lock cost; that's a different post.
- Item sizes other than the 16-byte `MarketTick`.
- Queue depths other than 1024.
- AVX-512.
