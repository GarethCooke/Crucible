# Crucible — demo 10 §1 pilot round 2: resolving A3

Opus → CC, same throwaway branch (`pilot/demo-10-core-to-core`). Extends the round-1 pilot bench; still `bench/pilot/10-core-to-core/`, still not wired into `run_one.sh`, still deleted or absorbed when the §2 implementation brief lands.

## Context

Round 1 (headless, `performance` governor, log `capture-20260723T162234.log`) settled three gates and left one open.

- **A1 — GO.** Measured blocks match sysfs L3 exactly: `{1,2,3}` and `{4,5,6,7}`. Max intra 80.1 ns, min cross 157.5 ns — 77 ns of clear air, no overlap in either run. Block ratios 2.22× and 2.19×, run-to-run cross drift ~1.5%.
- **A2 — exchange.** Exchange 158.80/72.11 = 2.20×; twoflag 273.13/86.38 = 3.16×. Twoflag moves two lines and pays the fabric crossing twice — 2×(T_cross−T_intra) is 173 ns vs 374 ns. Exchange is the headline; twoflag is the comparison figure.
- **A4 — core 0 is clean.** IQRs 0.00–1.97 ns, no housekeeping stripe.
- **A3 — INCONCLUSIVE.** This brief exists to close it.

**Why A3 failed.** Invocation-to-invocation variation swamps the K effect. Pair (1,2) at K=1000, four separate invocations across A1/A2/A3: **80.1, 77.6, 72.11, 80.21**. A2 and A3 ran identical configurations 30 seconds apart and differ by 11%. The cross cell across the K-sweep goes 166.4 → 158.8 → 163.4 — non-monotonic, so no K trend is readable.

The values are **bimodal, not noisy**: they cluster near 72 or near 78–80 with little in between. A3's own K=1000 window set has IQR 8.12 ns, min 72.10, max 80.37 — it straddled both modes inside a single invocation. ~8 ns ≈ 31 cycles at 3.9 GHz.

**Leading hypothesis: L3 slice placement.** A Zen 2 CCX splits its 16 MB L3 across four slices, selected by a hash of the line's *physical* address. Each invocation allocates the ping-pong line at a fresh address, so it homes to a different slice, and slice distance from the two participating cores differs. That would produce exactly this signature: discrete modes rather than a continuum, stable within an allocation, varying across allocations.

**Second observation needing explanation.** Intra-CCX0 pairs among `{1,2,3}` skew high (80.1, 79.1, 76.5 / 77.6, 79.1, 73.4) against `{4,5,6,7}` (70.8–73.4). But core 0's own intra-CCX0 pairs from A4 are *fast* (73.4, 73.2, 72.1) — so "core 0's housekeeping pollutes CCX0's L3" does not by itself explain it, since core 0 is in CCX0. The distinguishing feature of the A4 measurements is that **core 0 is a worker there**, whereas elsewhere it is the orchestrator, a third party in CCX0. Task 5 tests that. Note the skew may also be partly sampling from the bimodal distribution — run 2's pair (2,3) at 73.4 sits in the fast mode — so this must be judged against the round-2 across-allocation distributions, not the round-1 point estimates.

**Guardrails unchanged:** nothing under `site/`, no JSON in `site/src/data/perf/`, no schema touched, no `run_one.sh` demo wiring, no numerical targets invented.

## Tasks

### Task 1 — Report the current allocation lifetime, then move the line into a controlled arena

**1.1 (do first, report before building anything).** State plainly in the PR notes: in the current `pingpong.cpp`, is the ping-pong line allocated **once per process**, once per pair, or once per window? This determines how every round-1 number is read. If one allocation serves the whole `--full-matrix` run, all 21 cells shared a slice and the within-matrix CCX0/CCX1 skew is a real effect. If each pair re-allocates, that skew may be address noise. **Do not proceed to 1.2 before reporting this.**

**1.2 — Controlled arena.** Replace the ad-hoc allocation with a single arena whose offset is selectable:

- Allocate one 2 MiB region, 2 MiB-aligned (`posix_memalign` or `mmap`), `madvise(MADV_HUGEPAGE)`, then touch every page to fault it in.
- **Verify and report** whether a huge page was actually obtained — parse `AnonHugePages` for the mapping from `/proc/self/smaps`. This matters: with 4 KiB pages, virtual offsets stop tracking physical offsets past page boundaries and the sweep in Task 3 only probes within a page. Print the result at startup; if THP was not obtained, print a warning and clamp the sweep range to 4 KiB.
- The ping-pong line sits at `arena + offset`, `offset` 64 B-aligned, default 0, settable via `--offset BYTES`.
- Harness bookkeeping stays where it is — on its own cache lines, well away from the arena. The existing `static_assert`s must still hold.

### Task 2 — `--repeat N`: across-allocation distribution

Within one process, repeat the whole measurement N times (default 20), each at a **different arena offset**, and report the distribution *of the per-run medians*:

- Offsets: pseudo-random 64 B-aligned offsets within the arena, from a fixed seed so runs are reproducible. Print the seed.
- Output: median-of-medians, IQR across the N medians, min, max, **and the full sorted list of N medians** — the list is the point, because bimodality is invisible in a summary statistic.
- Works with `--pair` and with `--full-matrix` (for the matrix, apply the repeat per cell; keep the output readable — a matrix of median-of-medians plus a separate across-allocation IQR matrix).

This converts the address effect from an uncontrolled confound into a measured error bar, which is what the project's multi-capture principle requires for fine-structure claims.

### Task 3 — `--offset-sweep`: confirm or kill the slice hypothesis

Step the line through systematic offsets and print median RTT per offset:

- Default: 64 offsets, `0` to `4032` step 64 (one 4 KiB page — safe even without THP).
- `--offset-sweep-range BYTES` to extend (meaningful only if THP was obtained; refuse politely and explain if not).
- Output: a plain two-column list, offset → median RTT, for one intra pair and one cross pair. A repeating pattern with period equal to a small number of lines, or discrete clustering into a few levels, confirms slice placement. A flat line refutes it and sends us hunting elsewhere.

### Task 4 — `--baseline`: isolate the fixed protocol cost

Single thread, pinned to one core, line held exclusively in its L1 — same inner loop, no cross-core transfer. Per "round trip" it must perform **the same two atomic stores** as the exchange protocol so the comparison is like for like; skip only the spin-wait, which would be satisfied immediately anyway. Acquire/release ordering unchanged.

- `--baseline --pair a,b` runs the baseline on each of `a` and `b` separately and prints both (they should agree closely; a disagreement is itself informative).
- Report median + IQR, and honour `--repeat` and `--offset`.

This gives X, the fixed cost — atomic RMW into L1, loop overhead, amortised rdtscp. The transfer component is then `(RTT − X)/2` per direction, and the post can report raw RTT *and* the transfer component rather than letting harness overhead silently set the headline multiple. Do not compute or assert any ratio in the harness; print the numbers and let the analysis happen outside.

### Task 5 — `--orchestrator-core C`: placement test

Make the orchestrator's pinned core configurable (default unchanged: core 0).

Also **report, in the PR notes, what the orchestrator actually does while a pair is being measured** — spinning, blocked in `pthread_join`, waiting on a condvar? A spinning orchestrator contends for its CCX's L3; a sleeping one largely does not. This single fact may explain or dismiss the asymmetry without any measurement.

### Task 6 — `run_pilot.sh` gates

Add, keeping the existing `--a1`/`--a2`/`--a3`/`--a4` intact and the default unchanged:

- `--a3b` — re-run the K sweep `{100, 1000, 10000}` **with `--repeat 20`** at each K, for the intra and cross pairs. This is the real K-lock: compare across-allocation IQR against the intra/cross gap, not within-window IQR.
- `--a6` — offset sweep, intra and cross pair.
- `--a7` — baseline on cores 1, 2, 4, 5.
- `--a8` — pair (1,2) with orchestrator on 0, 3, 4, 7; then pair (4,5) with orchestrator on 0, 3, 4, 7. Prints a small table.

All four are analysis-grade and must run headless: gate them with `assert_headless`, as `--a4` already is.

**Also add the governor to `run_pilot.sh`'s own preflight** — assert `performance` on all eight cores by reading sysfs directly (`grep -Lx performance /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`), not via `cpupower ... | grep`. Round 1's first attempt ran under `schedutil` and produced a plausible-looking 1.40× that was pure artefact. A standalone script that bypasses `run_one.sh` bypasses every guarantee `run_one.sh` provides, so it must assert its own.

## Acceptance

- **Scope:** `git status --porcelain` shows changes only under `bench/pilot/10-core-to-core/`. `grep -c '10-core-to-core' bench/scripts/run_one.sh` → 0. No `site/`, `docs/`, or perf-JSON file touched.
- **Builds clean, no warnings.** `--help` lists `--repeat`, `--offset`, `--offset-sweep`, `--offset-sweep-range`, `--baseline`, `--orchestrator-core`.
- **Ordering unchanged:** `grep -c memory_order_seq_cst bench/pilot/10-core-to-core/*.cpp` → 0.
- **Alignment intact:** existing `alignas(64)` count and `static_assert`s still present and passing.
- **Governor gate:** `grep -c 'scaling_governor' bench/pilot/10-core-to-core/run_pilot.sh` ≥ 1; the check reads sysfs, and `grep -c 'cpupower' run_pilot.sh` → 0.
- **Headless gates:** `--a3b`, `--a6`, `--a7`, `--a8` each exit non-zero under an active `graphical.target`.
- **Argument validation:** `--repeat -1`, `--offset -64`, `--offset 33` (unaligned), `--orchestrator-core 99` all exit 2 with a clear message, per round 1's `parse_count`/`parse_core` hardening.
- **Reproducibility:** two `--repeat 20` runs with the same seed produce the same offset sequence.
- **Task 1.1 answered in the PR notes before any code lands.**

## Out of scope

- Schema, machine block, charts, MDX, `site/` — §2.
- Deciding K, protocol, or core-0 inclusion — the data decides with Opus/user.
- Changing the exchange/twoflag protocol semantics.
- Physical-address readout via `/proc/self/pagemap` — root-only and not needed; the offset sweep tests the hypothesis without it.
- Fixing the false-pass governor check in `tools/prepare_bench.sh`, or consolidating it with `bench/scripts/lib.sh` — real, but belongs in the owed hardening brief.

## Open items for CC to flag

1. **Allocation lifetime (Task 1.1)** — report before building. It changes how round 1 is read.
2. **THP obtained or not**, per `/proc/self/smaps`. If not, say so loudly; the sweep range is then only 4 KiB and Task 3's power is reduced.
3. **Orchestrator behaviour** — spinning or sleeping (Task 5).
4. **Bimodality confirmed or not** — does `--repeat` reproduce discrete ~72/~80 modes, or a continuum? If a continuum, the slice hypothesis is wrong and round 1's bimodal reading was small-sample illusion.
5. **Baseline sanity** — if X exceeds the intra-CCX RTT, something is wrong with the baseline loop; stop and report rather than publishing a negative transfer time.
6. **Any pair where across-allocation IQR exceeds the intra/cross gap** — that would put the seam itself in question at that offset, and is a stop-and-report finding.

## Run sequence (user, one headless pass)

```bash
./bench/scripts/headless-capture.sh bash -c \
  './bench/pilot/10-core-to-core/run_pilot.sh --a3b && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a6  && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a7  && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a8'
```

`--a3b` dominates the runtime (3 K values × 2 pairs × 20 repeats × 20 windows). The `&&` chain stops on first failure, which is the wanted behaviour.
