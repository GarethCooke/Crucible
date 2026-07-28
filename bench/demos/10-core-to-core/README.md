# Demo 10 — core-to-core latency across the Zen 2 CCX boundary

Measures how long a single cache line takes to bounce between two pinned cores.
Intra-CCX pairs hand the line over through their shared L3 slice; cross-CCX
pairs route it out to the IO die over Infinity Fabric. The gap between those two
numbers is the CCX seam, and the 8×8 matrix makes it visible as block structure.

**Reference figures** (Machine 1, Ryzen 7 3800X / Matisse, SMT off, boost off,
`isolcpus=1-7`, headless): intra 72.1 ns, cross 160.2 ns — **2.20×** at K=1000,
`exchange` protocol. Round-trip times, never halved.

x86-64 only: the harness uses `rdtscp` and this rig's invariant TSC.

## Capture

```bash
sudo ./bench/scripts/headless-capture.sh ./bench/scripts/run_one.sh 10-core-to-core
```

That produces three files under `site/src/data/perf/`:

| File | Contents |
| --- | --- |
| `10-core-to-core.json` | headline: the `latency_matrix` block — 8 cores, 8 baselines, 28 unordered pairs |
| `10-core-to-core.slice-sweep.json` | exhibit: RTT vs cache-line placement, one intra + one cross pair |
| `10-core-to-core.protocol.json` | exhibit: `exchange` vs `twoflag` on the same two pairs |

The binary writes complete, ready-to-ship JSON to stdout. There is no
`assemble_results_*.py` step and no `parse_perf.py`: every string in the output
is a literal in `benchmark.cpp`, and the `machine` block is
`crucible::machine_info_json()` verbatim.

`run_one.sh` re-asserts `assert_isolated_cores`, `assert_smt_off`,
`assert_boost_off`, `assert_headless` and `set_governor_performance` inside the
demo-10 branch, **unconditionally** — `--skipchecks` does not bypass them. The
§1 pilot showed that a path skipping these produces plausible-but-wrong numbers.

Demo 10 also runs **without** a `cset` shield, unlike demos 01–08. It needs all
eight cores including core 0, and pins every worker itself with an asserted
`sched_getcpu()`; a shield confined to 4-7 would make those pins fail.

### Second capture

Per the demos 05–08 multi-capture rule, the headline is captured **twice**. The
convention those demos established: the current capture lives at
`site/src/data/perf/<slug>.json` and the other is moved to
`site/src/data/perf/archive/<slug>_<YYYY-MM-DD>.json` (the date is that file's
own `captured_at`), then both are cited in the post's prose.

`run_one.sh` does the archiving **automatically**, so just run it twice. Before
publishing a new capture it moves any existing `10-core-to-core.json` — and the
two sibling exhibit files, which are also written to fixed paths — to
`archive/<basename>_<its captured_at date>.json`. The date comes from the old
file's own `captured_at`, not from today; if that field is unreadable it falls
back to the file mtime and says so loudly, because an mtime is a write date and
not necessarily a capture date. A destination that already exists is never
clobbered — the run appends `_2`, `_3`, … and notes which name it used.

This is deliberately not an advisory. Demo 10 captures under
`headless-capture.sh` with the desktop down, so a "move the previous file first"
warning has nobody to read it, and the second capture would destroy the first —
the one file the two-capture rule needs to compare against. The move happens
after all three captures have been taken and validated, so an aborted run leaves
the previous capture live where it was.

The two captures must agree on **CCX block structure and the seam ratio within
the across-placement error band**. Per-cell differences inside that band are
expected — slice placement — and are not a retraction trigger. The error bar
already owns them.

### Cross-checks

Before archiving anything, `run_one.sh` also cross-checks the finished files
against each other: the protocol exhibit's `exchange` cells re-measure two
matrix cells, and if either disagrees with its matrix cell by more than 5% the
capture fails. Each capture invocation allocates its own arena pool, and arenas
allocated in one burst can be physically clustered in the high-order address
bits that feed the L3 slice hash — a correlated pool can land a whole capture
on a minority slice mode (seen once in §7: 79.3 ns vs the matrix's 72.1 ns on
pair (1,2), both with tight IQRs). The cross-check turns that from a silently
inconsistent pair of shipped files into a re-run signal.

## Why cells are averaged over a 20-arena pool

Cache-line placement modulates RTT along **two independent axes**, and conflating
them is what broke the first calibration attempt:

| axis | cross-CCX | intra-CCX |
|---|---|---|
| offset **within** a physical frame | bimodal, ~160 vs ~166 ns (~4%) | flat (§1/A6 swept a whole 2 MiB frame: every offset 72.13 ns) |
| **which** physical frame the arena occupies | varies | varies — high-order physical address bits feed the Zen 2 L3 slice hash |

The original design measured each cell at 20 pseudo-random offsets inside **one**
shared arena. That samples only the first axis — the one intra-CCX is flat on —
so it reported whichever frame that single arena happened to land on, with an
error bar that described nothing. Two such captures of pair (1,2) came back
**72.13 ns (IQR 0.01) and 79.93 ns (IQR 0.14)**: 11% apart, error bars not even
touching. Tight and wrong. Worse, the two §6 captures would have built
independent arenas on independent frames and the corroboration rule would have
flagged two correct captures as inconsistent.

So each cell is now measured across a **pool of 20 independent arenas**,
allocated once at capture start and **held live simultaneously** for the whole
capture. That is the guarantee: concurrent private anonymous mappings cannot
share physical backing, so the 20 arenas occupy 20 distinct physical frames *by
construction* — no `/proc/self/pagemap` (root-only) needed. Placement `i` of
every cell uses pool arena `i` at a per-cell seeded random 64 B-aligned offset,
so the 20 placements span both axes at once.

One honest limit: *distinct* frames are not automatically *independent* frames.
The pool is allocated in one burst, so its frames can be clustered in the very
address bits that feed the slice hash, and a whole pool can occasionally land
on one slice mode with a deceptively tight across-placement IQR. That is what
the two-capture rule and the `run_one.sh` exhibit-vs-matrix cross-check exist
to catch.

The **same pool serves every cell**, which is what keeps the matrix internally
comparable: if cell A sampled frames {f1..f20} and cell B sampled {g1..g20},
cell-to-cell differences would be confounded by frame-set differences. Every cell
sees the same 20 frames, so what is left is the core-pair effect.

The cell value is the median of the per-placement medians; `iqr_lo`/`iqr_hi` are
the quartiles of that same distribution. `--pair a,b --repeat N` samples the same
way (an N-arena pool), so a diagnostic re-measurement reproduces what a capture
cell does rather than the single-frame answer — pair order is irrelevant, since
the offset seed is canonicalised on the unordered pair, so `--pair 4,1` draws
the same offsets as the capture's (1,4) cell; `--verbose` prints the
per-placement medians with their arena address and offset, which is the
distribution to look at when a cell's spread is the question. Only `--repeat 1`
and the offset sweeps stay on a single arena, which is what they are for.

## Statistics contract

The house `stats` shape is eight fields — `median`, `min`, `max`, `p99`, `iqr`,
`iqr_lo`, `iqr_hi`, `n_reps` — as emitted by every `ns_per_op` in
`07-no-crossover.json` and its siblings. `rtt_ns` and `baseline_ns` emit seven of
them, a clean subset in the same field order:

```
median, min, max, iqr, iqr_lo, iqr_hi, n_reps
```

Following demo 07 — the only other demo carrying an error band — **`iqr_lo` and
`iqr_hi` are absolute quartiles in nanoseconds (Q1 and Q3), not widths around the
median**; `iqr` is their difference, taken at full precision before rounding,
exactly as `bench/scripts/stats_utils.py` computes it. A perfectly stable pair can
give `iqr == 0`; that is a correct answer and the field is still emitted.

**`p99` is deliberately omitted.** In demos 01–08 the distribution is raw per-rep
latencies, where a 99th percentile is a meaningful tail. Here the distribution
being summarised is the 20 per-placement medians, *not* the raw timing windows, so
a `p99` over 20 already-averaged values is the near-maximum of an average rather
than a latency tail — reporting it would invite a false tail reading. The emitted
`notes` field states all of this, including the omission and its reason, so a
cross-read does not have to guess whether the missing field was an oversight.

## Diagnostic modes

Retained from the §1 pilot so §4 can re-verify the production harness against
the calibration reference:

```bash
BIN=bench/build/demos/10-core-to-core/bench_10_core_to_core

$BIN --full-matrix --repeat 20            # text matrix + across-placement IQR
$BIN --pair 1,4 --repeat 20               # one cell
$BIN --pair 1,4 --baseline --repeat 20    # fixed cost X on each core
$BIN --pair 1,4 --offset-sweep --offset-sweep-range 2097152
$BIN --pair 1,4 --orchestrator-core 3     # A8: placement-independence check
$BIN --protocol twoflag --pair 1,4 --repeat 20
$BIN --machine-info                       # same shape as demo 4's
```

`--orchestrator-core` is diagnostics-only. Capture modes always apply the
`lowest-free-isolated` rule (see below) and record it in the JSON.

**The tuning flags above are diagnostics-only too.** All three capture modes run
at locked parameters — `protocol=exchange`, `k=1000`, `windows=20`, `warmup=5`,
`placements=20` — and passing any of `--protocol`, `--k`, `--windows`, `--warmup`
or `--repeat` alongside one of them is a hard error naming both the offending flag
and the mode, not a silent override.

It has to be. `--capture --k 7` would emit `k_roundtrips: 7`: self-consistent,
passes every schema check in `run_one.sh`, and not comparable with any other
capture. This demo already produced one plausible-but-wrong headline from a stray
parameter (a governor default, a phantom 1.40× that validated cleanly); this
closes the second such path.

The two exhibit modes ship files too, and they fail in **both** directions.
`--k`/`--windows`/`--warmup` land in their JSON verbatim, so the exhibit stops
being comparable with the matrix it exists to explain. And `--protocol` is a
silent no-op in both — the slice sweep hardcodes `exchange`, the protocol exhibit
measures both by construction — as is `--repeat` in the slice sweep, which sweeps
every line instead of sampling placements. A flag that looks honoured and does
nothing is worse than one honoured wrongly, because nothing in the output
contradicts it. So the lock covers all three.

The sweep span (`--offset-sweep-range`, `--offset-sweep-step`) is deliberately
**not** locked: it shapes how much of the arena the exhibit covers, not the
measurement, and `run_one.sh` sets it to reach the full 2 MiB huge page.

The no-silent-ignore rule extends to every other flag a mode would discard:
`--offset` is rejected by all three capture modes, `--seed` by the slice sweep,
and the sweep span flags by the other two captures. The diagnostic modes apply
the same rule to their own combinations — `--offset` with `--repeat N>1`,
`--seed` at `--repeat 1`, `--repeat` or `--offset` with `--offset-sweep`,
`--protocol` with `--baseline`, and conflicting diagnostic modes are all hard
errors rather than silent no-ops. The diagnostic modes honour all five locked
flags exactly as before.

**What the printed bracket summarises depends on `--repeat`,** and the two are
different distributions. At `--repeat N` (N > 1) it is the N across-placement
medians — the same statistic a capture cell reports. At the default `--repeat 1`
there is only one placement, so it is that placement's timed windows, which is
what the §1 pilot printed and what §4 compares against. Each line names its own
unit (`n=20 placements` vs `n=20 timed windows`) so the two can't be confused.

## THP

**The slice-sweep exhibit needs a huge page; the matrix does not.**

The sweep is only physically meaningful across contiguous memory: past a page
boundary, virtual offsets stop tracking physical offsets. Without a transparent
huge page the harness clamps the sweep to one 4 KiB page, sets
`arena_hugepage: false`, and `run_one.sh` prints a loud warning — the exhibit
still emits and still validates, so nothing else would catch it. That exhibit is
the one place in demo 10 that is deliberately **single-frame**: showing
within-frame offset dependence requires one contiguous frame, so it keeps one
2 MiB THP arena and its `notes` says so, to stop a reader applying the matrix's
multi-frame reasoning to it.

The matrix tolerates arenas that miss THP rather than aborting. A random offset
in a 4 KiB-page arena still lands on a physical page whose address feeds the
slice hash, so it is still a valid frame sample — arguably a better one, since
small pages give more frame diversity. `arenas_hugepage_obtained` records how
many of the 20 got one (the old top-level `arena_hugepage` boolean is gone: it
described a single arena, and there is no longer a single arena). A capture with
`arenas_hugepage_obtained < 20` is reportable, not a failure.

One trap worth knowing: THP can be disabled *per process tree* by
`PR_SET_THP_DISABLE`, which is inherited across fork/exec. A shell whose ancestor
set it will report 0/20 THP no matter what `/sys/kernel/mm/transparent_hugepage/`
says. Check `grep THP_enabled /proc/self/status` (`0` means disabled) before
concluding the machine is out of huge pages.

## Orchestrator placement

Core 0 is a measured worker, so the pilot's "pin the orchestrator to core 0"
no longer holds. For each pair `(a, b)` the orchestrator pins to the
lowest-indexed core in the isolated set that is not in `{a, b}` and asserts its
own `sched_getcpu()`, exactly as the workers do. During the timed region it is
blocked in `pthread_join` — a futex sleep, not a spin — which is why A8 found
its placement makes no difference to the pair.

## Provenance

The measurement core is promoted unchanged from the §1 calibration pilot at
`bench/pilot/10-core-to-core/pingpong.cpp`, committed on the
`pilot/demo-10-core-to-core` branch together with the two capture logs that
locked the protocol, K, the core-0 decision and the placement-averaging design.

Post: `site/src/posts/10-core-to-core.mdx` (slug `10-core-to-core`).
