# Crucible — Demo 08: Sorting shootout (`std::sort` vs `pdqsort` vs LSD radix)

Implementation brief for Claude Code. Lands on the feature branch (`demo-8-sorting-shootout` or equivalent, per-branch Amplify preview enabled). Self-contained — no further scoping decisions required beyond the named open items.

## Context

Eighth demo in the Crucible series. Builds on:

- `BRIEF.md` — v1 scaffold, locked JSON schema, methodology, hardware spec, and (per the demo 6 close-out) the `sudo cset shield --reset` capture precondition.
- `crucible-handover.md` — per-demo process and lessons.
- `demo-08-plan.md` — the tracking doc this brief implements (§2 of that plan).
- `demo-08-teaser-brief.md` (companion) — the stub MDX and "In Progress" teaser that lands on `main` ahead of this work. This brief's MDX (§7 of the plan) replaces that stub on the feature branch.
- Demos 6 and 7 — provide `<TimeVsN>` with cache-tier band markers. Chart 1 reuses that component directly. The per-run JSON shape (n-sweep, `ns_per_op` per element) follows demos 6/7.
- Demo 1 (branch prediction) — the backward cross-link target: demo 1 showed sorting makes the *downstream* loop branch-predictable; demo 8 measures what the sort itself costs. Clean pairing.

This demo has **no threading, no atomics, no latency histograms**. It is a single-threaded N-sweep plus a fixed-N distribution sweep. Simpler than demos 4–7 mechanically; the work is in getting the harness honest (the destructive-sort hazard) and the framing right (no crossover — see Story angle).

When the feature branch merges to main, the merge replaces the stub MDX with the full post and removes the `status: "in-progress"` and `expectedAt` frontmatter.

### Pilot findings this brief is built on

A calibration pilot (plan §1, run on the reference machine in a desktop session — throwaway, no commit) resolved the open framing questions. **Pilot magnitudes are ordinal only** — they fix shapes and directions; the formal preflight (§4 / Task 4 below) re-confirms them through the built harness on the isolated boot, and all published numbers come from the headline capture (Task 6). The shapes the brief commits to:

1. **No crossover.** Radix wins at *every* N measured (1024 → 67 M, random u32). Order is consistently radix < pdqsort < `std::sort`. The headline is **not** "crossover" (which would also have read as a demo-6/7 tic — demo 7 hostile cross-read L-1). Lead with mechanism + tail-latency.
2. **The cache-tier inflection lives in the radix line.** `std::sort`'s ~40→73 ns/elem rise across the sweep is almost entirely the `log₂n` term, not cache tiers. Radix is flat (~11 ns/elem) until ≈4 M elements (16 MB ≈ L3/CCX boundary) then climbs into the DRAM-bound regime (~15.6 ns/elem at 67 M). Chart 1's cache-tier band markers read meaningfully on the radix line; the comparison-sort lines are dominated by the algorithmic ramp. Say so — do not sell chart 1 as a "comparison-sort staircase."
3. **Distribution sensitivity is large and carries chart 2.** At N=4 M, pilot ns/elem: pdqsort 0.8 (sorted) → 28.0 (sawtooth), ~35× swing; `std::sort` 6.8 (reverse) → 63.2 (random), ~9×; radix 13.4 (random) → 20.0 (sorted), ~1.5× — essentially flat.
4. **The inversion is the story beat.** Comparison sorts *love* pre-sorted input (pdqsort 0.8 ns); radix is indifferent — and slightly *slower* on sorted (20.0) than random (13.4), because sequential keys fan out across all 256 buckets every pass. Verify this holds in Task 4; if it does, it earns a one-paragraph sidebar.
5. **Sawtooth is the pdqsort-defeat case** (pdqsort 28.0 ≈ its random 26.0). The honest limit of pattern detection.
6. **The destructive-sort restore is load-bearing.** Pilot Phase 3: omitting the per-iteration restore collapsed `std::sort` from 58.2 to 8.9 ns/elem on iteration 2+ (re-sorting already-sorted data). The collapsed value lands on `std::sort`'s sorted-input cost — the bug exactly mimics a fast sort. It is asymmetric: radix is unaffected, so a broken harness silently flatters the comparison sorts. See Harness.

## Story angle

Headline thesis: *for fixed-width integer keys, the comparison lower bound is a wall `std::sort` can't climb — and you can go around it.* Radix sort is O(n·w/r) for w-bit keys at r bits per pass; it sidesteps the Ω(n log n) comparison bound by exploiting that the keys are fixed-width integers. Not magic — a different cost model. Across every size measured, radix wins on random u32.

The tail-latency hook (the strongest pull for the capital-markets reader, and the through-line from demos 4 and 5): **radix's runtime is essentially data-independent.** Its ns/elem band is ~13–20 across all five input distributions; the comparison sorts swing from 0.8 to 63. On a hot-path sort whose p99 matters, the data-independent sort is the safe choice even where its median isn't the best — there is no adversarial input that blows out its tail.

Two mechanisms, two charts:

- **Chart 1 — the wall.** Time-vs-N, all variants, random input. Radix on the floor across the whole sweep; the comparison sorts ride the `log₂n` ramp above it. Cache-tier band markers (reused from demo 6/7) annotate where the radix line leaves L3 for DRAM.
- **Chart 2 — input shape decides the comparison-sort race.** Fixed large N, variants across random / sorted / reverse / few-unique / sawtooth. The comparison sorts spread dramatically and invert (cheap on sorted, expensive on random); radix stays flat. This chart *is* the tail-latency evidence.

What the post does **not** claim:

- **Not that radix is universally faster.** It does not transfer to non-integer or variable-width keys — comparison sorts are the only general option there. Its advantage shrinks as key width grows (u64 is 8 passes vs u32's 4 — quantify in the u64 callout, Task 4).
- **Not that `std::sort` is bad.** It is a fine general-purpose default and the only option once keys aren't fixed-width integers. State this in a "What this doesn't show" section.
- **No claim that radix loses at small N.** (The plan's pre-pilot assumption; the pilot disproved it for u32 — radix wins at N=1024.) Make no claim either way below the chart's left edge; say "across every size we measured."
- **Stability is mentioned, not benchmarked.** LSD radix is stable; `std::sort` and `pdqsort` are not. The headline sorts bare u32 keys, so stability is moot for the measurement; note it as a property, don't build a chart on it.

## Variants

Templated on key type so u32 and u64 share one implementation (no copy-paste radix — the code-review skill's DRY priority applies). All built `-O3 -march=native -std=c++20`.

1. **`std-sort`** — `std::sort(begin, end)`. Introsort. The default.
2. **`pdqsort`** — Orson Peters' pattern-defeating quicksort, vendored header (see Open items for licence). `pdqsort(begin, end)`.
3. **`radix-lsd`** — hand-rolled LSD radix, 8 bits per pass, `sizeof(T)` passes. The clearest implementation and the one that matches the project's "roll one, call out the simplifying assumptions" ethos.

```cpp
// radix.h — LSD radix, 8-bit passes. Even pass count for u32/u64 => result lands in `a`.
template <class T>
void radix_lsd(std::vector<T>& a, std::vector<T>& tmp) {
    static_assert(std::is_unsigned_v<T>, "LSD radix here assumes unsigned fixed-width keys");
    const size_t n = a.size();
    for (unsigned shift = 0; shift < sizeof(T) * 8; shift += 8) {
        size_t count[256] = {0};
        for (size_t i = 0; i < n; ++i) ++count[(a[i] >> shift) & 0xFFu];
        size_t sum = 0;
        for (int b = 0; b < 256; ++b) { size_t c = count[b]; count[b] = sum; sum += c; }
        for (size_t i = 0; i < n; ++i) tmp[count[(a[i] >> shift) & 0xFFu]++] = a[i];
        a.swap(tmp);
    }
}
```

`sizeof(T)` is even for both u32 (4) and u64 (8), so the result lands back in `a` after the swaps. The `tmp` scratch is allocated once outside the timed region and passed in.

**Optional second radix line — defer unless it's free.** A tuned-library radix (`boost::sort::spreadsort` or `ska_sort`) as a "what production radix looks like" contrast. Default: ship the hand-rolled line only. If a library line is added, it must not clutter chart 1 (see Open items).

**`std::stable_sort`** — a one-line callout in prose on the cost of merge-sort-with-buffer stability, **not** a headline chart line. Do not add it to chart 1.

## Inputs

```cpp
enum class Dist { Random, Sorted, Reverse, FewUnique, Sawtooth };

template <class T>
std::vector<T> make_input(Dist d, size_t n, std::mt19937_64& rng);
```

- `Random` — uniform over the full key range. Fixed seed (document it).
- `Sorted` — `0, 1, …, n-1`.
- `Reverse` — `n-1, …, 1, 0`.
- `FewUnique` — uniform over `[0, 99]` (100 distinct values). Exercises pdqsort's few-unique fast path and radix's "high passes are all one bucket" locality.
- `Sawtooth` — `i % (n/8)`, eight repeating ramps. The pdqsort-defeat case.

All RNGs use fixed seeds for reproducibility; document the seeds in the demo README.

## Harness (the destructive-sort hazard — named explicitly)

Sorting mutates its input. An unrestored buffer measures the best case on every iteration after the first. This is demo 8's analogue of demo 4's warmup contamination, and it is **asymmetric**: it collapses the comparison sorts (re-sorting sorted data) while leaving radix untouched, so a broken harness produces a plausible-looking result that silently flatters `std::sort`/`pdqsort`. The pilot reproduced the exact signature (58.2 → 8.9 ns/elem from iteration 2 on).

Google Benchmark, mirroring the project's existing harness. Build the master once, outside the loop, with a fixed seed; restore a pristine copy into the work buffer each timed iteration with the copy **outside** the timed region:

```cpp
template <class T, class SortFn>
static void BM_Sort(benchmark::State& state, SortFn sort, Dist dist) {
    const size_t n = static_cast<size_t>(state.range(0));
    std::mt19937_64 rng(/*fixed seed*/);
    const std::vector<T> master = make_input<T>(dist, n, rng);  // built once
    std::vector<T> work(n), tmp(n);                              // tmp = radix scratch
    for (auto _ : state) {
        state.PauseTiming();
        std::memcpy(work.data(), master.data(), n * sizeof(T));  // restore — UNTIMED
        state.ResumeTiming();
        sort(work, tmp);
        benchmark::DoNotOptimize(work.data());
        benchmark::ClobberMemory();
    }
    state.SetItemsProcessed(state.iterations() * static_cast<int64_t>(n));
}
```

Notes:

- `benchmark::DoNotOptimize` + `ClobberMemory` keep the sort from being elided. Confirm the sort is not optimised away in the disassembly during implementation (one-time check, record in the README).
- **Known, accepted property:** after the memcpy, `work` is warm in cache, so the sort reads warm data. This is consistent across all variants, so the relative shapes — the whole point — are fair. Do **not** add cache-flushing; that is a different, harder methodology and out of scope.
- **Restore verification.** Add a debug-build invariant (or a `--verify-restore` one-shot, mirroring demo 4/5's `--verify-warmup`): per-iteration timings for a comparison sort on random input must not trend downward across iterations. If they do, the restore is broken. Record the verification result in the README and `stop and flag` rather than capturing.

## Measurement

Two registration sets, both feeding one JSON file.

**Set A — N-sweep (chart 1).** `distribution = random`, `key_type = u32`. Powers of two from **2¹⁰ (1024) to 2²⁶ (67 108 864)**. Each (variant × n) registered with `->Arg(n)` and `->Repetitions(R)` where **R ≥ 5** for the headline capture. Google Benchmark auto-scales inner iterations, so small-N timer-granularity noise (visible in the chrono pilot) is not a concern here.

**Set B — distribution sweep (chart 2).** `key_type = u32`, fixed **N = 2²² (4 194 304)**, across all five distributions, all variants, `->Repetitions(R)` with R ≥ 5.

`run_one.sh 08-sorting-shootout` orchestrates the build + capture and drives the existing Google-Benchmark-JSON → project-schema aggregation. The aggregator computes `ns_per_op` (per element) median / min / p99 / iqr from the GB repetitions.

## Schema

One JSON file, `site/src/data/perf/08-sorting-shootout.json`, matching the locked schema. Per-run fields:

```json
{
  "variant": "radix-lsd",
  "n": 4194304,
  "distribution": "random",
  "key_type": "u32",
  "iterations": 5,
  "ns_per_op": { "median": 13.4, "min": 13.1, "p99": 14.0, "iqr": 0.3 },
  "ops_per_sec": 74600000,
  "compile_flags": "-O3 -march=native -std=c++20",
  "notes": "ns_per_op is nanoseconds per element sorted; input restored from a master copy outside the timed region each iteration."
}
```

- `ns_per_op` = **nanoseconds per element sorted.** `op = one element`. Confirm this unit matches what demos 6/7's `<TimeVsN>` already consume (see Open items) — the chart must read demo 8's JSON with no per-element conversion if 6/7 already normalise per element.
- `distribution` and `key_type` are **new** additive per-run fields. Demos 1–7 JSON unchanged. Chart 1 filters `distribution == "random"`; chart 2 filters `n == 4194304`.
- The machine block follows the patched-harness schema (`required-fields.md`): `turbo: false` from `CRUCIBLE_TURBO`, `governor: "performance"`, `isolated_cpus` string, `isolated_cpus_{requested,effective,source}`, `cpu_affinity`, `lscpu_extended`. No machine-level `compiler_flags` (it lives per-run as `compile_flags`).

## Charts (component reuse, not fork)

- **Chart 1** — `<TimeVsN>` reused as-is, 3 lines (`std-sort`, `pdqsort`, `radix-lsd`), random input, with the cache-tier band markers from demo 6/7. Verify it takes demo 8's JSON as-is. Annotate the L3→DRAM band on the radix line.
- **Chart 2** — distribution sensitivity at N=4 M across five distributions. Decide between repeated `<ThroughputBars>` calls (one per distribution, filtered) vs a small grouped-bar extension. **Resist forking a bespoke "SortChart"** — extend or compose (see Open items). Editorial lean: whichever keeps the five-distribution view legible.

Demo 6/7 JSON suffices for chart-shape sanity-checking during development before demo 8's capture exists.

## Build / file layout

```
bench/
├── common/
│   └── third_party/
│       └── pdqsort.h                       # vendored, zlib licence
└── demos/
    └── 08-sorting-shootout/
        ├── CMakeLists.txt
        ├── benchmark.cpp                   # registration sets A and B
        ├── radix.h                         # templated LSD radix
        ├── inputs.h                        # Dist, make_input<T>
        └── README.md                       # seeds, restore-verification result, disasm check note
```

`run_one.sh 08-sorting-shootout` builds and captures to `site/src/data/perf/08-sorting-shootout.json`.

## Preconditions (verify before capture; user/CC split noted)

These hold for the **headline capture** (Task 6, user) — not for development builds:

1. Boot the isolated GRUB entry (`isolcpus=0-7 …`). Headless, single isolated core for the pinned run.
2. `sudo cpupower frequency-set -g performance`; verify turbo off; `export CRUCIBLE_TURBO=off`.
3. **`sudo cset shield --reset`** before the capture session (BRIEF.md precondition; named here as defence in depth).
4. Pin the run to one isolated core (`taskset -c 4` or the harness's affinity, matching demos 1–7).

## Acceptance criteria

### C++ / capture

- `cmake --build build --clean-first` succeeds on the reference machine.
- `radix_lsd<uint32_t>` and `radix_lsd<uint64_t>` both produce fully sorted output (assert against `std::is_sorted` in a debug check).
- The destructive-sort restore is verified: per-iteration timings for `std-sort` on random input do not trend downward (`--verify-restore` or debug invariant). Result recorded in the demo README.
- The sort is not elided: `DoNotOptimize`/`ClobberMemory` confirmed via one disassembly check, recorded in the README.
- Set A emits all powers of two 2¹⁰…2²⁶ for `distribution=random, key_type=u32`, R ≥ 5, for all three variants.
- Set B emits all five distributions at N=2²², R ≥ 5, for all three variants.
- u64 confirmation run (Task 4) produced for the key-width callout: radix's advantage over `std::sort` is smaller at u64 than u32. Numbers recorded for the post.

### Schema

- New per-run fields `distribution` and `key_type` appear only on demo 08 records; demos 01–07 JSON unchanged.
- `ns_per_op` is per element and consistent with the unit demos 6/7 `<TimeVsN>` consumes.
- Machine block matches `required-fields.md` (patched-harness schema; `captured_at` postdates `2026-05-16T20:42:00Z`, `Z` suffix).
- `ops_per_sec` is internally consistent with `ns_per_op.median` and `n` to one significant figure.

### Site

- `site/src/posts/08-sorting-shootout.mdx` exists with no `status`/`expectedAt` frontmatter.
- The demo 08 index card renders with no WIP pill; index shows eight fully shipped cards.
- Chart 1 (`<TimeVsN>`, 3 lines, random) and chart 2 (distribution sweep) render with no console errors.
- Lighthouse Performance ≥ 90, Accessibility ≥ 90 on `/posts/08-sorting-shootout`.
- No internal contradictions: every reference to "five distributions" / "three variants" / the fixed chart-2 N agrees across prose, charts, and JSON.

### Post

- All numerical claims in prose are derived from the **captured JSON**, not the pilot numbers in this brief and not the brief's expectations. Any "radix is N× faster at 67 M" sentence matches `ns_per_op.median` from the actual JSON to one significant figure.
- The headline avoids "crossover" (Task 8 checks this explicitly).
- "What this doesn't show" section lists at minimum: non-integer/variable-width keys (no transfer); key-width sensitivity (u64 shrinks the advantage); stability not benchmarked (bare keys, no payload); single-threaded, single machine.
- Backward cross-link to demo 1 (sorting makes the downstream loop predictable; this measures the sort's own cost) and to demos 6/7 (cache staircase). Forward-links inserted into demos 1, 6, 7 pointing at demo 8.
- Methodology page demo total bumped to 8 if it references one.
- Vendored `pdqsort` dependency called out in the post and the repo README.

## Out of scope

- Any modification to demos 1–7 prose, code, or JSON, beyond inserting the forward cross-links into demos 1, 6, 7 (Task 7) and the methodology demo-count bump.
- Non-integer keys, variable-width keys, string keys (future post if any).
- Key+payload records and the stability/scatter-cost story they enable (possible future sidebar; not this post).
- Multi-threaded / parallel sorts (`std::execution::par`, parallel radix).
- A tuned-library radix line *unless* it is added per Open item 2 without cluttering chart 1.
- `std::stable_sort` as a chart line (callout only).
- Recapturing any demo 1–7 JSON.
- The cache-flush methodology variant (warm-buffer property is accepted and documented).
- Any chart-component fork. `<TimeVsN>` reused as-is; chart 2 is compose-or-small-extend only.

## Open items for CC to flag

1. **`ns_per_op` unit consistency with demos 6/7.** Confirm `<TimeVsN>` already consumes a *per-element* ns value. If demos 6/7 store total ns and convert in-component, match their storage convention instead and note the choice in the PR. The chart must render demo 8 with no bespoke conversion.

2. **Tuned-library radix line.** Default is hand-rolled only. If adding `boost::sort::spreadsort` or `ska_sort` is trivial *and* it sits cleanly on chart 1 without making it a five-line tangle, add it as a fourth line labelled "production radix." If it clutters, leave it out and mention library radix in one prose sentence. Surface the choice in the PR.

3. **Chart 2 component shape.** Repeated `<ThroughputBars>` (one filtered call per distribution) vs a small grouped-bar extension to an existing component. Pick whichever keeps the five-distribution view legible; do not fork a new component. Surface the decision in the PR.

4. **Reverse vs sorted in chart 2.** The pilot shows `reverse` and `sorted` produce near-identical *shapes* (both comparison sorts cheap, radix flat). Capture all five, but if chart 2 is visually crowded, drop `reverse` from the rendered chart (keep it in the JSON). Flag the call.

5. **Radix-slower-on-sorted inversion.** The pilot showed radix slightly slower on `sorted` (20.0) than `random` (13.4). If Task 4 reproduces this through the real harness, it earns a one-paragraph sidebar (the clean "different cost models" inversion). If it does **not** reproduce, drop the sidebar — do not assert a pilot artifact as fact.

6. **`pdqsort` licence.** Vendored header is zlib-licensed (permissive); the repo is MIT. zlib-into-MIT is fine, but confirm and add the licence header/attribution per the repo's vendoring convention. Flag if the repo has no existing third-party-vendoring pattern to follow.

7. **Aggregator handles the new `distribution` axis.** Demos 6/7 already n-sweep, so the GB-JSON → schema aggregator handles `n`. The `distribution` axis is new. Confirm the aggregator parses it (likely from the GB benchmark name) and emits one record per (variant × n × distribution). If the GB benchmark-naming scheme needs a convention, define it (e.g. `Sort/<variant>/<distribution>/<n>`) and document it.

8. **Chart 1 left edge.** Capture from 2¹⁰. If even the Google-Benchmark numbers are visibly noisy below 2¹² in the real capture, trim the rendered chart's left edge to 2¹² (keep the JSON). The "wins everywhere" claim is unaffected — just say "across every size we measured."

## Notes for CC

- Budget ~2–3 days. Mechanically this is the simplest demo since the early ones: no threads, no atomics, no histograms. Stage it: (1) `inputs.h` + `radix.h` with `is_sorted` debug asserts; (2) the harness with restore verification — get the destructive-sort check passing before anything else; (3) registration sets A and B; (4) capture + aggregation; (5) MDX.
- The single highest-risk item is the **harness restore**. If `--verify-restore` shows downward-trending iteration times, the destructive-sort bug is present — `stop and flag`, do not capture. Everything downstream is poisoned by it and the poison flatters the comparison sorts asymmetrically, so it will not look obviously wrong in the output.
- All prose numbers come from the captured JSON, written after capture. Do not pre-write prose with the pilot numbers in this brief — they are ordinal placeholders to fix the framing, nothing more.
- The "What this doesn't show" section is the post's defence against a skeptical hedge-fund reader. The honest claims are narrow: fixed-width unsigned integer keys, single thread, advantage shrinks with width, no transfer to general keys. Take it seriously.
