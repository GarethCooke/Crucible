# Crucible Demo 2 — False Sharing — Implementation Brief

Companion to `BRIEF.md`. Assumes v1 scaffold is in place and `bench/demos/02-false-sharing/benchmark.cpp` already exists (handed over separately). This brief covers everything _around_ that file.

## What's already done

`bench/demos/02-false-sharing/benchmark.cpp`:

- **Workload:** per-thread P&L accumulator over a shared 1024-double fill stream (seed 42, ~8 KB, fits L1d). Each worker writes `g_unpadded[tid].pnl += fills[j]` (or the padded equivalent) inside a tight `i × j` loop.
- **Variants:** `Strategy` (8 B, naive — adjacent slots share cache lines) vs `PaddedStrategy` (`alignas(64)`, one cache line per slot). Static asserts on size/alignment.
- **Topology groups:** registered as two groups under Google Benchmark:
  - `IntraCCX/{1,2,4}t/{padded,unpadded}` — pinned to CCX1 (cores 4–7).
  - `CrossCCX/{2,4,8}t/{padded,unpadded}` — pinned spanning both CCXs.
- **Sync model:** `std::barrier<>` for go/done, persistent worker threads, `pthread_setaffinity_np` for pinning.
- **Volatile contract:** `pnl` is `volatile double` to defeat register allocation across the j-loop. Inline objdump check documented in the file header (expect two `movsd` per inner-loop body).
- **SMT-off guard:** aborts at startup if `/sys/devices/system/cpu/smt/active` ≠ 0.
- **Repetitions:** `Repetitions(11)` per registered benchmark — Google Benchmark emits mean/median/stddev aggregates across the 11 outer runs.
- **References** `tools/parse_perf.py` (which doesn't exist yet — see below) and `common/machine_info.h` (from v1).

## What's left

### 1. CMake plumbing

- `bench/demos/02-false-sharing/CMakeLists.txt` — link `benchmark::benchmark`, `pthread`, include `common/`. C++20, `-O3 -march=native` from the top-level toolchain.
- `bench/demos/CMakeLists.txt` (or wherever the v1 list lives) — `add_subdirectory(02-false-sharing)`.
- Verify the binary is named `bench_02_false_sharing_pnl` to match the objdump comment in `benchmark.cpp`.

### 2. `bench/tools/parse_perf.py`

The benchmark file already references this path. It is the bridge between Google Benchmark JSON, `perf stat` output, and the canonical site JSON.

**Responsibilities:**

1. Discover registered benchmarks via `<binary> --benchmark_list_tests`.
2. For each benchmark, invoke:
   ```
   perf stat -x, -e cache-references,cache-misses,instructions,cycles \
     <binary> --benchmark_filter=<name>$ \
              --benchmark_repetitions=11 \
              --benchmark_format=json
   ```
   Optionally wrap the whole invocation in `taskset -c <cores>` matching the in-process pinning — defence in depth, not a substitute.
3. Parse Google Benchmark JSON. From the `_median` and `_stddev` aggregate rows, extract `real_time` (ns/iter) and stddev. Compute IQR as `1.349 × stddev` (Gaussian approximation — note this in the schema notes; the alternative is to crank up reps and compute true quartiles, which costs run time we don't need to spend for this demo).
4. Parse `perf stat -x,` stderr — CSV-formatted counters, robust against locale.
5. Decode benchmark name with the regex `^(IntraCCX|CrossCCX)/(\d+)t/(padded|unpadded)$` into structured fields.
6. Emit `site/src/data/perf/02-false-sharing.json` matching the extended schema (below).

**Cores map** — keep in `parse_perf.py` and mark with `# SYNC: must match benchmark.cpp intra_ccx_cores / cross_ccx_cores`. If the two ever drift, the taskset wrapper restricts the wrong cores; the in-process pinning still wins, but the perf numbers get contaminated by scheduler noise on the unintended cores during process startup.

**Per-iteration op count** for `ops_per_sec` and `_per_op` counters: `threads × N_ITERS × N_FILLS` = `threads × 100 × 1024`. Surface as `iterations_per_repetition` in the JSON for transparency.

### 3. Schema extension

Add structured fields to each `runs[]` entry. Backwards-compatible with v1 — existing `<ThroughputBars>` uses `variant`, won't break.

```json
{
  "variant": "intra-ccx / 4t / unpadded",
  "topology": "intra-ccx",
  "threads": 4,
  "padded": false,
  "cores": [4, 5, 6, 7],
  "iterations_per_repetition": 409600,
  "repetitions": 11,
  "ns_per_op": { "median": 12.4, "min": 12.1, "iqr": 0.18 },
  "ops_per_sec": 80645161,
  "cache_misses_per_op": 0.087,
  "cache_references_per_op": 0.42,
  "instructions_per_cycle": 1.1,
  "cache_miss_rate": 0.207
}
```

Schema notes for this demo and going forward:

- **`p99` becomes optional.** Google Benchmark's `Repetitions` gives aggregates across outer runs, not per-iteration distributions. Demos whose story is tail latency (Demo 4) will need a custom timing harness; demos whose story is throughput (this one, Demo 1) can omit `p99`. Document this in `BRIEF.md` next pass.
- **`n` semantics.** v1 used `n` as array size. For this demo it's structural rather than the headline variable — replace with `iterations_per_repetition`. Keep `n` optional in the schema.
- Surface `cache_miss_rate = cache_misses / cache_references` as a derived field — saves the chart from doing arithmetic.

### 4. `<CounterOverlay>` component

First demo that needs it. Build under `site/src/components/charts/CounterOverlay.tsx`, share `theme.ts` with `ThroughputBars`.

**Spec:**

- **Props:** `slug: string`, `metric: string` (key into the per-run JSON, e.g. `cache_misses_per_op`, `cache_miss_rate`), `groupBy?: string` (default `"padded"`), `xAxis?: string` (default `"threads"`), `topology?: "intra-ccx" | "cross-ccx"` (filter; default `"intra-ccx"`).
- **Render:** line chart, x = `threads`, y = `metric`. One line per value of `groupBy` (so for this demo: one line for padded, one for unpadded). Points labelled with exact value on hover.
- **Optional second axis:** if `metric` plus a throughput overlay are both requested, render as a dual-axis chart (right axis = ops/sec) — defer this until an MDX page asks for it.
- Honour the dark/cyan palette from `theme.ts`. Padded should be the "good" colour (subdued cyan), unpadded the "bad" colour (warm red/orange) — define once in `theme.ts` as `palette.good` / `palette.bad` so future demos reuse.

### 5. MDX post — `site/src/posts/02-false-sharing.mdx`

**Structure:**

1. **Hook.** "Two threads. One cache line they didn't know they were sharing. ~10× slowdown — and nothing in the source code points at the problem."
2. **Setup paragraph.** A per-strategy P&L accumulator. `results[tid].pnl += fill` is the kind of line you write without thinking. Frame it in capital-markets terms — strategies and fills, not threads and counters.
3. **Code.** `<CodeCompare lang="cpp" labels={["Naive struct","Cache-line padded"]} highlightLines={[...]} />` showing `Strategy` vs `PaddedStrategy`. Don't show the loop — the point is the struct.
4. **Headline numbers.** `<ThroughputBars slug="02-false-sharing" variants={["intra-ccx / 4t / unpadded","intra-ccx / 4t / padded"]} stat="median" />`. Caption with the ratio.
5. **Scaling story.** A grouped throughput chart at threads ∈ {1, 2, 4}, intra-CCX, both variants. Padded scales near-linearly; unpadded flatlines or goes backwards. Either extend `<ThroughputBars>` to accept multiple groups, or introduce a `<ThroughputVsThreads>` chart — decide based on what reads cleaner in the MDX. _Flag this design decision back before building._
6. **Mechanism.** `<CounterOverlay slug="02-false-sharing" metric="cache_miss_rate" />`. One paragraph on MESI ping-pong: the line oscillates between Modified states on different cores, every write becomes a coherence transaction. Cache-miss rate climbing in lockstep with threads (unpadded) vs flat (padded) is the visual proof.
7. **Cross-CCX sub-result.** Short paragraph + small bar chart: intra-CCX 4t unpadded vs cross-CCX 4t unpadded. Cross is worse because the line crosses the Infinity Fabric instead of staying within a CCX's L3. One-sentence Zen 2 caveat; link to methodology.
8. **Takeaway.** The proper fix is thread-local accumulators with a final reduce — one extra line, no padding required. Padding is what you reach for when the slot array _is_ the API (e.g. a shared results buffer exposed across a library boundary). The signal isn't knowing the trick; it's noticing the line on the cache-miss chart.
9. **Methodology link.**

### 6. Top-level integration

- `bench/scripts/run_one.sh` — add `02-false-sharing` to the dispatch (or generalise: the script takes the demo slug and calls `parse_perf.py` against the matching binary).
- `bench/scripts/run_all.sh` — add the demo.
- `README.md` — add a section under "Running benchmarks" if the workflow differs from demo 1; otherwise nothing.
- `site/src/app/page.tsx` — add the post card. If the index is auto-discovered from `posts/*.mdx`, ensure frontmatter on `02-false-sharing.mdx` matches the discovered schema.

## Acceptance criteria

- `cmake --build build` produces `bench_02_false_sharing_pnl`.
- Running the binary directly succeeds without root (assumes `kernel.perf_event_paranoid=1`).
- `objdump -d build/.../bench_02_false_sharing_pnl | grep -A 40 worker_fn | grep movsd` shows the expected load+store pair in the inner loop. If not, **stop and flag back** before changing flags or struct layout — the file header documents the escalation order.
- `./scripts/run_one.sh 02-false-sharing` emits valid JSON at `site/src/data/perf/02-false-sharing.json` with all 18 runs (2 topologies × thread-counts × 2 padding variants — total 3+3+3+3+3+3 = wait, recount: IntraCCX has 3 thread counts × 2 padding = 6; CrossCCX has 3 × 2 = 6; total 12 runs).
- **Sanity assertions** (post-run, can be a separate `tools/sanity_check.py`):
  - At intra-CCX 4t, `unpadded.ns_per_op.median / padded.ns_per_op.median ≥ 5` (expected ~10×; 5× is the floor for "the demo is working").
  - At intra-CCX 1t, `unpadded.ns_per_op.median ≈ padded.ns_per_op.median` within 20% — no sharing at one thread, so padding shouldn't matter.
  - `cross-ccx/4t/unpadded.ns_per_op.median > intra-ccx/4t/unpadded.ns_per_op.median` — cross-CCX is worse.
- Post page renders all charts. CounterOverlay shows the climbing-vs-flat shape.
- Lighthouse perf ≥90 on `/posts/02-false-sharing`.

## Open items for CC to flag back

1. **`perf` paranoid level** — confirm `kernel.perf_event_paranoid=1` suffices for `cache-references` / `cache-misses` events without `CAP_SYS_ADMIN`. If not, document the `sudo setcap cap_perf_event=ep <binary>` workaround in the README.
2. **`perf list` event names** — `cache-misses` and `cache-references` are aliases; on Zen 2 the canonical raw events differ. Pick the alias for portability; if numbers look off, switch to raw events and document.
3. **IQR derivation.** Gaussian `1.349σ` is fine for normally-distributed throughput, but for false-sharing-contended runs the distribution may be bimodal (scheduler noise). If stddev/median > 0.1 on any run, flag it — may need raw repetition data instead of aggregates.
4. **Grouped throughput chart.** Extend `<ThroughputBars>` vs introduce `<ThroughputVsThreads>`. Pick one and propose before building.
5. **Index frontmatter schema.** If the v1 index auto-discovers posts, confirm what `02-false-sharing.mdx` frontmatter must contain (title, date, summary, slug?).

## Skeptical review pass (post-implementation, in chat)

To run after CC ships:

- Would a quant dev call `volatile` non-idiomatic and demand `std::atomic_ref` with relaxed ordering? Defend in the post (volatile is the minimal mechanism to force the memory traffic the demo is _about_; atomic adds fence overhead irrelevant to the false-sharing story) or switch and accept the contamination. **Pre-commit answer: defend.**
- Does the 10× ratio hold across reruns? Re-run three times on different days; if it drifts >20% the post needs a confidence interval, not a point ratio.
- Is the cross-CCX gap large enough to be a sub-result, or does it muddy the headline? If `cross/4t/unpadded` is within 30% of `intra/4t/unpadded`, demote to a methodology footnote.
- The thread-local fix — should the post show its numbers too, or just describe it? Showing them risks burying the false-sharing story under "look, the proper fix is fast." Recommendation: describe, don't measure. The post is about the _cost_, not the cure.
