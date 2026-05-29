# Crucible — Demo 04 (SPSC) fix-up brief

Companion to `BRIEF.md` and `crucible-handover.md`. This brief specifies the changes required to make demo 04 (lock-free SPSC vs mutex queue) defensible to a skeptical hedge-fund reviewer. Scope: change what is measured, fix harness asymmetries, regenerate data, rewrite affected post sections. Component contracts and the overall data-schema shape are unchanged; the schema gains additive fields only.

This brief assumes the v1 brief and handover are loaded. It references the existing files at `bench/demos/04-spsc-queue/` and `site/src/posts/04-spsc-queue.mdx`.

## Why this revision

The original demo measured "end-to-end enqueue→dequeue latency" with a producer running flat-out into queues of different effective depths. By Little's law (avg queue depth = latency × throughput), the resulting numbers were:

| Variant               | Throughput | p50 latency | Implied avg queue depth                     |
| --------------------- | ---------- | ----------- | ------------------------------------------- |
| `lockfree-handrolled` | 19.7 M/s   | 352 ns      | ~7 items (queue near-empty)                 |
| `lockfree-boost`      | 15.8 M/s   | 65,536 ns   | ~1036 items (saturated at 1023 cap)         |
| `mutex-condvar`       | 4.1 M/s    | 18.87 ms    | ~77,400 items (unbounded queue building up) |

The post interpreted these as queue-operation latency. They are queue-residency time at three different effective queue depths. Three structural problems followed:

1. **Boost vs handrolled** — Boost saturated its 1024-slot ring while handrolled didn't. The 200× gap reads as a Boost defect but is actually rate-balance dependent: the slower per-op variant saturates first, and its "latency" then becomes `capacity × consumer_period`.
2. **Mutex queue was unbounded** — `std::queue` has no capacity limit, so the producer had no back-pressure. ~77 K items accumulated; the resulting "latency" is mostly time spent sitting in a deep FIFO, not condvar wake-up cost.
3. **Asymmetric warmup and timestamp placement** between variants.

This revision moves the headline measurement to a paced offered-load regime where the queue stays near-empty for all three variants, so the reported latency reflects per-op cost plus (for mutex) condvar wake-up time. Saturation behaviour is shown separately as a latency-vs-offered-load sweep, with the mechanism (queue depth × consumer period) honestly named.

Reference numbers in this brief assume re-measurement on the existing rig. Targets are shape-of-result, not values.

## Conceptual change to the harness

Replace the single saturated-throughput mode with two measurement modes. The headline becomes the paced mode.

### Mode A — paced offered load (the new headline)

A producer that issues items at a fixed inter-arrival period well below the slowest variant's sustainable throughput. At low offered load the queue stays near-empty in all three variants, so reported latency is per-op queue cost plus (for the mutex variant) condvar wake-up time. This is the comparison the post wants to make.

Target offered load: 1 M items/sec (1 µs inter-arrival). All three variants should easily sustain this; queue depth should stay in single digits.

### Mode B — load sweep (the new "under saturation" section)

A series of paced runs sweeping offered load from 100 k/s up to and past each variant's saturation point. Charted as p50/p99/p99.9 latency vs offered load, all three variants overlaid. The mutex curve should hockey-stick well before the lock-free curves. This is where the "tail collapses" story now lives — honestly attributed to the rate at which each variant breaks down.

Both modes run for `ITEMS_MEASURED = 1,000,000` per run × `NUM_RUNS = 5`.

## C++ changes

### `bench/demos/04-spsc-queue/benchmark.cpp`

**Pacing helper.** Compute `target_period_cycles` from offered load and the calibrated `ns_per_cycle`. Inside the producer loop, before stamping `enq_ts[i]`, busy-wait with `_mm_pause()` until `rdtscp_ordered() >= next_release_cycles`, then increment `next_release_cycles += target_period_cycles`. Stamp the enqueue timestamp after the wait, immediately before `try_push` / `push` / locked `q.push()` — preserves the existing contract.

**Symmetric warmup across all three variants.** The mutex variant already uses a `warmup_consumed` atomic to drain warmup before measurement; replicate the same pattern in `run_lockfree_handrolled` and `run_lockfree_boost`. The producer must observe `warmup_consumed.load(acquire) == ITEMS_WARMUP` before starting the measurement loop, in all three variants.

**Symmetric timestamp placement.** In `run_mutex_condvar`, move `deq_ts[t.seq] = rdtscp_ordered()` from inside the lock to immediately after `lk.unlock()`. The lock-free variants already timestamp outside the synchronisation primitive. This removes ~50–100 ns of lock-holding bias from the mutex measurement.

**Bound the mutex queue.** Replace `std::queue<MarketTick>` + raw `std::mutex` + `std::condition_variable` pair with a bounded variant: same `std::queue` under a mutex, plus a second condition variable. Producer waits on `cv_not_full` while `q.size() >= QUEUE_DEPTH`. Consumer notifies `cv_not_full` after each pop. Producer notifies `cv_not_empty` (rename existing `cv` to this for clarity) after each push. This matches the lock-free 1024-slot back-pressure semantics.

**CLI surface.** Replace the current variant-only invocation:

```
bench_04_spsc_queue <variant>
bench_04_spsc_queue --machine-info
bench_04_spsc_queue --stress-test [variant]
```

with:

```
bench_04_spsc_queue <variant> --mode paced     --rate-hz <N>
bench_04_spsc_queue <variant> --mode saturated
bench_04_spsc_queue <variant> --mode sweep     --rate-from <N> --rate-to <N> --steps <K>
bench_04_spsc_queue --machine-info
bench_04_spsc_queue --stress-test [variant]
```

Default mode is `paced` at 1,000,000 Hz. `saturated` is retained for the secondary saturation discussion and for sanity-checking throughput. `sweep` produces a series of paced runs and emits per-step results into a single `runs[]` array; one JSON file covers all sweep points.

**Empirical warmup verification.** Add a `--verify-warmup` flag. When set, the binary writes two separate histograms — items 0–10,000 of measurement and items 100,000+ — and prints their p50/p99 to stderr. The goal is a one-time check that the first ~1024 items don't show a different distribution after the warmup-drain fix. Result of this check goes into the README under a "Warmup verification" subsection. Not committed as part of the per-run JSON.

**Histogram percentile convention.** In `histogram.h` (existing — adjust only the reporting path), change percentile output to return bucket _midpoints_ rather than upper bounds. Document the convention as a comment in the JSON: add `"percentile_convention": "log2_bucket_midpoint"` next to `"scheme"`. Update the `max` field to be guaranteed ≥ any reported percentile by either returning the raw sample max or clamping the top percentile bucket. The current state (`max < p99_9`) must not recur.

### `bench/demos/04-spsc-queue/spsc_queue.h`

Add defensive static asserts near the top of the class:

```cpp
static_assert(sizeof(PaddedAtomic) == 64,
              "PaddedAtomic must occupy exactly one cache line");
static_assert(offsetof(SPSCQueue, tail_) - offsetof(SPSCQueue, head_) >= 64,
              "head_ and tail_ must be on separate cache lines");
```

The first is straightforward. The second protects against future class-layout changes that would put head and tail on the same line. Cost: zero runtime, three lines.

### `bench/common/machine_info.h`

**Fix `isolated_cpus` reporting.** Current output `"0-7"` (claiming all cores isolated) is wrong; cores 1–7 are actually isolated, core 0 is not. Parse `/proc/cmdline` for the `isolcpus=` substring and report its value verbatim, falling back to the cset cgroup state with an explicit `"isolated_cpus_source": "cgroup"` if cmdline parsing fails. Expected output on the reference machine: `"1-7"`.

**Capture `lscpu --extended`.** Add a field `"lscpu_extended": "<output>"` to the machine block, populated by `popen("lscpu --extended", "r")` at machine-info collection time. This makes CCX topology visible in the data and protects future runs on different hardware from silently invalidating the post's "same CCX" claim.

### `bench/demos/04-spsc-queue/CMakeLists.txt`

No changes required.

### `bench/scripts/run_one.sh`

Update the demo-04 branch to invoke both modes and merge their outputs into a single `04-spsc-queue.json`:

- Paced run: one invocation per variant at 1 MHz offered load
- Sweep run: one invocation per variant covering 100 k/s → 25 M/s in 8 log-spaced steps (or whatever falls naturally; aim for 2–3 points below saturation and 2–3 past saturation for each variant)

Result file structure: see Data schema section below.

## Data schema changes

Schema is additive; existing fields preserved. Two changes:

The `runs[]` array now contains entries from both paced and sweep modes. Distinguish via a new `mode` field and an `offered_rate_hz` field:

```json
"runs": [
  {
    "variant": "lockfree-handrolled",
    "mode": "paced",
    "offered_rate_hz": 1000000,
    "n": 1024,
    "items_measured": 1000000,
    "iterations": 5,
    "ns_per_op": {...},
    "ops_per_sec": ...,
    "latency_ns": {
      "scheme": "log2_subbuckets_16",
      "percentile_convention": "log2_bucket_midpoint",
      "bucket_count": 384,
      "min_bucket_ns": 1,
      "counts": [...],
      "stats": {...}
    },
    "top_bucket_count": 0,
    "calibration_drift_pct": 0.0
  },
  {
    "variant": "lockfree-handrolled",
    "mode": "sweep",
    "offered_rate_hz": 100000,
    ...
  }
]
```

Each run keeps its existing `ns_per_op`, `ops_per_sec`, `latency_ns.{counts, stats}`, `top_bucket_count`, `calibration_drift_pct` fields. The `<Benchmark>` MDX component already filters by `variants`; extend its filter to also accept `mode` and `offered_rate_hz`.

## Site changes

### `site/src/components/Benchmark.tsx`

Extend the props interface to support filtering by `mode` and `offered_rate_hz`:

```tsx
<Benchmark slug="..."
           chart="latency-histogram"
           variants={[...]}
           mode="paced"
           offered_rate_hz={1000000}
           markers={["p50","p99","p99_9"]} />
```

Existing posts that don't pass `mode` default to `"paced"` for charts that have multiple modes available, falling through to the only available mode otherwise. Preserves backward compatibility with demos 01–03.

### `site/src/components/charts/`

Add `LatencyVsLoad.tsx` — a line chart with x = offered load (log scale, Hz), y = latency (log scale, ns), one line per (variant, statistic) pair. Statistics shown: p50, p99, p99.9. Markers indicating each variant's empirical saturation point (where p99 diverges sharply from p50). Uses `components/charts/theme.ts` for palette and typography.

Register the chart as `chart="latency-vs-load"` in the `<Benchmark>` dispatcher.

### `site/src/posts/04-spsc-queue.mdx`

Substantive rewrite. New structure:

1. **Hook** — at moderate offered load, all three variants look similar at the median; the tail and the breakdown rate are where they diverge.
2. **Setup** — keep current variant descriptions. Add: "all three variants use a 1024-slot bounded queue; mutex variant uses a paired condvar for not-full back-pressure." Add: "the producer is paced at 1 M items/sec for the headline measurements, well below the sustainable throughput of any variant."
3. **The code** — `<CodeCompare>` now shows both sides with timestamping included, including the post-`unlock()` timestamp on the mutex side. Use `labels={["Mutex + condvar (bounded)","Lock-free SPSC"]}`.
4. **Headline — tail latency at 1 MHz offered load** — `<Benchmark mode="paced" offered_rate_hz={1000000} chart="latency-histogram" view="ccdf" markers={["p50","p99","p99_9"]} />`. CCDF on log-log axes; this is the chart that justifies the "lock-free wins on the tail" claim, with the queue near-empty so the difference is genuinely kernel-wake-up cost.
5. **Distribution shape** — `<Benchmark mode="paced" ... view="pdf" />`. Keep the bimodal-mutex commentary; it's actually visible at this load level.
6. **What happens as offered load rises** — new section. `<Benchmark mode="sweep" chart="latency-vs-load" variants={["lockfree-handrolled","lockfree-boost","mutex-condvar"]} />`. Discuss where each variant's tail breaks down. Mutex tail will diverge from p50 well before lock-free does. This is where "the tail collapses" lives now, with the mechanism (queue saturating because consumer can't keep up) honestly named.
7. **Throughput** — keep current section; throughput numbers come from the `saturated` mode results in the JSON.
8. **Why the tail collapses** — keep the kernel-boundary explanation but tighten the attribution: at low load, the tail is the kernel wake-up path; at high load, it's the kernel path _plus_ queue saturation. The post should not blur the two.
9. **Boost comparison** — Boost should now track handrolled within ±20% at p50 and p99.9 under paced load. If it doesn't, that's a genuine finding worth a paragraph; if it does, the credibility-check framing works as originally intended.
10. **What this doesn't show** — keep most items. Remove "Fixed queue depth: 1024 entries" as a caveat (it's now true of all three variants and stated up front). Add: "Best-case offered load was 1 MHz — well below saturation. Behaviour at near-saturation loads is shown in the load-sweep section but not exhaustively swept across queue depths."
11. **Takeaway** — unchanged in spirit; reword to match the new framing.

**Footer:** numbers regenerated from JSON. Fix "Turbo Boost on" → "Turbo Boost off" (the original was a copy-paste error; Turbo was off for the original run, confirmed by `machine.turbo: false` in the JSON). Where possible, generate the footer at build time from the JSON rather than hand-writing it, to prevent re-divergence.

## Acceptance criteria

- `cmake --build build --target bench_04_spsc_queue` succeeds.
- `bench_04_spsc_queue --machine-info` reports `"isolated_cpus": "1-7"` and includes a non-empty `"lscpu_extended"` field.
- `bench_04_spsc_queue lockfree-handrolled --mode paced --rate-hz 1000000` produces a JSON run with avg queue depth < 10 (verifiable via Little's law: `ns_per_op.median × ops_per_sec / 1e9`).
- All three variants under paced 1 MHz show median latency within a single order of magnitude of each other.
- `bench_04_spsc_queue --stress-test` continues to pass for all three variants (now including the bounded mutex variant).
- `04-spsc-queue.json` contains runs for paced mode (3 variants) and sweep mode (3 variants × ≥6 load steps).
- For every run in the JSON, `latency_ns.stats.max >= latency_ns.stats.p99_9`.
- The post renders all three charts (latency CCDF at 1 MHz, latency PDF at 1 MHz, latency vs offered load).
- Footer numbers match `latency_ns.stats` in the corresponding JSON runs, to two significant figures.
- MDX footer says "Turbo Boost off".
- `static_assert`s in `spsc_queue.h` compile cleanly; no behavioural change.
- README "Warmup verification" section reports the empirical 0–10k vs 100k+ comparison output once.
- Lighthouse perf score on the post page still ≥ 90.

## Out of scope

- Cross-CCX measurement (still deferred).
- A separate "spin-check-without-condvar" mutex variant (different post).
- Sweep over queue depths (1024 only; mention in caveats).
- Changing the histogram bucket scheme itself; only the percentile convention reporting is fixed.

## Open items CC should flag during implementation

- Whether pacing precision at 1 MHz is good enough on the reference rig; if `_mm_pause` spin is too noisy, fall back to a coarser pacing loop and document the actual jitter distribution.
- Whether the bounded mutex variant should use a single condvar (notify_all on every push/pop, accepting some thundering-herd cost) or two condvars (not-empty for consumer, not-full for producer). The brief assumes two; if there's a reason to use one, document and pick.
- Whether `lscpu --extended` output is stable enough across kernel versions to be a useful schema field, or whether a narrower capture (`/sys/devices/system/cpu/cpu*/cache/index3/shared_cpu_list`) is better.
- If Boost still diverges materially from handrolled under paced load: investigate (likely a hot-path difference in Boost's `spsc_queue::push`/`pop`) before publishing.
