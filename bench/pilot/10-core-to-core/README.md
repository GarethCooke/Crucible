# Demo 10 — core-to-core ping-pong calibration pilot (throwaway)

This is a **throwaway** pilot bench. It answers the §A calibration questions in
`docs/demo-10-plan.md` §1 before the demo 10 implementation brief
(`10-core-to-core-brief.md`, §2) is written. It is **not** wired into
`run_one.sh`, ships nothing to `site/`, and is deleted or absorbed when the
implementation brief lands.

**Target hardware:** Machine 1 only — Ryzen 7 3800X (Matisse, Zen 2, 2 CCX × 4
cores), SMT off, `isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7` (isolated set 1–7,
core 0 = housekeeping). It builds and runs anywhere, but the numbers are only
meaningful on that isolated rig.

The bench **discovers** the numbers; it decides no gate. Protocol, window size
`K`, and core-0 include/exclude are decided from the data with Opus/the user.

## Build

```bash
cmake -S bench/pilot/10-core-to-core -B bench/pilot/10-core-to-core/build
cmake --build bench/pilot/10-core-to-core/build
```

## Run sequence

**1. Ground truth (hardware topology, before any measurement):**

```bash
./bench/pilot/10-core-to-core/topology.sh
```

On Zen 2, L3 `shared_cpu_list` sharing *is* CCX membership. This dumps the CCX
grouping straight from sysfs and becomes A1's prediction; the harness then
confirms or contradicts it by measurement. It writes `pilot_logs/topology.txt`.

**2. GUI-safe gates — the desktop may stay up:**

```bash
./bench/pilot/10-core-to-core/run_pilot.sh            # A1, A2, A3
```

A1–A3 touch only cores 1–7, which `isolcpus` protects from the desktop
entirely, so they are safe to run with the GUI up.

**3. A4 only — must be headless:**

```bash
./bench/scripts/headless-capture.sh \
    ./bench/pilot/10-core-to-core/run_pilot.sh --a4
```

A4 measures **core 0's row**. Under a GUI, core 0 also carries gdm, the
compositor and the desktop session, so a GUI-up A4 measures "core 0 plus your
desktop" and the verdict comes out wrong. `run_pilot.sh --a4` therefore calls
`assert_headless` and refuses to run under an active `graphical.target`; the
`headless-capture.sh` wrapper drops the desktop, runs, and brings it back.

If A3's IQR comes out marginal against the intra/cross gap, re-run A3 headless
the same way before locking `K`.

## Round 2 — resolving A3 (L3-slice placement)

Round 1 left A3 inconclusive: pair medians were **bimodal** (~72 / ~80 ns) and
swung 11% between otherwise-identical invocations. The leading hypothesis is
**L3 slice placement** — round 1 allocated the ping-pong line on the stack, so
each process invocation (ASLR-randomised) homed it to a different L3 slice.
Round 2 turns that confound into a measured variable via a controlled arena.

New harness flags (see `./build/pingpong --help`):

| Flag | What it does |
|------|--------------|
| `--offset BYTES` | place the ping-pong line at `arena+BYTES` (64 B-aligned) in one 2 MiB, THP-advised arena; the header reports whether a huge page was obtained |
| `--repeat N [--seed S]` | re-run the whole measurement at `N` pseudo-random offsets (one allocation each) and report the distribution of per-run medians — the **across-allocation** error bar. Reproducible per seed |
| `--offset-sweep [--offset-sweep-range B]` | step the line through systematic offsets, print median RTT per offset. Range >4 KiB needs a huge page (clamped with a warning otherwise) |
| `--baseline --pair a,b` | single thread, line resident in L1, the same two atomic stores as a round trip but no transfer and no spin — the fixed cost X |
| `--orchestrator-core C` | pin the orchestrator to core C (default 0) |

New `run_pilot.sh` gates — all **HEADLESS ONLY** (`assert_headless`), and the
preflight now also asserts `performance` governor on all eight cores by reading
sysfs directly:

- `--a3b` — A3's K sweep with `--repeat 20` at each K (compare across-allocation
  IQR against the intra/cross gap, not within-window IQR).
- `--a6` — offset sweep on the intra and cross pair.
- `--a7` — baseline X on cores 1, 2, 4, 5.
- `--a8` — pair (1,2) and (4,5) each with the orchestrator on cores 0, 3, 4, 7.

One headless pass (the user runs this):

```bash
./bench/scripts/headless-capture.sh bash -c \
  './bench/pilot/10-core-to-core/run_pilot.sh --a3b && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a6  && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a7  && \
   ./bench/pilot/10-core-to-core/run_pilot.sh --a8'
```

## Files

| File | What it is |
|------|-----------|
| `topology.sh` | sysfs topology dump — L3/L2/L1d sharing, isolation state, lstopo if present |
| `pingpong.cpp` | custom pinned-thread cache-line ping-pong harness (see `--help`) |
| `run_pilot.sh` | gate runner: `--a1` `--a2` `--a3` `--a4`; default runs A1–A3 |
| `reconciliation-inventory.md` | A5 — earlier-post cross-CCX prose vs its JSON, re-derived |
| `CMakeLists.txt` | standalone build (C++20, `-O3 -march=native`, pthreads) |

## Harness at a glance

- **Two protocols:** `exchange` (default, one shared atomic, even/odd handoff)
  and `twoflag` (two atomics on separate cache lines, one per direction).
- **Affinity is asserted, not assumed:** each worker reads back `sched_getcpu()`
  and aborts if it is not on the requested core.
- **No self-false-sharing:** the ping-pong atomic(s) are `alignas(64)` and kept
  off the lines holding counters/results; a `static_assert` guards the gap.
- **Timing:** `rdtscp` bracket per window of `K` round trips, warmup windows
  discarded, median + IQR over ≥20 timed windows, reported in nanoseconds.
- **TSC→ns** is calibrated once at startup against `CLOCK_MONOTONIC` and printed.

See `./build/pingpong --help` for the full flag list.
