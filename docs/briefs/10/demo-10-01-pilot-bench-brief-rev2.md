# Crucible — demo 10 §1 pilot bench build brief (rev 2)

Opus → CC, on a throwaway working branch (nothing here ships). Companion: `demo-10-plan.md` §1.

**Rev 2 supersedes rev 1 and the WSL2 sections of `demo-10-core-to-core-pilot-scope.md`.** Rev 1 was authored against a false premise — that Machine 1 captures run under WSL2. They do not. Machine 1 is a **dual-boot box running native Ubuntu 24.04** (`6.8.0-134-generic`, LVM root, GRUB); Windows is a separate boot, not a host. All captures for demos 1–9 were taken on native Ubuntu. Where this brief and the pilot scope disagree, **this brief wins**. The plan needs the same correction (see §Plan corrections).

**This is throwaway calibration scaffolding, not demo code.** It answers §A before the implementation brief (`10-core-to-core-brief.md`, §2) is written, and is deleted or absorbed when that brief lands.

## Context

- Demo 10 measures pairwise cache-line ping-pong RTT across the isolated cores of the Zen 2 rig (Ryzen 7 3800X, Matisse, 2 CCX × 4 cores, SMT off, `isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7`, isolated set = cores 1–7, core 0 = housekeeping). The finding is the CCX seam: intra-CCX pairs exchange a line through their shared L3 slice, cross-CCX pairs via the IO die over Infinity Fabric.
- **What changed from rev 1, and why it matters.** On bare metal there is no vCPU→pCPU indirection, so core indices map directly to physical cores. Three consequences: (a) A1 is no longer a hard viability gate — it confirms measurability and assigns CCX membership, but the seam is a documented hardware property and is expected to appear; (b) absolute nanoseconds are trustworthy bare-metal values, with no hypervisor caveat — remaining caveats are FCLK dependence and Matisse-specificity; (c) **CCX membership is independently readable from sysfs**, so the pilot predicts from hardware and confirms by measurement rather than inferring topology from latency alone. (c) is new work — see Task 1.
- **Isolation is asserted, not assumed.** Every gate below verifies `/sys/devices/system/cpu/isolated` → `1-7` and `nohz_full` → `1-7` before running. A pilot run against an unisolated machine is worthless and must fail loudly rather than produce plausible numbers.
- **Guardrails (finding yourself outside these = STOP):** everything under `bench/pilot/10-core-to-core/`, except Task 0 which touches `bench/scripts/`. Nothing under `site/`. Nothing added to `run_one.sh`'s demo list. No JSON in `site/src/data/perf/`. No schema file touched. No numerical targets invented — this scaffolding *discovers* the numbers.
- Tasks 0–4 are build work; Task 5 (A5) is repo-side and completes now. The user runs the hardware gates.

## Tasks

### Task 0 — Capture tooling (`bench/scripts/`)

Two additions, both reusable well beyond demo 10.

**0.1 — `assert_headless` in `bench/scripts/lib.sh`.** Alongside `assert_smt_off` / `assert_isolated_cores`, matching their style:

```bash
# Aborts if a graphical session is active. Demos 1-9 were captured under
# multi-user.target; a GUI-up capture is not comparable to them.
assert_headless() {
    if systemctl is-active --quiet graphical.target; then
        echo "ERROR: graphical.target is active — captures must run headless." >&2
        echo "  Use: ./bench/scripts/headless-capture.sh <capture command>" >&2
        echo "  Or:  sudo systemctl isolate multi-user.target" >&2
        exit 1
    fi
}
```

Call it from `run_one.sh` alongside the existing asserts. Rationale: the benchmark boot entry previously carried a trailing `3` (multi-user runlevel) which made headless structural; that has been dropped in favour of booting to GUI for convenience, so the guarantee moves into the harness. The gate is strictly stronger than the old `3` — it also catches booting headless and then switching to the desktop mid-session.

**0.2 — `bench/scripts/headless-capture.sh`.** A wrapper that runs a capture headless from a GUI session and restores the desktop afterwards. A working version exists (supplied separately); **integrate it rather than reimplementing, with one required change: it must `source bench/scripts/lib.sh` and call `assert_isolated_cores`, `assert_smt_off` and `assert_boost_off` for its pre-flight instead of its own inline `cat`-and-compare checks.** The standalone version duplicates logic lib.sh already owns; DRY per the code-review skill, and it means the wrapper tracks methodology changes automatically via `EXPECTED_ISOLATED`.

Design points to preserve when integrating:
- Pre-flight runs **while the GUI is still up**, so a bad machine state produces a readable error rather than a black console.
- The capture runs inside a transient `systemd-run` unit, so it survives the session teardown that `systemctl isolate multi-user.target` causes. This is the crux — a naive inline script kills the terminal it is running in.
- `trap ... EXIT` restores `graphical.target` on every exit path including failure.
- The log records machine state **as measured after the GUI is down**, so it evidences capture conditions rather than asserting them.
- Root-created files are chowned back to the invoking user so git doesn't see root-owned output.

### Task 1 — Scaffold + sysfs topology cross-check (A0)

Scaffold `bench/pilot/10-core-to-core/` mirroring `bench/pilot/09-arm-neon/`: `CMakeLists.txt` (C++20, `-O3 -march=native`, pthreads, standalone `cmake -S . -B build`, not referenced from any top-level build) and a one-screen `README.md` stating it is throwaway, not wired into `run_one.sh`, Machine 1 only, with build/run lines.

**New in rev 2 — `topology.sh`**, a small script capturing ground truth *before* any measurement:

- `lscpu -e` (core/socket/node enumeration)
- L3 sharing per CPU: `for c in /sys/devices/system/cpu/cpu[0-9]*; do echo "$c: $(cat $c/cache/index3/shared_cpu_list)"; done` — **on Zen 2, L3 sharing is CCX membership**, so this yields the CCX grouping directly from hardware
- L1d/L2 sharing (`index0`, `index2`) for completeness
- `/sys/devices/system/cpu/isolated`, `nohz_full`, `smt/active`
- `lstopo-no-graphics --of console` if `hwloc` is installed (optional; note if absent)

Output plain text to stdout and `pilot_logs/topology.txt`. Expected on a 3800X with SMT off: two L3 domains, `0-3` and `4-7`. **Report what it actually says — do not assume.** This becomes A1's prediction, which measurement then confirms or contradicts.

### Task 2 — Ping-pong harness

Custom harness, **not** Google Benchmark (pairwise pinned-thread orchestration doesn't fit its model; demo 4's custom latency pipeline is the precedent).

- **Affinity.** Two worker threads per pair, each pinned via `pthread_setaffinity_np`. **Each worker reads back `sched_getcpu()` and asserts it equals the requested core before any timing.** Orchestrator pins itself to core 0, off the isolated set. An affinity-assert failure aborts with a clear message.
- **Two protocols:**
  - `exchange` (default) — one `alignas(64)` `std::atomic<uint64_t>`; one worker advances on even values, the other on odd; a round trip is one even→odd→even cycle (2 stores).
  - `twoflag` — two `alignas(64)` atomics, one written per direction (A writes `flag_a`, spins on `flag_b`; B spins on `flag_a`, writes `flag_b`). The two flags **must sit on separate cache lines**.
- **No self-false-sharing.** Ping-pong atomic(s) `alignas(64)`; per-thread counters, result buffers and token storage on *separate* lines. Demo 2's lesson applied to demo 2's own descendant — get it wrong and the blocks blur. `static_assert` on the offset gap.
- **Ordering:** acquire on the spin-load, release on the store. No `seq_cst`.
- **Timing:** `rdtscp` bracket per window of K round trips; `N_WARMUP` warmup windows discarded (demo 4's contamination lesson); ≥20 timed windows; **median + IQR** per pair, in nanoseconds.
- **Cycles → ns.** Calibrate the TSC→ns factor once at startup against `CLOCK_MONOTONIC` over ~100 ms; print it. Confirm `constant_tsc` / `nonstop_tsc` in `/proc/cpuinfo`; note if either is missing. The invariant TSC is why the pilot need not gate on boost state — record the factor for §2 to reuse.
- **CLI:** `--pair a,b` · `--full-matrix` · `--protocol {exchange,twoflag}` · `--k K` · `--windows W` (default 20) · `--warmup N` · `--include-core0` · `--verbose`.
- **Output:** plain text only. Full-matrix prints a labelled median-RTT matrix; single-pair prints median + IQR. Every run prints the isolated-core set, the TSC→ns factor, and `graphical.target` active state at the top (so a log shows whether it was a GUI or headless run).

### Task 3 — `run_pilot.sh`

Logs to `pilot_logs/`. Gate groups, selectable so the user can run the GUI-safe ones separately from the headless-only one:

- `--a1` — `--full-matrix` **twice, back to back**; print both matrices.
- `--a2` — one intra-CCX and one cross-CCX pair under both protocols; print four medians.
- `--a3` — same two pairs swept over K ∈ {100, 1000, 10000}, ≥20 windows each; print median + IQR per K.
- `--a4` — **core 0's row only** (`--include-core0`, core 0 paired with each isolated core). Calls `assert_headless` first and refuses to run under a GUI (see Task 4 rationale).
- default (no flag) — runs A1, A2, A3.

The representative intra/cross pairs for A2/A3 are taken from **`topology.sh`'s L3 grouping**, not hardcoded — and the script prints which pairs it chose and why. It does not decide any gate; it lays out numbers.

### Task 4 — Headless enforcement for A4

A4 measures core 0's row to decide include-with-caveat vs exclude, based on whether housekeeping traffic makes it too noisy. **Under a GUI, core 0 also carries gdm, the compositor and the desktop session, so a GUI-up A4 measures "core 0 plus your desktop" and the verdict comes out wrong.** A1–A3 touch only cores 1–7, which `isolcpus` protects from the desktop entirely, so those are GUI-safe.

Wire `assert_headless` into `run_pilot.sh --a4` and document the split in the pilot README.

### Task 5 — A5 reconciliation inventory (repo-side, do now)

No hardware. From the repo, never memory:

1. `grep -rin` `site/src/posts/*.mdx` for: `CCX`, `cross-CCX`, `intra-CCX`, `Infinity Fabric`, `IO die`, `across CCX`. Demos 2, 4, 5 expected.
2. For each hit: quote the sentence, extract its numeric claim and direction/magnitude, locate the field in the companion `site/src/data/perf/*.json` it rests on, and **re-derive the figure from the JSON** — never trust the prose.
3. Write `bench/pilot/10-core-to-core/reconciliation-inventory.md`: *post · sentence · claimed direction & magnitude · source JSON field · JSON value · match?*
4. Flag disagreements; **do not fix them**. They feed the §2 reconciliation section and may be findings.

## Run sequence (user)

Build once:

```bash
cmake -S bench/pilot/10-core-to-core -B bench/pilot/10-core-to-core/build
cmake --build bench/pilot/10-core-to-core/build
```

Ground truth and the GUI-safe gates — **desktop is fine, cores 1–7 are isolated from it**:

```bash
./bench/pilot/10-core-to-core/topology.sh
./bench/pilot/10-core-to-core/run_pilot.sh            # A1, A2, A3
```

A4 only — **must be headless**; this drops the desktop, runs, and brings it back:

```bash
./bench/scripts/headless-capture.sh \
    ./bench/pilot/10-core-to-core/run_pilot.sh --a4
```

If A3's IQR comes out marginal against the intra/cross gap, re-run A3 headless the same way before locking K.

## Acceptance

- **Scope containment:** `git status --porcelain` shows changes only under `bench/pilot/10-core-to-core/` and `bench/scripts/`. `grep -c '10-core-to-core' bench/scripts/run_one.sh` → 0. No `site/` or `docs/` file modified. No file created under `site/src/data/perf/`.
- **Builds:** the two `cmake` lines above succeed.
- **Task 0:** `grep -c assert_headless bench/scripts/lib.sh` → 1; `grep -c assert_headless bench/scripts/run_one.sh` → ≥1; `bench/scripts/headless-capture.sh` exists, is executable, and `grep -c 'lib.sh' bench/scripts/headless-capture.sh` → ≥1 (sources lib.sh rather than reimplementing its checks).
- **Topology:** `./bench/pilot/10-core-to-core/topology.sh` runs and writes `pilot_logs/topology.txt`; CC reports the actual L3 `shared_cpu_list` grouping in the PR notes.
- **Affinity assert:** `grep -n sched_getcpu bench/pilot/10-core-to-core/*.cpp` returns the per-worker readback-and-assert.
- **Alignment:** `grep -c 'alignas(64)' bench/pilot/10-core-to-core/*.cpp` ≥ 1; `static_assert` guards the atomic(s) against co-location with harness bookkeeping.
- **Ordering:** `grep -c memory_order_seq_cst bench/pilot/10-core-to-core/*.cpp` → 0; acquire/release present.
- **Runs (off-rig sanity only):** `--help` lists every CLI flag; `--full-matrix --k 100 --windows 2` prints a labelled matrix without crashing (numbers meaningless off-rig — this proves the harness runs).
- **A4 gate:** `run_pilot.sh --a4` under an active `graphical.target` exits non-zero with the remediation message.
- **A5:** `reconciliation-inventory.md` exists; every figure re-derived from a named JSON field; mismatches flagged, not fixed. CC reports the mismatch list — empty is a valid, informative result.

## Out of scope

- Schema conformance, machine block, chart components, MDX, multi-capture, `run_one.sh` demo wiring — §2+.
- Anything under `site/src/data/perf/`.
- **Deciding** protocol, K, window count, or core-0 include/exclude — the data decides those with Opus/user; the bench produces numbers.
- Fixing prose-vs-JSON mismatches A5 surfaces.
- Correcting `demo-10-plan.md`'s WSL2 language — flagged below, user's call, separate edit.
- Changing `isolcpus=1-7` to the hardened `isolcpus=domain,managed_irq,1-7` form. Better, but it changes machine state relative to demos 1–9; a recorded methodology decision, not a pilot-time change.

## Open items for CC to flag

1. **Measured grouping vs sysfs grouping.** If A1's latency blocks disagree with `topology.sh`'s L3 `shared_cpu_list`, stop and report both. That disagreement is a significant finding, not a bug to paper over.
2. **Affinity assert fires** (`sched_getcpu()` ≠ requested) → STOP, report which core.
3. **TSC not invariant** (`constant_tsc`/`nonstop_tsc` absent) → report; the ns-portability framing depends on it.
4. **`twoflag` starvation** — unfair spinning or a stalled handshake; note whether a fence was needed, since §2 must specify it.
5. **A5 mismatches** — surface any earlier-post cross-CCX claim whose JSON disagrees with its prose. A clean result is equally informative; say so explicitly.
6. **`assert_boost_off` availability** — confirm lib.sh's version degrades safely when invoked by `headless-capture.sh`; the pilot does not require boost-off (invariant TSC), so it must not hard-fail the wrapper on a rig where the signal is absent.

## Plan corrections (user sign-off — not CC work)

`docs/demo-10-plan.md` carries the same false WSL2 premise and should be corrected before §2 is written, or §2 will inherit it:

1. **Lesson 1** — "must be *visible and stable* through WSL2's vCPU→pCPU mapping… The rig itself is under test here" → the rig is not under test; A1 confirms measurability and assigns CCX membership, cross-checked against sysfs L3 sharing.
2. **Story angle** — "they're rig-specific (FCLK-dependent, and virtualised)" → drop "and virtualised"; FCLK dependence stands.
3. **What the post does NOT claim** — "WSL2 sits under everything… absolute values reported under an explicit hypervisor caveat" → delete. Absolute ns are bare-metal. Replace the portable-quantity discipline with FCLK/Matisse-specificity caveats.
4. **§1/A1 task text** — "don't assume core indices 1–3 / 4–7 map to CCX0/CCX1 through the hypervisor" → keep the *let-the-data-decide* discipline, but reframe: predict from sysfs L3 sharing, confirm by measurement. Delete "or reframe as a virtualisation post".
5. **Lessons list** — "A1 tests the rig (WSL2 mapping stability)" → correct as above.
6. **Open items** — delete "**WSL2 framing depth**" entirely.
7. **§6** — "headless boot" is still correct, but the mechanism changed: the benchmark GRUB entry no longer carries the runlevel-`3` argument, so headless is now enforced by `assert_headless` + `headless-capture.sh` rather than by the boot entry. Worth a sentence so the methodology page stays true.

