# Crucible — Continuation Handover

Paste this at the start of a new Opus session to continue scoping demos for the Crucible project without re-deriving context.

## Project state

- **Crucible**: C++ performance-benchmarking microsite, companion to garethcooke.com
- Separate repo, deployed at `crucible.garethcooke.com` (FrontierView pattern)
- Target audience: hedge fund / capital markets engineering hiring (Selby Jennings, Huxley, Dartmouth pipeline)
- v1 brief written and handed to Claude Code; scaffold + first demo (sorted-vs-unsorted branch prediction) being implemented
- The full v1 brief is in project knowledge as `BRIEF.md`
- Now scoping demos 2–N for subsequent CC sessions

## Key learnings & principles
- Prose-against-data briefs use a pre-flight check pattern (see BRIEF.md § "Pre-flight checks for prose-against-data briefs"). Established after the 25b → 25c stale-capture incident on 22 May.

## Hardware (reference machine for all benchmarks)

- AMD Ryzen 7 3800X (Zen 2), 8 cores / 16 threads, ASUS ROG STRIX B550-F GAMING (Wi-Fi), 32GB DDR4
- Ubuntu Server LTS dual-boot
- ISA: SSE4.2, AVX, AVX2, FMA — **no AVX-512**
- **Zen 2 caveat:** 256-bit AVX2 ops execute as two 128-bit µops; full 256-bit dispatch starts at Zen 3. Note this on any SIMD post.
- **Zen 2 CCX caveat:** two 4-core CCXs sharing Infinity Fabric; inter-CCX cache coherency has higher latency than intra-CCX. Relevant for any threading/cache demo.

## Methodology commitments (locked, on /methodology page)

1. CPU governor pinned to `performance` (`cpupower frequency-set -g performance`)
2. Turbo Boost disabled (BIOS Core Performance Boost off, verified via `/sys/devices/system/cpu/cpufreq/boost`)
3. Core isolation via `isolcpus=4-7` boot param; benchmarks pinned with `taskset`/`pthread_setaffinity_np`
4. Statistical reporting: **median + IQR** for typical, **min** for best-case, **p99 / p99.9** for tail-latency claims; each chart states which stat it shows

References cited on methodology page: Chandler Carruth (CppCon 2015), Agner Fog (agner.org), Brendan Gregg (brendangregg.com).

## Tech stack (locked)

- C++20, GCC 13+, CMake ≥3.20, Google Benchmark
- `perf stat` invoked via shell wrapper, output parsed to JSON
- Next.js 14 App Router, Tailwind CSS v4, TypeScript, MDX
- Shiki for code rendering (custom side-by-side, MD3-dark-theme palette)
- D3 for charts, built as reusable React components
- Static export deployed to AWS Amplify
- License: MIT
- **No IguanaWare branding** — rigour signal for this project, kept distinct from maker work

## Component contracts (locked)

```
<CodeCompare lang="cpp" naive={src} optimized={src} highlightLines={[...]} labels={["Before","After"]} />
<Benchmark slug="..." chart="throughput-bars" variants={[...]} stat="median" />
<ThroughputBars slug="..." />
<TimeVsN slug="..." />
<LatencyHistogram slug="..." />   <!-- to be built when first needed -->
<CounterOverlay slug="..." metric="..." />   <!-- to be built when first needed -->
```

Charts share `components/charts/theme.ts` (palette, typography, axis treatment).

## Data schema (locked)

JSON per demo at `site/src/data/perf/<slug>.json`. Schema includes machine block (CPU, RAM, compiler, kernel, governor, turbo, isolated cores), `captured_at`, and `runs[]` with per-variant `ns_per_op` stats (`median`, `min`, `p99`, `iqr`), `ops_per_sec`, perf-counter fields (e.g. `branch_misses_per_op`, `cache_misses_per_op`, `instructions_per_cycle`), and `notes`.

Full schema is in `BRIEF.md`. Don't change it without considering all charts/demos that depend on the contract.

## Demos to scope next (order matters)

### Demo 2 — False sharing
- **Story:** padded vs unpadded per-thread counters; same code, ~10× difference because of cache-line ping-pong. Demonstrates the cost of accidental sharing.
- **What to measure:** ops/sec across N threads (1, 2, 4, 8); cache misses per op via `perf stat`.
- **Charts:** ThroughputBars (padded vs unpadded), and ideally a CounterOverlay showing cache-miss rate climbing without padding. CounterOverlay component will need building for this demo.
- **Gotchas to flag:** pin to physical cores only (SMT siblings will lie); on Zen 2, intra-CCX vs cross-CCX gives different penalty magnitudes — pick one and document, or show both as a sub-result.
- **Plumbing this demo adds:** perf-stat hardware-counter capture, parsed into the schema's counter fields. All subsequent demos benefit.

### Demo 3 — SIMD: scalar vs SSE vs AVX2
- **Story:** vectorisation gains on a workload the audience cares about. Candidate workloads: dot product (simplest), sum reduction, or vectorised Black-Scholes across an option chain (capital-markets flavoured — recommended).
- **What to measure:** GFLOPS or ns/op across the four variants (scalar, SSE, AVX2 auto-vectorised, AVX2 hand-tuned with intrinsics).
- **Charts:** ThroughputBars by ISA. Optionally show the assembly diff inline.
- **Gotchas to flag:**
  - Zen 2 splits 256-bit AVX2 into 2×128-bit µops — speedup is real but smaller than on Haswell+ Intel
  - `-march=native` vs explicit ISA flags — be deliberate about which the compiler used
  - Alignment: aligned vs unaligned loads
  - AVX-512 is **not** in scope here (deferred to a one-time rented-bare-metal post, possibly bundled with a Zen 4 / Sapphire Rapids comparison)

### Demo 4 — Lock-free SPSC vs mutex queue
- **Story:** single-producer single-consumer ring buffer vs `std::mutex`-protected `std::queue`. Latency tail collapses dramatically with the lock-free version. **The killer demo for the hedge-fund signal.**
- **What to measure:** end-to-end enqueue→dequeue latency distribution. p50, p99, p99.9. Throughput as secondary metric.
- **Charts:** LatencyHistogram with p50/p99/p99.9 markers (component will need building). ThroughputBars as a supporting view.
- **Gotchas to flag:**
  - Warmup matters — early iterations contaminate the histogram
  - Batch size of enqueues per measurement window
  - The ring buffer itself can suffer false sharing between producer and consumer — show or mention the cache-line-padded version
  - On Zen 2, producer and consumer on different CCXs vs same CCX shows in the tail — pick a configuration and document
  - Cite a known-good lock-free queue impl (e.g. Folly, moodycamel) rather than rolling one — or roll one and explicitly call out the simplifying assumptions

### Future demos (not yet scoped)

- `std::sort` vs radix sort vs `pdqsort` on int keys (algorithmic, time-vs-N curves)
- `std::map` vs `std::unordered_map` vs `boost::flat_map` vs robin_hood (data structures)
- Allocators: default vs arena vs pool vs `boost::small_vector` (tail-latency post)
- Memory hierarchy: AoS vs SoA, latency-vs-working-set staircase
- ARM NEON vs scalar on Raspberry Pi 5 (constrained-hardware differentiation post — use IguanaWare-adjacent voice if it fits)
- AVX-512 on rented bare-metal (one-time, batched, possibly Sapphire Rapids vs Zen 4 comparison)

## Process per demo

1. **Scope in chat** (~10 min): pick the story angle, anticipate the quant-reader objection, choose the chart, identify gotchas
2. **Generate brief** for that demo (similar shape to v1 brief but smaller — just C++ code + JSON output + MDX page; component contracts already exist)
3. **Hand to CC** for implementation
4. **Skeptical review pass** in chat after CC ships ("would a quant dev push back on this claim?")

## What NOT to do

- No IguanaWare branding on Crucible itself
- No AVX-512 demos on local hardware
- Don't expand v1 scope retroactively — each new demo is a separate brief
- Don't change the data schema without auditing all dependent charts
- Don't have multiple demos in flight at CC simultaneously