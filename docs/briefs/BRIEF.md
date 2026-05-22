# Crucible — Project Brief

A high-performance C++ benchmarking microsite. Each post is a focused optimisation problem with naive vs tuned implementations, real measurements, and visualisations of system behaviour rather than algorithm steps. Companion piece to `garethcooke.com`, deployed at `crucible.garethcooke.com`. Follows the same separate-repo pattern as FrontierView.

## Goals

- Demonstrate concrete C++ performance engineering skill (cache effects, branch prediction, concurrency primitives, SIMD, allocators, data structures) to a hedge-fund / capital-markets engineering audience.
- Each post: problem statement, naive code, tuned code, benchmark results, visualisation, takeaway, link to source.
- Reproducible methodology, public benchmark harness, all measurements run on a single documented reference machine.

## Repository structure

Single repo `crucible`, separate from the portfolio site:

```
crucible/
├── bench/                              # C++ benchmark code
│   ├── CMakeLists.txt
│   ├── common/                         # shared harness utilities
│   │   ├── perf_wrapper.h              # perf stat invocation, JSON output
│   │   ├── stats.h                     # median, IQR, percentile helpers
│   │   └── machine_info.h              # capture machine spec into JSON
│   ├── demos/
│   │   └── 01-branch-prediction/
│   │       ├── CMakeLists.txt
│   │       ├── benchmark.cpp
│   │       └── README.md
│   └── scripts/
│       ├── run_one.sh                  # build + run one demo, emit JSON
│       └── run_all.sh
├── site/                               # Next.js MDX site
│   ├── package.json
│   ├── next.config.mjs                 # output: 'export' for static
│   ├── tailwind.config.ts
│   ├── src/
│   │   ├── app/
│   │   │   ├── page.tsx                # index, lists posts
│   │   │   ├── methodology/page.tsx
│   │   │   └── posts/[slug]/page.tsx
│   │   ├── components/
│   │   │   ├── CodeCompare.tsx         # Shiki side-by-side
│   │   │   ├── Benchmark.tsx           # MDX-friendly chart wrapper
│   │   │   └── charts/
│   │   │       ├── theme.ts            # shared D3 palette + typography
│   │   │       ├── ThroughputBars.tsx
│   │   │       ├── TimeVsN.tsx
│   │   │       ├── LatencyHistogram.tsx
│   │   │       └── CounterOverlay.tsx
│   │   ├── data/perf/
│   │   │   └── 01-branch-prediction.json
│   │   └── posts/
│   │       └── 01-branch-prediction.mdx
├── README.md
├── LICENSE                             # MIT
└── amplify.yml
```

The C++ side is buildable independently. JSON outputs are committed alongside the site so the deploy is purely static.

## Tech stack

- **C++:** C++20, GCC 13+ (target Ubuntu LTS, current at install time)
- **Build:** CMake ≥3.20
- **Benchmarking:** Google Benchmark (`benchmark::DoNotOptimize`, `benchmark::ClobberMemory`)
- **Hardware counters:** `perf stat` invoked via shell wrapper, output parsed into JSON
- **Site:** Next.js 14 with App Router, TypeScript, Tailwind CSS v4
- **MDX:** `@next/mdx`
- **Code rendering:** Shiki, dark theme matching portfolio site palette
- **Charts:** D3 (current version), built as reusable React components — not one-off SVG per page
- **Deploy:** AWS Amplify, static export
- **License:** MIT

## Hardware / reference machine

Single reference machine, documented on `/methodology`:

- AMD Ryzen 7 3800X, 8 cores / 16 threads, Zen 2
- 32 GB DDR4 (record actual speed/timings on methodology page)
- ASUS ROG STRIX B550-F GAMING (Wi-Fi)
- Ubuntu Server LTS, dual-boot with Windows
- Boot params: `isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7`
- BIOS: Core Performance Boost disabled, SMT disabled (or pin to physical cores 0–3 only)

ISA caveats to disclose explicitly on methodology page: SSE4.2, AVX, AVX2, FMA. **No AVX-512.** Zen 2 implements 256-bit AVX2 as two 128-bit µops — note this in any future SIMD post.

One-time setup that needs documenting in the README:

- `cpupower frequency-set -g performance`
- `echo 0 > /sys/devices/system/cpu/cpufreq/boost`
- `sysctl kernel.perf_event_paranoid=1` (allows user-mode `perf` access)
- Kernel boot params via GRUB

## Methodology commitments

To be stated explicitly on `/methodology`. All four are non-negotiable for the published numbers to be credible:

1. **CPU governor** pinned to `performance` for all benchmark runs.
2. **Turbo Boost** disabled (BIOS CPB off, verified via `/sys/devices/system/cpu/cpufreq/boost`).
3. **Core isolation** — cores 4–7 isolated via `isolcpus=`; benchmarks pinned with `taskset -c 4-7` or `pthread_setaffinity_np`.
4. **Statistical reporting** — each benchmark runs N≥100 iterations after warmup. Report **median + IQR** for typical-case latency, **min** for "best the hardware can do," **p99 / p99.9** for tail-latency claims. Each chart states which statistic it shows.

Additional best-practice items the methodology page should call out:

- Inputs are runtime-loaded (not compile-time-known) to defeat constant folding.
- Outputs sunk via `benchmark::DoNotOptimize` to prevent dead-code elimination.
- Inputs shuffled between iterations where branch-predictor memorisation would distort results.
- Allocations kept out of hot paths.
- Machine spec, kernel version, compiler version, and `lscpu --extended` output committed to the repo.

References to credit on the methodology page:

- Chandler Carruth — _Tuning C++: Benchmarks, and CPUs, and Compilers! Oh My!_ (CppCon 2015)
- Agner Fog — optimisation manuals at agner.org
- Brendan Gregg — systems performance writing at brendangregg.com

## Data schema

Every benchmark emits a JSON file at `site/src/data/perf/<slug>.json` matching this contract. **This is the boundary between C++ and the site — settle it before writing chart components.**

```json
{
  "demo": "01-branch-prediction",
  "title": "Sorted vs unsorted branch prediction",
  "machine": {
    "cpu": "AMD Ryzen 7 3800X",
    "cores_physical": 8,
    "cores_logical": 16,
    "smt_enabled": false,
    "ram_gb": 32,
    "ram_speed_mhz": 3200,
    "compiler": "gcc 13.2",
    "compiler_flags": "-O3 -march=native",
    "kernel": "6.8.0-generic",
    "governor": "performance",
    "turbo": false,
    "isolated_cores": [4, 5, 6, 7]
  },
  "captured_at": "2026-05-15T14:30:00Z",
  "runs": [
    {
      "variant": "sorted",
      "n": 33554432,
      "iterations": 100,
      "ns_per_op": { "median": 1.21, "min": 1.18, "p99": 1.45, "iqr": 0.04 },
      "ops_per_sec": 826446280,
      "branch_misses_per_op": 0.001,
      "instructions_per_cycle": 3.2
    },
    {
      "variant": "unsorted",
      "n": 33554432,
      "iterations": 100,
      "ns_per_op": { "median": 7.34, "min": 7.21, "p99": 8.12, "iqr": 0.11 },
      "ops_per_sec": 136239782,
      "branch_misses_per_op": 0.498,
      "instructions_per_cycle": 0.9
    }
  ],
  "notes": "Branch predictor learns sorted patterns; unsorted forces ~50% mispredicts."
}
```

## Component contracts

The components MDX posts can use:

- `<CodeCompare lang="cpp" naive={src} optimized={src} highlightLines={[12,13]} labels={["Before","After"]} />` — Shiki side-by-side, changed lines subtly highlighted, synchronised vertical scroll. `labels` overrides default Naive/Optimised wording for cases where the framing is different (e.g. the branch-prediction demo where input differs, not code).

- `<Benchmark slug="01-branch-prediction" chart="throughput-bars" variants={["sorted","unsorted"]} stat="median" />` — loads the JSON, renders the chosen chart with the chosen statistic, captions with stat label.

- `<TimeVsN slug="..." />`, `<ThroughputBars slug="..." />`, `<LatencyHistogram slug="..." />`, `<CounterOverlay slug="..." metric="branch_misses" />` — direct access if MDX needs more control than `<Benchmark>` exposes.

Charts share `components/charts/theme.ts` — colour palette, typography, axis treatment, all defined once. Dark theme matching the portfolio site.

## v1 scope

Ship one complete demo end-to-end plus the surrounding scaffold. Subsequent demos cost ~20% of v1.

1. Repo skeleton per layout above
2. CMake build for `bench/`, builds first demo on Linux
3. `perf stat` wrapper script that runs a binary and emits JSON conforming to schema
4. First demo (sorted-vs-unsorted) implemented and producing valid JSON
5. Next.js site initialised, MDX configured, Tailwind v4 wired up, static export configured
6. `<CodeCompare>` component using Shiki
7. `<ThroughputBars>` chart component (D3) — sufficient for v1 demo
8. `<Benchmark>` MDX wrapper
9. `posts/01-branch-prediction.mdx` consuming the above
10. `/methodology` page documenting all four commitments above plus best-practice items
11. Index page `/` listing posts (initially: one post)
12. `README.md` covering: prerequisites, one-time machine setup commands, how to build benchmarks, how to run, how to deploy site
13. `LICENSE` (MIT)
14. `amplify.yml` for static-export deploy

Out of scope for v1, build later when a demo needs them: `<TimeVsN>`, `<LatencyHistogram>`, `<CounterOverlay>` chart components.

## v1 demo: sorted vs unsorted branch prediction

The classic. Iterate an array of `int`, sum elements meeting a condition (`x >= 128`). Compare:

- **Sorted variant** — input sorted ascending. Branch predictor learns the pattern, near-zero mispredicts.
- **Unsorted variant** — input shuffled. Predictor fails roughly 50% of conditions, large stall.

Run at multiple N (say 1k, 10k, 100k, 1M, 10M, 32M). The largest matters for the headline, but capture all sizes — useful for follow-up posts and eventual `<TimeVsN>` views.

Headline chart: throughput bars, sorted vs unsorted, at N=32M, median ns/op. Annotate with branch-miss rate per op (from `perf stat`).

Post structure for `01-branch-prediction.mdx`:

1. Hook — "Same code. Same data values. ~6× difference. Why?"
2. Code — `<CodeCompare>` showing the loop. Note: the "before/after" framing here is unusual — both variants are the same code; the _input ordering_ differs. Use `labels={["Sorted input","Unsorted input"]}` rather than the default.
3. Numbers — `<Benchmark>` with throughput bars.
4. Mechanism — short paragraph on history-based branch prediction.
5. Takeaway — when input ordering is under your control, sorting once amortises across many predictable iterations. Caveat: sorting cost itself isn't free.
6. Methodology link.

## v1 acceptance criteria

- `cd bench && cmake -B build && cmake --build build` succeeds on the reference machine
- `./scripts/run_one.sh 01-branch-prediction` produces a JSON file matching the schema
- `cd site && npm install && npm run dev` starts the dev server cleanly
- `npm run build` produces a static export in `out/`
- The post page renders the code comparison and the throughput bars chart
- The methodology page is readable and lists all four commitments plus references
- Lighthouse performance score ≥90 on the post page
- Repo can be deployed to Amplify with the included `amplify.yml`

## Out of scope (deferred follow-up briefs)

- Demos 2–N: false sharing, SIMD (scalar/SSE/AVX2), lock-free SPSC vs mutex queue, allocators, std::sort vs radix sort, std::map vs flat_map vs robin_hood
- AVX-512 demos (require rented bare-metal time)
- RSS feed
- Cross-machine comparison views
- Search / filtering on the index
- Comments / disqus
- Analytics

## Open items for CC to flag during implementation

- Exact Shiki integration approach for Next.js 14 App Router + MDX (multiple patterns exist; pick one and document the choice).
- Whether to vendor Shiki theme JSON or load from CDN (Amplify static-deploy implications).
- Whether `perf` requires CAP_SYS_ADMIN or just `kernel.perf_event_paranoid=1` on the target kernel; document the resolved approach in the README.
- Confirm Tailwind v4 + Next.js 14 static export combination works in the chosen versions; pin if necessary.

## Naming and branding

Project name: **Crucible**. Subdomain: `crucible.garethcooke.com`. Project page on the main portfolio at `garethcooke.com/projects/crucible` follows the FrontierView card → overview → external link pattern.

Branding should match `garethcooke.com` aesthetic — dark theme, cyan accent. **No IguanaWare branding** — perf work needs to feel rigorous, not playful.

## Pre-flight checks for prose-against-data briefs

When a brief prescribes prose edits against specific data values (e.g. percentile claims in MDX based on JSON benchmark output), the brief MUST include a pre-flight check that validates two things:

1. **The data file's `captured_at` timestamp** matches the timestamp the brief was written against. Capture re-runs change every measurement value; a brief authored against one capture can't be safely applied to another.
2. **A handful of sentinel statistics** match the values the brief assumes. Catches the case where two captures share a timestamp but differ in values (shouldn't happen, but the check is cheap).

The check runs as a Python snippet at the top of the brief, before any edits. On failure: `STOP, surface the mismatches, contact Opus for a new brief.` No interpretation, no partial application.

Reference implementation: any of the `pre-demo-5-25c-*` or later briefs.

Why this matters: brief 25b (May 22) was authored against a `2026-05-20` JSON capture that didn't match the repo's `2026-05-21` capture. The pre-flight in its successor brief 25c caught the mismatch and prevented a wrong-direction rewrite from landing.

### When to skip

Pre-flight isn't needed for briefs that:

- Don't reference specific data values (e.g. pure refactoring, structural, code-only briefs).
- Reference data values only in passing for context, where the brief's correctness doesn't depend on those values being accurate.

When in doubt, include the pre-flight — it's a five-line Python snippet and costs nothing if everything's fine.
