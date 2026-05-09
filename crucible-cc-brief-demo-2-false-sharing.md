# Crucible — Demo 2 Brief: False Sharing

Companion to `crucible-cc-brief.md` (v1 brief, branch prediction). This brief assumes the v1 scaffold is in place: data schema, component contracts, MDX content layout, methodology page, build/CI plumbing. Where this brief refers to those, defer to the v1 brief and codebase as authoritative.

## Story

Per-thread P&L accumulators arranged in a contiguous array. As thread count scales, the unpadded version's throughput collapses while the padded version scales near-linearly. Same algorithm, same fill stream, same machine — the only difference is whether each strategy slot occupies its own cache line. The cause is shown by overlaying cache-miss rate climbing in lockstep with the throughput drop.

The post lands two claims:

1. False sharing is not a small effect — multi-× slowdowns on this hardware.
2. On Zen 2 specifically, intra-CCX and cross-CCX false sharing have meaningfully different penalty profiles because Infinity Fabric coherency traffic is more expensive than intra-CCX L3 traffic.

## What CC produces

New files:

- `bench/false_sharing_pnl.cpp` — Google Benchmark target
- `tools/perf_capture.sh` — wraps `perf stat -j` around a benchmark binary, emits JSON; handles `cset shield` setup/teardown and IRQ affinity steering
- `tools/parse_perf.{py|ts}` — folds perf JSON into the demo's `runs[].counters` fields (match whichever language the v1 plumbing uses)
- `site/src/data/perf/false-sharing-pnl.json` — schema-conformant data file
- `site/src/components/charts/CounterOverlay.tsx` — new chart component, per locked contract `<CounterOverlay slug="..." metric="..." />` plus the `placement` filter prop noted below
- `site/src/content/demos/false-sharing.mdx` — the post

Existing files extended:

- `components/charts/theme.ts` — add palette entries CounterOverlay needs only if existing series colours don't cover it
- `components/charts/ThroughputBars.tsx` — add optional `placement?: string` prop (filters runs by placement before rendering)
- Methodology page MDX — reflect runtime cpuset shielding + SMT-off-in-BIOS, per spec below

## Workload spec

Two struct definitions:

```cpp
// Unpadded — adjacent slots share cache lines
struct Strategy {
    double pnl;
};

// Padded — each slot owns its cache line
struct alignas(64) PaddedStrategy {
    double pnl;
    char pad[64 - sizeof(double)];
};
```

Fill stream: pre-generated `std::vector<double>` of size 1024 (8 KB, fits comfortably in 32 KB L1d), populated once at benchmark setup with a deterministic pseudo-random sequence (`std::mt19937` seeded with a fixed value — record the seed in JSON `notes`). Shared read-only across all threads. Iterated repeatedly to reach the measurement window.

Worker function:

```cpp
void worker(int slot,
            const double* fills,
            size_t n_fills,
            size_t n_iters) {
    for (size_t i = 0; i < n_iters; ++i) {
        for (size_t j = 0; j < n_fills; ++j) {
            strategies[slot].pnl += fills[j];
        }
    }
}
```

One "op" = one fill processed. Total ops per run = `n_threads * n_iters * n_fills`.

**Compile-time sanity check.** Inspect `objdump -d` of the unpadded variant after build, confirm there is a memory write to `strategies[slot].pnl` per iteration of the inner loop. Document the check in a comment at the top of `false_sharing_pnl.cpp`. If the loop is being elided, **flag back rather than escalating silently** — options are `-O1`, a `volatile` qualifier, or `std::atomic_ref<double>` with relaxed ordering, but the choice affects how realistic the compiler config looks and is worth a chat-level decision.

## Variant matrix

With SMT disabled in BIOS, the reference machine exposes 8 logical CPUs (0–7), one per physical core. CCX0 = cores 0–3, CCX1 = cores 4–7 (verified via `lscpu --extended` L3 grouping).

Two placement configs, recorded in the same JSON file via the `placement` field on each `runs[]` entry:

- **`intra-ccx`**: all threads pinned to physical cores within one CCX. Use CCX1 (cores 4–7) by convention since it's the typical shielded set. Thread counts: **1, 2, 4** (no 8 — only 4 physical cores per CCX with SMT off).
- **`cross-ccx`**: threads distributed across both CCXs. Thread counts: **2, 4, 8**. For 2: cores 0, 4. For 4: cores 0, 1, 4, 5. For 8: all of 0–7.

Within each placement, both `padded: false` and `padded: true` variants. Total runs: 6 thread-placement points × 2 padding states = **12 runs**.

The 1-thread baseline lives under `intra-ccx`; with no contention, placement is moot at 1 thread, and `intra-ccx` is the natural home.

**Pinning.** Use `pthread_setaffinity_np` after thread creation, targeting logical CPUs 0–7 directly (one per physical core, since SMT is off). Discover SMT state at runtime via `/sys/devices/system/cpu/smt/active` and assert it's `0`; abort with a clear error if SMT is on so we don't silently produce contaminated numbers. Record exact core IDs used in each `runs[].notes`.

**Core isolation.** `cset shield` configured before the benchmark binary runs, reset after. Wrapper script (`tools/perf_capture.sh`) handles setup and teardown. For `intra-ccx` runs the shield is `--cpu=4-7`; for `cross-ccx` it expands to cover whichever CCX0 cores are needed (e.g. `--cpu=0-7` for 8-thread, `--cpu=0,1,4,5` for 4-thread cross). Record the shielded core set in `machine.isolated_cores` per run.

## Measurement spec

Per variant:

- Google Benchmark auto-tunes iteration count to ~100 ms per run
- 11 runs per variant
- Report `ns_per_op` as `median`, `min`, `iqr`; derive `ops_per_sec` from median
- Wall-clock timing via Google Benchmark's default (`std::chrono::steady_clock`)

Perf counters captured per variant via the wrapper:

- `cache-misses`
- `cache-references`
- `instructions`
- `cycles`

Derived fields written to `runs[].counters`:

- `cache_misses_per_op` = cache-misses / total ops
- `cache_miss_ratio` = cache-misses / cache-references
- `instructions_per_cycle` = instructions / cycles

Use generic `perf` events for v1. AMD-specific events (`l2_request_g1` family) are the upgrade path if sharper Zen 2 data is wanted later — note this in `runs[].notes` as a future-work hook.

## Compiler config

GCC 13, `-O2 -march=native -std=c++20`. No LTO. No `-ffast-math`. No `-funroll-loops` beyond what `-O2` already implies. Compile flags recorded in JSON's machine block per the v1 schema.

## Methodology page edit

Replace any existing core-isolation paragraph in the methodology page MDX with the following two paragraphs:

> **Core isolation.** Per-benchmark `cpuset` shielding via `cset shield`, configured immediately before each benchmark run and reset after. Exact shielded core IDs are recorded in each demo's JSON `machine.isolated_cores` field. IRQ affinity is steered to non-shielded cores via `/proc/irq/*/smp_affinity` by the wrapper script. SMT is disabled at the BIOS level — verified via `/sys/devices/system/cpu/smt/active` returning `0` and `lscpu` reporting 8 CPUs — to remove SMT-sibling resource sharing (L1, L2, execution ports, frontend) from all measurements.

> **Boot parameters.** No core-isolation boot parameters are committed (`isolcpus=`, `nohz_full=`, `rcu_nocbs=` are all unset). Demos with hard tail-latency claims (sub-microsecond p99.9) may introduce `nohz_full=` at that point, with each addition documented in that demo's methodology notes alongside the data it's needed for.

Add `machine.isolated_cores: number[]` and `machine.smt_active: 0|1` to the schema if not already present.

## MDX page outline

`site/src/content/demos/false-sharing.mdx`. Sections in order:

1. **Headline + framing** (1 paragraph). Same code, same algorithm, multi-× difference. Why?
2. **The setup** (~2 paragraphs + `CodeCompare`). Explain the workload (per-strategy P&L accumulators), show the two struct definitions side-by-side via `<CodeCompare lang="cpp" naive={...} optimized={...} highlightLines={[/* alignas line */]} labels={["Unpadded","Padded"]} />`.
3. **What happens at scale (intra-CCX)** (~1 paragraph + 2 charts). `<ThroughputBars slug="false-sharing-pnl" placement="intra-ccx" />` and `<CounterOverlay slug="false-sharing-pnl" placement="intra-ccx" metric="cache_misses_per_op" />`. Note that intra-CCX caps at 4 threads on this hardware (one CCX = 4 physical cores with SMT off).
4. **The Zen 2 CCX caveat** (~2 paragraphs + 2 charts). Same chart pair for `cross-ccx` (2/4/8 threads). Explain that Zen 2's two CCXs share L3 only via Infinity Fabric, and inter-CCX coherency traffic is meaningfully more expensive than intra-CCX traffic. Reference AMD Zen 2 microarchitecture briefly.
5. **Reading the numbers** (~2 paragraphs). Quantify what the charts show. Acknowledge that on Zen 3+ and Intel SoCs without CCX boundaries, the second chart pair would look different — this is a Zen 2-specific result, which is exactly why we report machine config alongside every measurement.
6. **What this means in practice** (~2 paragraphs). Connect to where this surfaces in real systems: shared counters across worker threads, market-data fan-out structs, per-strategy state in trading engines. Don't over-claim — false sharing is well-known; the value here is making the magnitude legible.
7. **Reproducing this** (1 paragraph + links). Source files, methodology page link, exact `cset shield` invocation used.

## CounterOverlay component spec

Per the locked contract `<CounterOverlay slug="..." metric="..." />`, plus the `placement?: string` prop. Reads `data/perf/<slug>.json`, optionally filters runs by `placement`, plots the named counter on the Y-axis vs the variant axis on the X-axis (threads, with padded/unpadded as series). Series colours from `theme.ts`. Match axis treatment, typography, and tooltip style of `ThroughputBars` and `TimeVsN`. Tooltip shows variant label + exact value + units (e.g. "Unpadded, 4 threads — 0.42 misses/op"). Y-axis labelled with the metric name and units.

## Acceptance criteria

- [ ] `bench/false_sharing_pnl.cpp` builds with the project's CMake, no warnings on `-Wall -Wextra`
- [ ] `tools/perf_capture.sh` runs the benchmark with `cset shield` setup and teardown, emits valid perf JSON
- [ ] `false-sharing-pnl.json` validates against the v1 schema (with the additions of `isolated_cores` and `smt_active` to `machine`)
- [ ] All 12 variants populated in JSON with the four counter fields
- [ ] Benchmark binary aborts cleanly if `/sys/devices/system/cpu/smt/active` reports `1` (SMT must be off)
- [ ] MDX page renders with all 4 chart instances populated from the JSON; CodeCompare renders both struct definitions
- [ ] **Sanity check (precondition):** padded throughput exceeds unpadded throughput by **at least 3× at 4 threads on `intra-ccx`** and **at least 5× at 8 threads on `cross-ccx`**. If less, the false-sharing effect isn't manifesting cleanly — flag back before measuring the rest.
- [ ] **Direction check:** at the same thread count, `cross-ccx` unpadded is markedly worse than `intra-ccx` unpadded (compare 4-thread runs, since both placements have data at that thread count). If `cross-ccx` numbers come back near-identical to `intra-ccx`, that's a real result but flag back so the post's Zen 2 framing can be adjusted rather than asserting a difference that isn't there.

## Pre-flight (already validated)

- ✓ `cset shield` works on Ubuntu 24.04 cgroup v2 — confirmed via smoke test (shield activated, status checked, reset cleanly)
- ✓ Topology confirmed via `lscpu --extended` — CCX0 = cores 0–3, CCX1 = cores 4–7, SMT pairs are compact-numbered (0/8, 1/9, …, 7/15)

## Pre-flight remaining

- [ ] Disable SMT at BIOS level (or apply runtime fallback `echo off | sudo tee /sys/devices/system/cpu/smt/control` per boot). Verify post-disable: `cat /sys/devices/system/cpu/smt/active` returns `0` and `lscpu | grep "^CPU(s):"` reports 8.
- [ ] Per-boot setup applied: governor = performance, turbo off, SMT off (per `## Per-boot setup` in the README).
- [ ] `cpuset` package installed: `sudo apt install cpuset`.
