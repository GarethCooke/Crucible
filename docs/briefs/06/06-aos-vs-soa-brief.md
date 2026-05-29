# Crucible — Demo 06: AoS vs SoA across the cache hierarchy

Implementation brief for Claude Code. Lands on the feature branch (`demo-6-aos-vs-soa` or equivalent, per-branch Amplify preview enabled). Self-contained — no further scoping decisions required beyond the named open items.

## Context

Sixth demo in the Crucible series. Builds on:

- `BRIEF.md` — v1 scaffold, locked schema, methodology, hardware spec.
- `crucible-handover.md` — per-demo process and lessons from demos 1–5.
- `demo-06-plan.md` — task tracker for this demo. This brief is task §2.
- `demo-06-teaser-brief.md` — already shipped to `main`: stub MDX at `site/src/posts/06-aos-vs-soa.mdx`, "In Progress" pill on the index card.
- `bench/calibration-notes/06-aos-vs-soa-pilot/README.md` — the §1 calibration pilot's notes file. Struct shape, working-set sweep, K sweep, and the thesis reframing in this brief are all derived from that file.
- Demo 1 (sorted vs unsorted) — provides the cache-hierarchy framing this post forward-links to from its DRAM-cliff section.
- Demo 3 (SIMD Black-Scholes) — provides the auto-vectorisation framing this post forward-links to from its SoA-scalar vs SoA-autovec comparison.

This demo:

- Reuses `<TimeVsN>` and `<ThroughputBars>` from the v1 scaffold. **May extend `<TimeVsN>`** with an L3/DRAM threshold marker (see §5 of the plan; chart-component decision is a separate task and out of scope for this brief).
- Adds no new chart components in this brief's scope. Any extension or new component is the chart-task PR.
- Adds new per-run schema fields (additive only) for working-set, hot-column-count, struct shape, and access pattern.
- Adds three layout/codegen variants under `bench/demos/06-aos-vs-soa/`.

When the feature branch merges to main, the merge replaces the stub MDX from the teaser brief with the full post, and removes the `status: "in-progress"` and `expectedAt` frontmatter fields.

## Story angle

**The §1 pilot reframed this demo.** The plan's original hedged thesis ("the AoS↔SoA crossover isn't where you'd naïvely place it") did not survive the data: on the reference machine, for sequential analytical scans, _there is no crossover_. SoA wins or ties at every `K` the sweep covers. What the pilot did surface is sharper and more pedagogically honest than the plan had aimed for. Two intertwined headline observations:

**1. The AoS bandwidth-amplification model.** For a 128 B / 16-field record with 8-byte fields and a 64 B cache line, AoS pays a bandwidth penalty proportional to `64 / (K × 8)` at small K — that is, AoS pulls a full cache line per record but uses only `K × 8` of the 64 bytes that line carries. At K = 1, AoS uses 1/8 of each fetched cache line; at K = 4, 1/2; at K = 8, exactly one line of useful work per record and the layouts tie. SoA pulls one cache line per _eight_ records at K = 1, which is the same `64 / (K × 8)` advantage from the column-store side. The pilot data fit that model within a few percent across the K row at DRAM-bound N. This is a one-line analytic model that the post can lead with.

**2. The cache hierarchy is binary, not staircase, for streaming AoS scans.** Zen 2's L1 stride prefetcher handles a perfectly-sequential scan with zero effort, hiding the L1→L2 and L2→L3 transitions completely. What survives is a single sharp L3→DRAM cliff: AoS at K = 1 stays at roughly the same per-element cost from L1-resident N right up to L3-resident N, then jumps by roughly 3.5× when the working set spills into DRAM. The honest reframing — "the cache hierarchy is a staircase in textbooks; in streaming scans it's a cliff" — is a stronger story than the plan's predicted L1/L2/L3/DRAM-staircase visual.

Hedge-fund-engineering framing in one paragraph: an option-chain scan walks millions of rows, picking off a handful of fields per row (mid, IV, delta, maybe size). The layout question is whether to store the chain as an array of fat option records (AoS) or as parallel column arrays (SoA). The bandwidth-amplification model says SoA wins linearly in the field-touch ratio, with no caveats and no hidden crossover. The post's value is the model, not a benchmark sales pitch — and the K = 8 parity point is the demo's _clever_ observation, not its anti-climax. At K = 8 with 8 B fields on a 64 B line, AoS fills the line with useful work and there's nothing left for SoA to exploit.

What the post does **not** claim:

- It does not claim "AoS is always wrong." At K = FIELDS (touch every field), the layouts tie. Workloads that touch every field of every record have no layout preference, and the post says so. The bandwidth-amplification model is _exactly_ the regime of preference.
- It does not generalise to random or strided access. The thesis is for sequential, contiguous-prefix field selection. The DRAM cliff and the missing staircase are both prefetcher-mediated, and a different access pattern would tell a different story.
- It does not compare against compressed columnar formats, hand-tuned SIMD beyond what the compiler emits, or NUMA-aware allocators. Each of those is a separate demo.
- It does not relitigate `__builtin_prefetch` advice. The demo is about layout, not prefetch hints.

The "What this doesn't show" section in the MDX must list all four of those explicitly.

## Workload

### The Record struct (AoS)

Fixed 128 B, exactly two cache lines, 16 fields of 8 bytes each:

```cpp
#pragma once
#include <cstdint>

struct alignas(64) RecordAoS {
    double f0,  f1,  f2,  f3;
    double f4,  f5,  f6,  f7;
    double f8,  f9,  f10, f11;
    double f12, f13, f14, f15;
};

static_assert(sizeof(RecordAoS) == 128, "RecordAoS must be 128 bytes (2 cache lines)");
static_assert(alignof(RecordAoS) == 64, "RecordAoS must be cache-line aligned");
```

Rationale: 128 B is the smallest size at which a contiguous-prefix scan of fewer than half the fields can leave bytes on the table. A 64 B struct fills one cache line at any K ≥ 1 and the demo dies (no bandwidth penalty to measure). 16 × `double` gives a clean K sweep covering bandwidth-waste ratios `64 / (K × 8)` ∈ {8, 4, 2, 1, 1} at K ∈ {1, 2, 4, 8, 16}.

`double` rather than `int64_t` so that the sum reduction's auto-vectorisation path emits AVX2 `vaddpd` and matches demo 3's framing for the SoA-autovec variant. The fields are not modelling option-chain semantics — the names `f0..f15` are deliberately abstract because the post is about the bandwidth model, not the application.

### The Record struct (SoA)

Sixteen parallel arrays of `double`, each aligned to 64 B. Wrapped in one container struct for ownership clarity:

```cpp
struct RecordSoA {
    alignas(64) std::vector<double> f0,  f1,  f2,  f3;
    alignas(64) std::vector<double> f4,  f5,  f6,  f7;
    alignas(64) std::vector<double> f8,  f9,  f10, f11;
    alignas(64) std::vector<double> f12, f13, f14, f15;

    explicit RecordSoA(size_t n)
        : f0(n),  f1(n),  f2(n),  f3(n),
          f4(n),  f5(n),  f6(n),  f7(n),
          f8(n),  f9(n),  f10(n), f11(n),
          f12(n), f13(n), f14(n), f15(n) {}
};
```

The `alignas(64)` on each `std::vector` member only aligns the vector _handle_ — the underlying buffer alignment is a separate concern. Use `std::aligned_alloc(64, n * sizeof(double))` wrapped in a unique_ptr-with-deleter, or replace `std::vector` with a thin `aligned_buffer<double>` type, to guarantee 64-byte alignment of the data itself. CC: pick whichever is cleaner; document the choice in the demo README.

Why 16 separate vectors rather than one big block partitioned 16 ways: future-proof against TLB-pressure stories. Sixteen separate large allocations land on sixteen separate page sets, so any TLB-pressure effect from SoA at very large N is honestly captured rather than hidden by a single mega-allocation that gets transparent huge pages assigned to it. (At the chosen N range it shouldn't matter on this hardware; the surprise budget says check it during preflight.)

### The kernel

A sum-reduction across `K` of the 16 fields, for all N records:

```cpp
// AoS scalar — touches first K fields of each of N records
double scan_aos(const RecordAoS* records, size_t n, int k) {
    double sum = 0.0;
    for (size_t i = 0; i < n; ++i) {
        const double* fields = &records[i].f0;
        for (int j = 0; j < k; ++j) {
            sum += fields[j];
        }
    }
    return sum;
}

// SoA scalar — touches first K columns, full N each
double scan_soa_scalar(const RecordSoA& s, size_t n, int k) {
    double sum = 0.0;
    const double* cols[16] = { s.f0.data(),  s.f1.data(),  s.f2.data(),  s.f3.data(),
                               s.f4.data(),  s.f5.data(),  s.f6.data(),  s.f7.data(),
                               s.f8.data(),  s.f9.data(),  s.f10.data(), s.f11.data(),
                               s.f12.data(), s.f13.data(), s.f14.data(), s.f15.data() };
    for (int j = 0; j < k; ++j) {
        const double* col = cols[j];
        for (size_t i = 0; i < n; ++i) {
            sum += col[i];
        }
    }
    return sum;
}
```

Notes:

- Access pattern is **sequential, contiguous-prefix**: K is the _number_ of fields touched, drawn from `{f0, f1, ..., f(K-1)}`. No strided or random pattern within the field set. State this explicitly in the MDX so a reader doesn't generalise to "any K-of-16" scans.
- The kernel returns a `double` so the sum can be sunk via `benchmark::DoNotOptimize(sum)` and the loop can't be dead-code-eliminated. Verify the assembly during implementation; if the compiler hoists the sum out, replace with a per-iteration `DoNotOptimize` or change the reduction to a predicate count.
- `k` is a runtime parameter so the kernel is compiled once, not template-instantiated per K. Confirm this doesn't lose more than a few percent vs a template-specialised version in calibration; if it does, switch to template specialisation. (The K loop is short — likely fully unrolled by the compiler — so the runtime-K cost should be invisible.)

### Auto-vectorised variant

`scan_soa_autovec` is `scan_soa_scalar` compiled without the per-column-loop vectorisation block. To produce a fair _scalar_ SoA baseline, `scan_soa_scalar` is compiled with `#pragma GCC ivdep` removed and `__attribute__((optimize("no-tree-vectorize")))` applied to the function (or `#pragma GCC optimize("no-tree-vectorize")` around it). The autovec variant has no such pragma and gets the project's default `-O3 -march=native`.

CC: verify with `objdump -d` that:

- `scan_aos` emits scalar loads (no `vmovapd`/`vaddpd` against AoS — strided 128 B access is not vectorisation-friendly).
- `scan_soa_scalar` emits scalar `vmovsd`/`vaddsd` and no packed-double instructions.
- `scan_soa_autovec` emits `vmovapd ymm`/`vaddpd ymm` over the column loop.

Record the verification result in the demo README. This is the same discipline as demo 3's verify.cpp.

## Variants

Three variants, all built with `-O3 -march=native -std=c++20`:

1. **`aos-scalar`** — `scan_aos` over `RecordAoS`. Scalar by physical necessity; AoS layout defeats vectorisation.
2. **`soa-scalar`** — `scan_soa_scalar` with vectorisation explicitly disabled. Isolates the bandwidth advantage of SoA from the SIMD advantage.
3. **`soa-autovec`** — `scan_soa_scalar` with vectorisation enabled (project default). The production SoA path. Stacks SIMD throughput on top of the bandwidth advantage.

Variant order in JSON and on charts: `aos-scalar`, `soa-scalar`, `soa-autovec`. This ordering tells the story in three reads: AoS baseline → SoA bandwidth win → SoA bandwidth × SIMD win.

## Measurement

### Mode

Single mode this demo. No paced / saturated / sweep distinction; the working-set axis is the equivalent of demo 4's load axis.

```
bench_06_aos_vs_soa <variant> --n N --k K [--iterations I]
bench_06_aos_vs_soa --machine-info
bench_06_aos_vs_soa <variant> --verify-codegen
```

Defaults: `iterations=5`. Variant names: `aos-scalar | soa-scalar | soa-autovec`.

The harness orchestrates the (N × K) grid sweep; the binary takes one (variant, N, K) tuple per invocation.

### Working-set sweep (N axis)

Nine points, doubling from L1-resident to DRAM-bound:

```
N ∈ {4 096, 8 192, 16 384, 32 768, 65 536, 131 072, 262 144, 524 288, 1 048 576}
```

In bytes of AoS data: 512 KB → 128 MB. Mapping against the reference machine's geometry (16 MB L3 / CCX, 512 KB L2 / core, 32 KB L1d / core):

| N         | AoS bytes | Resides in     | Notes                                           |
| --------- | --------- | -------------- | ----------------------------------------------- |
| 4 096     | 512 KB    | L2             | L1 too small (32 KB); smallest N is L2-resident |
| 8 192     | 1 MB      | L2/L3 boundary |                                                 |
| 16 384    | 2 MB      | L3             |                                                 |
| 32 768    | 4 MB      | L3             |                                                 |
| 65 536    | 8 MB      | L3             |                                                 |
| 131 072   | 16 MB     | L3 boundary    | At exactly L3 size — the cliff edge             |
| 262 144   | 32 MB     | DRAM           | Pilot's first DRAM-bound point                  |
| 524 288   | 64 MB     | DRAM           |                                                 |
| 1 048 576 | 128 MB    | DRAM           | Pilot's headline N                              |

The pilot showed the staircase from L2 → L3 is invisible under the stride prefetcher; the cliff at the 131 072 → 262 144 transition is what matters. The N values above 1 048 576 add nothing but capture time and are out of scope.

If a smaller N (e.g. 2 048 → 256 KB) would put the working set inside L1, add it during preflight if and only if it changes the story; the pilot suggests it won't, because the prefetcher hides L1 too.

### Hot-column sweep (K axis)

Five points: `K ∈ {1, 2, 4, 8, 16}`. Corresponds to bandwidth-waste ratios `64 / (K × 8)` of `{8, 4, 2, 1, 1}`. K = 8 is the "one cache line fully used" parity point; K = 16 is the "two cache lines fully used" parity point. K ∈ {1, 2, 4} are the bandwidth-amplification regime.

The pilot tried K = 12 to check for a discontinuity at the cache-line-fill boundary; it sits on the linear ramp between K = 8 and K = 16 in per-element time and adds nothing to the per-op view, so it is excluded. Document this exclusion in the demo README and in the post — a reader will ask.

### Total run count

3 variants × 9 N values × 5 K values × 5 iterations = **675 inner runs**, 135 (variant, N, K) cells in the JSON.

Per-cell timing target: each cell runs N records, K fields per record. Wall-clock per iteration on the reference machine is bounded by AoS-scalar at N = 1 048 576, K = 16: ~830 ns/element × 1 048 576 elements ≈ 870 ms per iteration. Five iterations × 5 (other variant/K combinations average lower) gives a total capture wall-clock in the ~10-minute range; an exact estimate falls out of the calibration step. Anything above an hour means something is wrong.

### Headline metric

`ns_per_op` is **time per Record element scanned**, not per field-byte and not per row × field. This is the per-element view that the pilot identified as the headline-supporting metric:

- It shows the AoS K = 1 cliff at L3→DRAM cleanly (5.46 ns at N = 1 048 576 in the pilot, ~1.5 ns at cache-resident N).
- It shows the K = 8 parity point cleanly (AoS and SoA both ~0.79 ns/element at N = 1 048 576).
- It is comparable across K — the reader can divide by K to get "ns per field-touch" if they want a different lens, but the post leads with the per-element view.

This is the same units convention as demos 1–5 after the pre-demo-5 `ns_per_op` units fix. The JSON's `ns_per_op.median` is the per-element median. The `ops_per_sec` field is `1e9 / ns_per_op.median`. The round-trip identity from the pre-demo-5 brief must hold.

### Perf-counter capture

Add to `tools/perf_capture.sh` for this demo (probably already there from demo 2's L1D-miss work):

- `cache-misses`, `cache-references` (existing)
- `l1d.replacement` with fallback to `L1-dcache-load-misses` (added in pre-demo-5 brief M5)
- `instructions`, `cycles` (existing — IPC computed downstream)

The post leans on cache miss rates to corroborate the bandwidth-amplification story: AoS at K = 1 in DRAM should have ~16× the LLC misses per Record element of SoA at K = 1. CC must verify this falls out of the captured data before the post commits the claim.

If `l1d.replacement` is still unavailable on this kernel/microarch, fall back gracefully and note in the JSON `notes` field that the L1D number is computed from the cache-references proxy.

### Warmup

500 ms or 100 iterations of the kernel, whichever is shorter, per (variant, N, K) cell. The cache-fill state of the previous cell is the wrong starting point; warmup ensures the steady-state cache resident set is established before measurement begins. Document the warmup pattern in the README.

## Capture environment

Stated explicitly because the demo's findings are prefetcher-dependent and prefetcher behaviour is environment-dependent.

- **Machine:** AMD Ryzen 7 3800X (Zen 2), the reference machine documented in `BRIEF.md` and on `/methodology`.
- **Boot:** Headless. The reference machine is booted to a console session with no `gnome-session`, no display server, no compositor running. The same configuration used for demos 1–5. The MDX's "Reproducing this" section must call this out: a desktop session running in the background changes the prefetcher's noise floor and the L3-cliff sharpness.
- **Isolation:** `isolcpus=0-7 nohz_full=0-7 rcu_nocbs=0-7` set via the project's dedicated GRUB entry.
- **Shield:** `sudo cset shield --reset` run **before** the capture session begins. This is the cpuset-v1 / PID-1-affinity workaround from demo 5's detour notes. Without it, a stale shield from a previous session can pin PID 1 to the wrong CPU set and the benchmark thread ends up co-scheduled with kernel work it should be isolated from. Demo 5 surfaced this; demo 6 names it as a precondition in `run_one.sh` and in the post's reproduction notes.
- **Pinning:** Single thread pinned to core 4 (CCX1) via `taskset -c 4` invoked by `run_one.sh`. Verified inside the binary via `sched_getcpu()` at thread start; mismatch aborts with a diagnostic. Same pattern as demos 4 and 5.
- **Turbo / governor:** `CRUCIBLE_TURBO=off` env var set; `cpupower frequency-info` shows governor = `performance`; `/sys/devices/system/cpu/cpufreq/boost` shows `0`. The binary asserts the turbo state and records it in the `machine` block. (CC: this is already in the harness from earlier demos; confirm it works for a single-threaded run, which is the only new thing about demo 6's threading model.)
- **SMT:** Off (BIOS). Verified at startup; mismatch aborts.
- **Outer repetitions:** ≥5 per (variant, N, K) cell. The reduce-over-iterations math is the same as demos 1–4.

This list is the contract for §6 of the plan (headline capture). The post's "Reproducing this" section restates it in a reader-friendly form with the precondition list checkable in one screen.

## Schema additions

All additive. Existing fields preserved. Per-run schema gains:

```json
{
  "variant": "aos-scalar",
  "n": 1048576,                         // working-set element count (existing)
  "k": 1,                               // NEW — hot-column count (1..16)
  "struct_size_bytes": 128,             // NEW — for the bandwidth-amplification model annotation
  "struct_field_count": 16,             // NEW
  "field_type_bytes": 8,                // NEW — sizeof(double)
  "access_pattern": "sequential",       // NEW — fixed for this demo, but in JSON for forward-compat
  "kernel": "sum_reduction",            // NEW — fixed for this demo
  "iterations": 5,                      // existing
  "items_measured": 1048576,            // alias for n in this demo
  "items_warmup": 0,                    // warmup is wall-clock-bounded, not item-count-bounded
  "warmup_ms": 500,                     // NEW — wall-clock warmup window
  "ns_per_op": { "median": ..., "min": ..., "p99": ..., "iqr": ... },
  "ops_per_sec": ...,
  "llc_misses_per_op": 0.123,           // existing pattern (cache-misses / records_scanned)
  "l1d_misses_per_op": 0.456,           // existing pattern, from l1d.replacement
  "instructions_per_cycle": 1.8,        // existing
  "captured_at": "..."                  // existing
}
```

The `<Benchmark>` MDX component filters by `variants`, `mode`, `n`, etc. Confirm it can also filter by `k` and `n` together for this demo's grid; extend its contract if not. Surface the extension in the chart-task PR (§5), not in this brief.

The `machine` block gains no new fields.

## Hardware gotchas baked into implementation

- **Single thread, single core.** No threading model; pinned to core 4 (CCX1) only. The other 7 isolated cores are idle for the duration of the run. The full 16 MB of L3 on CCX1 is therefore effectively available to the pinned core under isolation.
- **Buffer alignment.** Every working buffer (the AoS array and each of the 16 SoA columns) is 64-byte aligned. The AoS struct is `alignas(64)` (the compiler guarantees this for the array). The SoA columns are allocated via `aligned_alloc` or an aligned-buffer wrapper.
- **TLB.** At N = 1 048 576, AoS is 128 MB — ~31 250 4-KB pages, or 62 2-MB transparent huge pages. The Zen 2 L1 dTLB is 64 entries; the L2 dTLB is 2 048. At 4 KB pages this exceeds L1 dTLB at the smallest DRAM-bound N. If transparent huge pages are enabled (typical Ubuntu default `madvise` or `always`), the working set fits comfortably in L2 dTLB across the whole sweep. Check `cat /sys/kernel/mm/transparent_hugepage/enabled` and record the setting in the JSON `notes`. If the setting is `never`, document that the post's TLB story may differ; if `madvise` or `always`, the post can ignore TLB as a confound.
- **NUMA.** Single NUMA node on this socket. No cross-node concern.
- **Prefetcher.** Zen 2 has a streaming/stride prefetcher in L1 that is the central confound for goal A of the pilot (no L1/L2/L3 staircase visible on streaming AoS). The demo doesn't disable the prefetcher — the realistic-workload framing requires the prefetcher on. The MDX must name the prefetcher explicitly when explaining the missing staircase. The reproduction notes do not ask the reader to tweak any MSR.
- **Vectorisation verification.** As above (`objdump -d` check), recorded in the README. Demo 3's same discipline.
- **Compile-time constants.** `K`, `N`, and `kernel` are runtime parameters to defeat constant folding. Inputs are runtime-loaded (random `double`s, seeded RNG with a fixed seed documented in the README). Sums are sunk via `DoNotOptimize`. Same discipline as every previous demo.

## Build / file layout

```
bench/
├── common/                                # existing
│   ├── perf_wrapper.h
│   ├── stats.h
│   ├── machine_info.h
│   └── histogram.h                        # not used by demo 6 (kept here)
├── demos/
│   └── 06-aos-vs-soa/
│       ├── CMakeLists.txt
│       ├── README.md
│       ├── record.h                       # RecordAoS + RecordSoA
│       ├── kernels.h                      # scan_aos, scan_soa_scalar, scan_soa_autovec
│       ├── verify.cpp                     # codegen verification (objdump-driven sanity check)
│       └── benchmark.cpp                  # dispatches the three variants
```

Single binary `bench_06_aos_vs_soa`. CMakeLists is conventional: include `bench/common/`, C++20, `-O3 -march=native`. Per-TU compile flags for the scalar-SoA variant — see §Variants on disabling vectorisation. No external dependencies new beyond what demos 1–5 already require.

`bench/scripts/run_one.sh 06-aos-vs-soa` orchestrates the full capture: 135 cells × 5 iterations each, output written to `site/src/data/perf/06-aos-vs-soa.json`. The script must:

1. Verify `cset shield` state is reset (`sudo cset shield --reset || true` at the top — idempotent).
2. Verify `CRUCIBLE_TURBO=off` is exported.
3. Iterate (variant, N, K) in the order that minimises cache cross-pollination between adjacent cells: outer loop variant, middle loop N descending, inner loop K. (Descending N means each warmup walks into a smaller working set than the previous cell's measurement, avoiding the "previous-cell's-tail-still-resident" scenario.)
4. Emit one JSON file at the end, not 135 partial files.

## Site additions

When the feature branch merges to main, these changes overwrite the stub from the teaser brief:

- `site/src/posts/06-aos-vs-soa.mdx` — full post (replaces stub).
- Frontmatter: remove `status: "in-progress"` and `expectedAt`. Set `date` to the capture date. Refine `excerpt` to match the reframed thesis (the stub's excerpt mentions "the crossover" — replace with bandwidth-amplification language).
- `site/src/data/perf/06-aos-vs-soa.json` — main JSON output.
- Possibly `site/src/components/charts/TimeVsN.tsx` extension or a new chart component (§5 of the plan; out of scope for this brief).

### Chart shape implications (no component commitment)

The data's natural views, ordered by importance to the post's argument:

1. **The DRAM cliff.** `ns_per_op` (per-element time) on y-axis, N on x-axis (log scale, element count or bytes), one line per `aos-scalar` at K = 1. The cliff at the 131 072 → 262 144 transition is the visual. An L3-size threshold marker on the x-axis makes it explicit.
2. **The bandwidth-amplification fan.** Same chart shape as (1), with one line per K ∈ {1, 2, 4, 8, 16} for `aos-scalar`. At cache-resident N the lines compress into a band; at DRAM-bound N they fan out by the `64 / (K × 8)` factor.
3. **The model fit.** Bar chart or annotated line: AoS/SoA ratio on y-axis, K on x-axis (1, 2, 4, 8, 16), at fixed DRAM-bound N. Overlay the predicted `64 / (K × 8)` model. The bars fit the model to within a few percent — that's the headline picture in compact form.
4. **The SIMD comparison.** `<ThroughputBars>` at the headline (N, K) = (1 048 576, 1) corner: `aos-scalar`, `soa-scalar`, `soa-autovec`. Shows SIMD's contribution on top of the bandwidth advantage. Forward-links to demo 3.

The plan's §5 settles which existing component handles each view and whether a new component is needed. This brief's contract is the data; the chart-task PR delivers the visualisation.

### Post structure (MDX)

Adapt the structure from demo 5. Required sections, in order:

1. _Opening framing_ — option-chain-scan motivation, one paragraph, capital-markets framing.
2. _The two thesis observations_ — bandwidth-amplification model and the missing staircase / DRAM cliff. Both as stated above; no hedging on either.
3. _Setup_ — Record struct (AoS and SoA layouts), kernel, sequential contiguous-prefix access pattern.
4. _The headline: AoS K = 1 across the cache hierarchy_ — the DRAM-cliff chart. Discuss why the L1/L2/L3 transitions don't show up (stride prefetcher), forward-link to demo 1 for the underlying cache-hierarchy concepts.
5. _The bandwidth-amplification model_ — the K-sweep ratio chart with model overlay. The `64 / (K × 8)` line and a paragraph deriving it from cache-line geometry.
6. _The K = 8 parity point_ — the demo's clever observation. At K = 8 the layouts tie; this isn't an anti-climax, it's the model's prediction. Explain.
7. _Stacking SIMD on top_ — `<ThroughputBars>` at headline (N, K). Forward-link to demo 3.
8. _What this doesn't show_ — explicit list per §Story angle: K-of-FIELDS workloads have no layout preference; random/strided access tells a different story; no compression / hand-SIMD beyond auto-vec / no NUMA; no prefetch-hint advice.
9. _Reproducing this_ — link to bench source, the run command, the headless-boot precondition, the `cset shield --reset` precondition, the hardware spec.
10. _Takeaway_ — bandwidth amplification + binary cache hierarchy.

Length target: comparable to or shorter than demo 5. Do not pad. Every chart needs a paragraph that says what the reader is supposed to see, written from the captured JSON after capture, not from the brief's expectations.

Cross-links per the plan §7:

- _Forward-links inserted in demos 1 and 3 to demo 6._ Demo 1's cache-hierarchy intro section gains a one-line "and this is the layout question that runs on top of it — see demo 6." Demo 3's vectorisation conclusion gains a one-line "the SoA layout that makes this possible is its own story — see demo 6."
- _Backward-links from demo 6 to demos 1 and 3._ In sections 4 and 7 of demo 6, as described above.

The methodology page total-demo count (if it mentions one) gets bumped from five to six. CC: grep for the count in `site/src/app/methodology/` during the MDX task; if it's parameterised off the posts directory, no change needed.

## Acceptance criteria

### C++ / capture

- `bench_06_aos_vs_soa --machine-info` emits a JSON object structurally identical to the `machine` block produced by demo 5 (turbo, isolcpus, cpu_affinity, lscpu_extended, smt_active, transparent_hugepage_enabled, etc).
- `bench_06_aos_vs_soa <variant> --verify-codegen` runs the objdump check from §Variants and prints PASS/FAIL per variant. CI doesn't run this, but CC runs it once during implementation and pastes the result into the demo README.
- `static_assert(sizeof(RecordAoS) == 128)` and `alignof(RecordAoS) == 64` hold.
- SoA column buffers verified 64-byte aligned at allocation (assert or runtime check).
- Affinity is verified at thread start via `sched_getcpu()`; mismatch aborts.
- TSC calibration: same pattern as demos 4 and 5. Verify `constant_tsc`, `nonstop_tsc`, `invariant_tsc`; abort cleanly on missing.
- The runtime-K kernel within a few percent of a template-specialised version on at least one (variant, N, K) spot-check during calibration; if not, switch to template specialisation and re-verify codegen.
- Build succeeds: `cmake --build build --clean-first` on the reference machine.
- Round-trip identity holds per row: `runs[i].ops_per_sec × runs[i].ns_per_op.median / 1e9` ∈ [0.999, 1.001].

### Schema

- New fields appear only on demo 06 records; demos 01–05 JSON unchanged.
- Every `runs[i]` has exactly one (variant, n, k) tuple; the grid is dense (no missing cells).
- `kernel` and `access_pattern` fields are present and consistent across all rows (they're per-demo constants but recorded per-run for forward-compat with future scan-shape demos).

### Site

- `site/src/posts/06-aos-vs-soa.mdx` exists with no `status` or `expectedAt` frontmatter.
- The index card for demo 06 renders without the WIP pill.
- All charts render with no console errors.
- Lighthouse Performance ≥ 90, Accessibility ≥ 90 on `/posts/06-aos-vs-soa` (matching shipped demos).
- No internal contradictions: every reference to "X working-set points" or "Y K values" agrees with the JSON; every numerical claim in the prose reconciles against the JSON to one significant figure.
- The methodology page total-demo count, if present, has been bumped to six.
- Forward-links from demos 1 and 3 to demo 6 are inserted; backward-links from demo 6 to demos 1 and 3 are inserted.

### Post

- All numerical claims in prose are derived from the JSON, not the brief. Any sentence like "AoS at K = 1 is N× slower than SoA in DRAM" matches the JSON to one significant figure. The bandwidth-amplification model is stated as `64 / (K × 8)` and the AoS/SoA ratios in the JSON are within ~10 % of the model at DRAM-bound N.
- The "What this doesn't show" section lists at minimum: K-of-FIELDS workloads have no layout preference; random/strided access patterns; no compression or hand-SIMD; no prefetch-hint advice. All four explicitly.
- The prefetcher is named explicitly in the post body as the mechanism that flattens the cache staircase. The reproduction notes mention the headless-boot precondition; the post body mentions it in passing in §9.
- The K = 8 parity point is presented as the demo's clever observation, not a footnote — at least one paragraph, ideally with the cache-line-fill arithmetic visualised.
- Forward-links to demos 1 and 3, and backward-links from them, are in place.
- Capital-markets framing is one paragraph at the start; not a recurring drumbeat.

## Out of scope

- Random-access AoS vs SoA. Different demo. State so in §What this doesn't show.
- Strided AoS access patterns (touch fields at indices {0, 4, 8, 12} say). Different demo.
- Hand-rolled SIMD beyond auto-vectorisation. Demo 3 covers SIMD craftsmanship; demo 6 stops at "compiler does the right thing on SoA scalar code."
- Compressed columnar formats (Arrow, Parquet, dictionary encoding). Future post.
- NUMA-aware allocation or cross-socket layouts. Single-socket machine.
- Cross-CCX behaviour. Single-thread workload; CCX is not relevant.
- Prefetch-hint experiments (`__builtin_prefetch`). Different demo.
- Variable-width fields, padding, struct-of-pointer-to-struct, AoSoA hybrid. All future material; out of scope here.
- Any modifications to demos 1–5 prose or JSON. The only edits to existing demos are the inserted cross-links per §7 of the plan (one line in demo 1's MDX, one line in demo 3's MDX). No other touches.
- `<TimeVsN>` extension or new chart-component work. §5 of the plan.
- Any change to the hostile cross-read (§8) or pre-merge review (§9) outputs. Those are separate Opus tasks.

## Preflight calibration (post-harness)

This is §4 of the plan: run a calibration step against the built harness once §3 (bench implementation) is complete, _before_ the headline capture in §6. The goal is to confirm that the §1 pilot's findings reproduce through the formal pipeline. If they don't, loop back to §3 or rescope §2 before spending the headline capture budget.

### Procedure

1. Build the harness: `cmake --build build --clean-first`.
2. Run `bench_06_aos_vs_soa --verify-codegen`; confirm PASS on all three variants. If any variant FAILs, fix codegen before proceeding.
3. Run a sparse calibration grid: 3 variants × 3 N values (`{4 096, 131 072, 1 048 576}`) × 3 K values (`{1, 8, 16}`) × 3 iterations. ~30 cells, ~5 minutes wall-clock under shield.
4. Inspect the resulting JSON for the three confirmations below.

### Confirmations (all three must hold)

**P1. Bandwidth-amplification ratio at DRAM-bound N.** At (N = 1 048 576), `aos-scalar.ns_per_op.median` divided by `soa-scalar.ns_per_op.median` should be approximately `64 / (K × 8)` at K = 1 (predicted 8, pilot observed 7.05, tolerance ±20 %) and approximately 1.0 at K = 8 and K = 16 (tolerance ±5 %). If the K = 1 ratio is below 5× or above 10×, something has changed since the pilot and the issue must be diagnosed before the headline.

**P2. DRAM cliff at the L3 boundary.** For `aos-scalar` at K = 1, `ns_per_op.median` at N = 1 048 576 should be at least 3× `ns_per_op.median` at N = 4 096. (Pilot observed ~3.5×.) If less than 2.5×, the prefetcher is either disabled, the working set isn't reaching DRAM, or the warmup is leaving the wrong cache state.

**P3. SoA-scalar vs SoA-autovec.** At (N = 1 048 576, K = 16), `soa-autovec.ns_per_op.median` should be lower than `soa-scalar.ns_per_op.median` by a factor of roughly 2–4× (the SIMD-vs-scalar speed-up on Zen 2 for double-precision sum reduction, where AVX2 dispatches 256-bit ops as two 128-bit µops). If the ratio is below 1.5×, the autovec variant isn't actually vectorising and the codegen check missed it — re-run `--verify-codegen`.

If any of P1, P2, P3 fail, **stop** and report. Don't press on to the headline; fix the issue in §3 or rescope here.

### Output artefact

`bench/calibration-notes/06-aos-vs-soa-preflight/README.md` — a short notes file documenting:

- Date, machine state (turbo, governor, SMT, shield).
- The sparse calibration JSON (or a link to it).
- Each of P1, P2, P3 with the measured number and PASS / FAIL.
- If anything diverges from the pilot's `bench/calibration-notes/06-aos-vs-soa-pilot/README.md`, a one-line note on what changed.

Matches the calibration-notes pattern from demo 5.

## Open items for CC to flag

1. **`std::vector` vs `aligned_buffer` for SoA columns.** Decide between `std::vector<double>` with documented 64-byte data alignment (via `std::aligned_alloc` + custom deleter wrapped in a thin owning type) and `std::vector<double>` plus an alignment assertion at construction (verified empirically — the libstdc++ implementation gives 16-byte alignment by default, which is wrong for AVX2 but only marginally for our access pattern). Recommended: an `aligned_buffer<double>` wrapper. Cost is ~20 lines of code, benefit is unambiguous alignment guarantees and a simpler invariant. Surface the choice in the PR.

2. **Per-TU vectorisation control.** The `soa-scalar` variant needs vectorisation disabled at the function level, not the TU level (the rest of the TU should still vectorise where it can). Confirm `__attribute__((optimize("no-tree-vectorize")))` on the function works on the project's GCC; if not, fall back to `#pragma GCC push_options` / `#pragma GCC optimize("no-tree-vectorize")` / `#pragma GCC pop_options` around the function. Verify in `--verify-codegen`.

3. **Transparent huge pages setting.** `cat /sys/kernel/mm/transparent_hugepage/enabled` on the reference machine — record the active setting in the JSON's `notes` field. If the setting is `never`, raise a flag: the demo's TLB story may need a sentence in the MDX. If `madvise` or `always`, no MDX change.

4. **`<Benchmark>` MDX wrapper filter contract.** The component currently filters by `variants`, `mode`, `n`, possibly `offered_rate_hz`. For this demo it also needs to filter by `k`. Either extend the contract or have charts consume the JSON directly and filter inline. Recommended: extend the contract — keeps the MDX filter spec uniform.

5. **Sweep ordering.** §Build / file layout describes outer-variant, middle-N-descending, inner-K. Confirm during calibration that this ordering doesn't produce a measurable cross-cell warmup bias. If it does, randomise the cell order and document.

6. **Runtime-K kernel cost.** The K loop is data-dependent (runtime K, not compile-time). If the calibration P1 ratios are systematically off-pilot, suspect this first — switch to template specialisation per K and re-run.

7. **Hoist `cset shield --reset` into the global precondition checklist.** The plan's open items raised this as a possible one-line edit to `BRIEF.md` or `crucible-handover.md`. Recommendation: do it here. Add one bullet to the "Capture environment" or "Methodology" section in `BRIEF.md` and a parallel one to `crucible-handover.md`. Folds into this brief's scope rather than spawning a separate task.

8. **The reframed thesis vs the teaser stub.** The teaser MDX shipped with `excerpt` text that probably hedged on "the crossover" wording, since it was written before §1's pilot. CC should grep the stub's frontmatter and body during the MDX task and replace any "crossover" language with the bandwidth-amplification framing — the post's central observation has moved.

9. **Forward-link insertion timing.** The cross-links into demos 1 and 3 (§7 of the plan) edit _shipped_ posts. Make these edits on the feature branch as part of the demo 6 MDX work, so they merge atomically with the new post and never appear out-of-context in a partial state.

10. **Should `verify.cpp` ship?** Demo 3 ships `verify.cpp` as a correctness check. Demo 6's `verify.cpp` is a _codegen_ check — fundamentally different. Decide whether it stays in the demo directory (useful for reproduction) or is treated as one-time scaffolding (delete after the codegen verification result is pasted into the README). Recommended: keep it. The reader who wants to reproduce will appreciate a runnable check.

## Notes for CC

- This is a smaller brief than demo 5. Budget ~3–4 days of CC time. Stage: (1) `record.h` + `kernels.h`, (2) `--verify-codegen` + assembly checks, (3) `benchmark.cpp` with one variant working end-to-end, (4) all three variants and the (N, K) grid, (5) `run_one.sh` orchestration, (6) preflight calibration per §Preflight calibration. The MDX task is separate (Opus draft, CC apply); don't merge it into this PR.

- The two highest-risk items are (a) the codegen verification — if `soa-scalar` accidentally vectorises, the demo's "bandwidth alone vs bandwidth + SIMD" decomposition breaks — and (b) preflight P1 — if the bandwidth-amplification ratios don't reproduce, the pilot was machine-state-dependent in a way the brief didn't anticipate. Both have hard stops in the acceptance criteria.

- The post is replacing a published stub on main. The stub URL (`/posts/06-aos-vs-soa`) is already live by the time this work starts. Per-branch Amplify preview is where chart rendering and prose reviews happen; merge to main only when the post is complete.

- All numerical claims must be regenerated from the captured JSON. Do not pre-write prose with placeholder numbers. The prose-writing pass happens after capture, same as demos 4 and 5.

- The pilot's notes file (`bench/calibration-notes/06-aos-vs-soa-pilot/README.md`) is the source of truth for the reframed thesis. Read it. If anything in this brief diverges from it, the pilot wins.
