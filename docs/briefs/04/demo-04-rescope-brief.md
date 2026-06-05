# Demo 04 rescope brief — bimodality finding (decision B)

Branch: `feature/boost-off-recapture`. Scope: `content/posts/04-spsc-queue.mdx`, one new committed data file, and post-processing in the demo-04 assembler. **No rig recapture** — sub-saturation numbers come from the June JSON; over-saturation numbers come from the 2026-06-05 performance-governor bimodality diagnostic, assembled into a committed file so every figure traces to data.

## Context

The bimodality diagnostic (decision A, run on performance governor, shielded) established that past saturation the SPSC system has **two stable equilibria** — a shallow queue (~350 ns boost / ~1.2 µs mutex p50) and a deep queue (~40–68 µs boost / ~210 µs mutex p50), separated by ~100×. The equilibrium is selected **per process** at startup and held for that process's lifetime (8–10 of 10 processes are internally single-mode for mutex/boost). A five-run capture therefore reports **one draw**, which is why the May capture (deep) and the June capture (shallow) looked like different benchmarks. Hand-rolled's deep excursions are a *different* mechanism — an intermittent within-run consumer stall (0/10 processes single-mode), the previously-documented environmental spike.

The shipped post's entire over-saturation narrative (two saturation *mechanisms*; mutex's 190 µs wall; boost's 28 MHz queue-fill knee; the "14.7 vs 14.9 coincidence"; the "Boost consumer ~3× slower"; the single-point spike at 16 MHz) is built on one draw and is contradicted by the distribution. Decision B keeps the **reproducible** result — the 1 MHz sub-saturation tail-latency comparison — as the spine, and replaces the over-saturation section with the bimodality finding itself.

This also re-derives the paced headline to the June JSON and clears the standing defects (footer isolation, date, depth-field derivability).

## Pre-flight sentinel

`site/src/data/perf/04-spsc-queue.json`: `captured_at == "2026-06-05T06:06:58Z"`, `turbo:false`, `turbo_source:"cpb"`, `freq_max_available_mhz:3900`. Paced (1 MHz) `latency_ns.stats` must read hand-rolled p50 **122**, p99 **164**, p99.9 **180**; boost p50 **140**, p99 **172**, p99.9 **180**. Abort on mismatch.

## Task 0 — commit the overload-modes data file

The over-saturation prose cites the diagnostic, which is currently only stderr in `bimode_raw_20260605T161247Z.log`. Assemble it into `site/src/data/perf/04-spsc-queue-overload-modes.json` so the numbers are derivable from committed data, and commit the raw log under `bench/diagnostics/04/` for provenance.

Add `bench/scripts/assemble_overload_modes.py` that reads the raw log, classifies each ITER line (`deep` depth_mean>100, `shallow` <10, else `indet`), and emits per `(variant, point)`: `n`, mode counts, and per-mode median p50/p99.9/achieved. Target structure (values below are the verified medians — the assembler must reproduce them):

```
mutex-condvar  @28MHz : shallow n=48 p50=1312ns ; deep n=2 p50=225280ns
mutex-condvar  saturated: indet n=45 p50=2880ns ; deep n=5 p50=208896ns
lockfree-boost @28MHz : shallow n=28 p50=376ns ach=17.3M ; deep n=20 p50=41984ns ach=18.8M
lockfree-boost saturated: deep n=47 p50=67584ns ach=15.5M ; indet n=3 p50=1312ns
lockfree-handrolled @28MHz: shallow n=28 p50=344ns ; indet n=20 p50=1248ns ; deep n=2
```

Also record per-cell process uniformity (fraction of the 10 invocations whose 5 runs are single-mode) — it is the evidence for "selected per process": mutex/boost 8–10/10, hand-rolled 0/10. Header must carry the diagnostic's `governor=performance`, `kernel=6.8.0-117`, shielded, 10×5 per cell.

## Task 1 — restore depth derivability to the published JSON (no rerun)

The prose cites queue depths (mutex ~1.8 items at 1 MHz; the deep-mode capacity fill) that exist in **neither** published JSON. They are computable offline from data already present: mean latency from the histogram buckets, then Little's law `depth_mean = ops_per_sec × mean_ns × 1e-9`.

In `bench/scripts/assemble_results_04.py`, when building each run's `latency_ns.stats`, compute `mean_ns` from the histogram and `depth_mean` via Little's law, and add both fields. Regenerate `04-spsc-queue.json` from the existing per-variant capture data — **no rig run**, this is pure post-processing of histograms already captured. Update `benchmark.cpp`'s emitter to carry the same two fields for future captures (the ITER path already computes them). Confirm the 1 MHz mutex run yields `depth_mean ≈ 1.8`.

## Task 2 — rewrite the over-saturation section

In `content/posts/04-spsc-queue.mdx`, replace lines 145–159 (everything from "Each line shows p50…" through "…re-rolling for a tidier curve.") with:

```
Each line shows p50, p99, and p99.9 across twelve log-spaced offered-load points
from 100 kHz to 50 MHz (x-axis: offered/requested load). The curve is drawn only
through the **sub-saturation** regime, where achieved throughput tracks the offered
rate and latency is a single well-defined function of load. Below saturation the
story is simple and reproducible: all three stay near their per-op floors — the
lock-free pair around 120–140 ns, the mutex a few hundred ns above — and the lines
are flat. Past the saturation knee the chart stops on purpose, because past
saturation there is no single line to draw.

### Past saturation: two equilibria, not one curve

When the offered rate exceeds what a variant can drain, the queue does not settle
into one steady state. It settles into one of two, and which one a run lands in is
fixed when the process starts and holds for that run. Repeating each
over-saturation point 50 times (10 processes × 5 timed runs, performance governor,
shielded) makes the split explicit:

| variant | offered | shallow p50 | deep p50 | processes deep / shallow |
| --- | --- | --- | --- | --- |
| mutex-condvar | 28 MHz | 1.3 µs | 225 µs | ~5% deep |
| lockfree-boost | 28 MHz | 0.38 µs | 42 µs | ~40% deep |
| lockfree-boost | saturated | — | 68 µs | ~95% deep |

In the **shallow** equilibrium the queue stays a handful of items deep: producer
and consumer hand off in lock-step, the bottleneck is per-operation cost, and p50
sits near the sub-saturation floor. In the **deep** equilibrium the queue fills
toward its 1024-entry capacity and residency becomes `queue_depth × consumer_period`
— hundreds of microseconds for the mutex, tens for Boost. The two are separated by
~100× with nothing between them; a run is in one or the other.

The selection is per *process*. At a fixed over-saturation load, 8–10 of every 10
processes are internally uniform — all five timed runs in the same mode — so a
process picks an equilibrium in the first rounds of the producer/consumer race and
stays there. Boost at 28 MHz is the clearest case: roughly 40% of processes run
deep and 60% shallow at the *same* offered load.

This is the methodological point of the demo. The published percentile for an
over-saturation point comes from one process — one draw from this distribution.
Capture the benchmark once and mutex's overload p50 is 1 µs; capture it again and
it is 200 µs. Neither is wrong; neither is *the* number. The split itself is not
even fixed: changing the CPU governor from performance to schedutil flips mutex
from mostly-shallow to mostly-deep. The honest statement is that past saturation
these queues are bistable, and any benchmark reporting a single over-saturation
latency is reporting a coin toss.

The hand-rolled variant has a third behaviour that is *not* one of these
equilibria. Its over-saturation runs are never internally uniform — the latency
flips item-to-item within a single run — because hand-rolled's deep excursions are
not a queue equilibrium but an intermittent consumer stall: a tens-of-microseconds
gap on the dequeue side with no matching gap on the producer side, the producer
stamping items while the consumer briefly goes dark. On a pinned, spinning,
isolated core that is an external event — a cross-core IPI or an SMI — and it does
not care about offered load. It surfaces as a tail spike only near saturation,
where the producer is flat-out and the stalled interval backs up hundreds of items
before the consumer resumes; below ~9 MHz the same stall clears before it matters.
Across repeated runs it appears in roughly half of them, landing at whatever sweep
point happens to catch it — which is why one capture showed it at one offered load
and another showed it elsewhere. It is real, environmental, and not a property of
any rate.
```

## Task 3 — rewrite the Throughput section

Replace the first paragraph (lines 180–193, "Saturated throughput: the producer runs flat-out…very different reason for the ceiling.") and the nuance paragraph (lines 201–206, "A nuance for the Boost number…depth-independent.") with:

```
Saturated throughput, producer flat-out. The lock-free pair cap in the same
neighbourhood — hand-rolled ~14–16 M/s, Boost ~15–18 M/s — but both figures are
mode-dependent draws from the same bistability as the latency: a process that
settles deep and one that settles shallow report different achieved rates, so a
single saturated-throughput number carries the same coin-toss caveat as the
over-saturation latency. Mutex caps lower, ~4–5 M/s, bound by condvar wake-up cost.

A throughput-only view misleads in both directions. It makes the lock-free pair
look interchangeable — they are not; their tails differ by ~100× and their overload
behaviour is bistable — and it undersells the mutex gap, which is a small multiple
in rate but orders of magnitude in tail.
```

Leave the "**The lock-free win is about determinism, not raw rate.**" line in place. Delete the producer-bound/consumer-bound attribution and the "~3× slower consumer" sentence wherever they remain in this section — the clean per-variant attribution dissolves into mode dependence and is not supported.

## Task 4 — Why the tail collapses (high-load paragraph)

Replace lines 225–228 ("At high offered load, the tail grows further…worth labelling separately.") with:

```
At high offered load the tail is the bistable picture above: a run that settles
into the deep equilibrium has latency `queue_depth × consumer_period` — the
hundreds-of-microseconds residency — while a run that settles shallow stays near
the per-op floor. A hockey-stick in any single sweep is whichever equilibrium that
capture's process happened to occupy, not a smooth function of load.
```

In the low-load paragraph just above (the ~130 ns floor sentence), change `roughly 130 ns` to `roughly 120 ns` to match the June paced p50 (122 ns).

## Task 5 — Boost comparison (re-derive to June JSON)

In the Boost-comparison paragraph: change `132 ns p50 against Boost's 140 ns` to `122 ns p50 against Boost's 140 ns`, and `identical at 172 ns` to `identical at 180 ns`. The p99 clause `164 ns vs 172 ns` is unchanged (still correct). Direction is preserved: hand-rolled edges p50 and p99, ties p99.9 — "edging it at the median and tying it in the tail" stays accurate.

## Task 6 — "What this doesn't show" bullet

Replace the "Offered loads near saturation exhaustively" bullet with:

```
- **Over-saturation as a single curve**: past the saturation knee the per-point
  behaviour is bistable (see above), so the over-saturation region is characterised
  by its mode distribution, not one interpolated curve. Sub-saturation behaviour
  between sweep points is interpolated, not measured.
```

## Task 7 — Takeaway

Replace the final sentence (lines 268–270, "The load-sweep chart shows where that breakdown begins…reaches its own ceiling.") with:

```
The load-sweep chart shows where that breakdown begins — and past saturation it
shows something subtler: the queue is bistable, settling deep or shallow per run,
so a single overload number is a coin toss. The reproducible result is the
sub-saturation tail: at moderate load the lock-free path's tail runs tens of
microseconds tighter than the mutex's, every run.
```

The "~1.8 items on average" mutex figure stays — it is now derivable from the `depth_mean` field added in Task 1.

## Task 8 — Footer isolation

`cores 0–7 isolated` → `cores 1–7 isolated`.

## Task 9 — Frontmatter date

`date: "2026-05-18"` → `date: "2026-06-05"`.

## Acceptance

1. `04-spsc-queue-overload-modes.json` exists, validates, and its medians match the values in Task 0; the raw log is committed under `bench/diagnostics/04/`.
2. `04-spsc-queue.json` carries `mean_ns` and `depth_mean` on every run's stats; 1 MHz mutex `depth_mean` rounds to ~1.8; `git` shows no change to the captured histogram/percentile values (Task 1 is additive).
3. MDX: `grep -c 'two different saturation mechanisms\|190 µs\|14.7 M/s and 14.9 M/s\|3× slower\|19.8 M/s\|saturates around 9 MHz\|single spike at the 16 MHz'` → 0.
4. MDX: `grep -c 'two equilibria\|bistable\|per process\|coin toss'` → ≥3; the overload table is present with the three rows.
5. MDX: `grep -c "Boost's 122\|132 ns p50\|identical at 172"` → 0; `grep -c "122 ns p50 against Boost's 140"` → 1; `grep -c 'identical at 180 ns'` → 1.
6. MDX: `grep -c 'cores 0–7'` → 0; `grep -c 'cores 1–7 isolated'` → 1; `grep 'date:'` → `2026-06-05`.
7. The `<Benchmark chart="latency-vs-load">` block is unchanged — the sub-saturation clamped curve still renders; no chart-component edit.
8. `npm run build` clean; Lighthouse ≥ 90 on the post.

## Out of scope

- Any rig recapture. If a future headline recapture of the over-saturation region is wanted, it must sample many *processes* (not iterations) per point and report the distribution — its own brief.
- Chart-component changes. The clamp already restricts the rendered curve to sub-saturation, which is exactly the reproducible regime; the bimodality is told via the static table from Task 0.
- The cross-link to demo 2 (already landed) and the CCDF/PDF headline charts (sub-saturation, unaffected).
- The `perf_event_paranoid`/governor capture-precondition hardening — separate standing brief.

## Open items

1. The governor-dependence of the mode split (performance ⇒ mutex mostly shallow; schedutil ⇒ mostly deep) is stated in the prose from the two diagnostic runs. If you want it shown rather than asserted, a small appendix table from both runs would do — flag if wanted; not included to keep the section tight.
2. Clock forensics held for demo 04 too: June and May clock-sensitive numbers agree where both are shallow-mode, so the old capture was at base clock; consistent with demos 02/03. Correction-note material.
3. This is the fourth demo whose old/new divergence was an environment effect rather than a result — the correction note's framing should be "boost verification absent; several demos also exposed kernel/governor sensitivity surfaced by the recapture," not "results were boosted."
