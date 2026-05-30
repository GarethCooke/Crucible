# Crucible — Raspberry Pi 5 bench-rig setup (isolation + preflight scripts)

Implementation brief for Claude Code. Lands two new scripts under `bench/scripts/` plus a README section. Self-contained. This is **rig infrastructure** — the prerequisite that unblocks the demo 9 (ARM NEON cross-arch) calibration pilot. It commits to no benchmark numbers, variants, chart shapes, or prose; all of that waits for the pilot and a subsequent implementation brief.

## Context

A second reference machine joins the project for the cross-arch demo: a **Raspberry Pi 5** (Broadcom BCM2712, 4× Arm Cortex-A76, AArch64), running **Raspberry Pi OS Lite (64-bit, Bookworm)**, headless, with an active cooler fitted. It is a separate boot card from the user's Home Assistant install.

The existing capture rig is x86 (Zen 2). Its scripts live in `bench/scripts/` (`run_one.sh`, `run_all.sh`, `lib.sh`). Those assume an x86 box: `lib.sh` carries an `assert_smt_off()` and other x86-specific guards. The Cortex-A76 has **no SMT**, no BIOS, and a different cpufreq driver. The Pi rig therefore gets its **own** scripts; the x86 path is not touched.

- `BRIEF.md` — the x86 rig isolates cores via `isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7` (boot params) and pins with `taskset`; methodology commitments are governor=performance, turbo off (verified), core isolation, statistical reporting. The Pi rig mirrors the *intent* of these, with Pi-appropriate mechanisms.
- `crucible-handover.md` — the ARM NEON post is the "constrained-hardware differentiation" candidate. Captures are "headless, single isolated core."
- The x86 rig's turbo-off guard has an analogue on the Pi: **thermal/voltage throttling**. `vcgencmd get_throttled` reading `0x0` is the Pi's "turbo off, verified" — a nonzero reading invalidates a capture exactly as an enabled boost would on the Zen 2 box.

## Preconditions (user, on the Pi — not CC)

These are **boot-time** kernel parameters and cannot be applied post-boot. The user applies them once and reboots before `pi-preflight.sh` can pass. They are listed here so CC's preflight checks know what "correct" looks like; CC does **not** edit any boot file.

- `/boot/firmware/cmdline.txt` (single line, space-separated, no newline added) has appended:
  `isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3`
- After reboot, `cat /sys/devices/system/cpu/isolated` reads `2-3`.

Cores 0–1 are left for the OS and IRQ housekeeping; cores 2–3 are isolated; the benchmark pins to core 3 (core 2 is a quiet buffer). Avoiding cpu0 sidesteps the "boot CPU cannot be isolated" behaviour seen on the x86 rig.

## Tasks

### 1. Create `bench/scripts/pi-rig-setup.sh` (apply runtime state)

A root, idempotent script that puts the running system into capture-ready state. Re-runnable any number of times with the same result. First action: **guard** — if `uname -m` is not `aarch64` or `/proc/device-tree/model` does not contain `Raspberry Pi 5`, print a clear message and exit nonzero. This script must never run against the x86 rig.

Then, in order:

- **Governor → performance.** Write `performance` to `/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor` for all present CPUs. (Pi OS default is `ondemand`.)
- **Pin the clock.** Read `cpuinfo_max_freq`, then write that value to both `scaling_min_freq` and `scaling_max_freq` for every CPU, locking the frequency (belt-and-braces with the performance governor). Record the pinned value to stdout in MHz.
- **Disable irqbalance**, then pin IRQ affinity off the isolated cores. `systemctl stop irqbalance` and `systemctl disable irqbalance` (tolerate "unit not found"). For each `/proc/irq/<n>/smp_affinity_list`, attempt to set it to `0-1`. Per-CPU and unmovable IRQs will reject the write with EIO — skip those silently and continue; emit a one-line summary of how many were re-pinned vs skipped.
- **Quiet jitter services.** `systemctl stop` (and `disable`) on any present of: `avahi-daemon`, `triggerhappy`, `ModemManager`, `bluetooth`. Tolerate absent units. Do **not** touch networking (`ssh`, ethernet) — the user needs the box reachable.
- **Swap off.** `dphys-swapfile swapoff` if present; `swapoff -a` as a fallback. Avoids swap-induced jitter.
- **perf access.** `sysctl -w kernel.perf_event_paranoid=1` (matches the x86 rig's documented one-time setup).

Each step prints a single `[ok]` / `[skip]` line. The script exits 0 only if the mandatory steps (governor, clock pin, perf_event_paranoid) succeeded; service/swap/IRQ steps are best-effort and never fail the run on their own, but log their outcome.

### 2. Create `bench/scripts/pi-preflight.sh` (verify or abort)

A read-only guard that asserts the rig is capture-ready and **exits nonzero with a specific message** on the first failure. This is the Pi analogue of the x86 abort guard. Same `aarch64` + `Raspberry Pi 5` guard as Task 1 first. Then assert:

- **Isolation took.** `/sys/devices/system/cpu/isolated` equals `2-3`. (Fail → "core isolation not active; apply cmdline.txt boot params and reboot — see README.")
- **Governor.** Every isolated core (2, 3) reports `performance`. (Fail → name the offending core; suggest running `pi-rig-setup.sh`.)
- **Clock pinned.** On cores 2 and 3, `scaling_min_freq == scaling_max_freq`. (Fail → report the two values.)
- **No throttling.** `vcgencmd get_throttled` returns `0x0`. (Fail → decode and report which bits are set; advise checking cooling / PSU.)
- **perf usable.** `kernel.perf_event_paranoid` ≤ 1, and a trivial `perf stat -e cycles true` exits 0. (Fail → report which.)
- **Isolated cores idle.** No non-kernel task is currently pinned to core 2 or 3 (e.g. parse `taskset`-readable affinity of running PIDs, or sample `/proc/stat` per-cpu utilisation and warn if cores 2–3 show sustained non-idle). A warning is acceptable here rather than a hard fail — flag in the summary.

On all-pass: print a one-line green summary including the pinned clock and the `get_throttled` value, exit 0.

### 3. README — Pi rig section

Add a "Raspberry Pi 5 bench rig" subsection to `README.md`, mirroring the existing x86 one-time-setup block. It documents, in order: the one-time boot edit (`/boot/firmware/cmdline.txt` append of `isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3`; note the alternate path `/boot/cmdline.txt` on pre-Bookworm images), the reboot + `cat /sys/devices/system/cpu/isolated` verification, and the per-session flow: `sudo ./bench/scripts/pi-rig-setup.sh` then `./bench/scripts/pi-preflight.sh`. State plainly that isolation is boot-time and the rest is the script.

## Acceptance

### Scripts
- `bench/scripts/pi-rig-setup.sh` and `bench/scripts/pi-preflight.sh` exist and are executable (`chmod +x`).
- `bash -n` parses both with no syntax errors; `shellcheck` reports no errors (warnings noted in the PR if any are intentional).
- Both scripts exit nonzero with a clear message when `uname -m` ≠ `aarch64` (verifiable on the x86 dev box: run them, confirm the guard fires and nothing is mutated).
- `pi-rig-setup.sh` is idempotent: running it twice produces identical end state and no errors.

### Isolation / non-interference with the x86 path
- `git diff` shows **no** changes to `run_one.sh`, `run_all.sh`, or `lib.sh`.
- `grep -rn 'assert_smt_off\|cset shield' bench/scripts/pi-*.sh` returns zero matches (the Pi scripts use neither).

### README
- README contains the `isolcpus=2,3 nohz_full=2,3 rcu_nocbs=2,3` line and the `/sys/devices/system/cpu/isolated` verification command.

## Out of scope

- **The cmdline.txt boot edit** — user precondition on the Pi; CC must not edit any file under `/boot`.
- **Demo 9 bench code, JSON, charts, or prose.** The Black-Scholes ARM port, `-mcpu=cortex-a76` flags, variant list, N-sweep, and chart work all wait for the calibration pilot and a separate implementation brief. Nothing in `bench/demos/` is created or touched here.
- **`machine_info.h` / machine-block capture for the Pi.** The schema fields a Pi capture needs (and whether the A76 PMU populates them) is a pilot question, then a demo-brief task. Not here.
- **Wiring `pi-preflight.sh` into a capture orchestrator.** Deferred to the demo 9 implementation brief, when an ARM build target exists. Do not fork `run_one.sh`.
- **`force_turbo` / overclock / any other config.txt tuning.** Do not touch — `force_turbo` sets a permanent bit and interacts with frequency settings. The performance governor + clock pin is sufficient.
- **Methodology page changes.** The Pi rig gets documented there when demo 9 ships, not now.

## Open items for CC to flag

1. **cgroup v2 vs `cset`.** If you reach for `cset shield` (the x86 rig's isolation tool) — don't. Pi OS Bookworm defaults to cgroup v2; the `cset`/`cpuset` Python tool targets v1 and will misbehave. Isolation here is `isolcpus` (boot) + `taskset` pinning (at capture time) + IRQ affinity (this script). If something pushes you toward `cset`, stop and flag rather than working around it.

2. **`get_throttled` "since boot" bits.** `vcgencmd get_throttled` encodes both *currently active* (low bits) and *occurred since boot* (high bits, `0x_0000`) conditions. Decide whether the preflight requires an exact `0x0` (strict — fails if a throttle ever happened this session) or masks the high bits to check only current state. Default to **strict `0x0`** and surface the choice in the PR; a clean cooled rig should read `0x0`, and an "occurred earlier" reading is itself worth knowing before a capture.

3. **Boot-config path.** Bookworm uses `/boot/firmware/cmdline.txt`; older images use `/boot/cmdline.txt`. The README should name both. The preflight reads `/sys/devices/system/cpu/isolated` (path-independent), so the scripts don't depend on this — but if you cannot confirm which the user's image uses, say so in the README rather than guessing one.

4. **`vcgencmd` availability.** It ships in `libraspberrypi-bin` / `raspi-utils` and is normally on PATH on Pi OS. If `command -v vcgencmd` fails, the preflight should report it as a setup error (name the package) rather than silently skipping the throttle check — the throttle check is the rig's turbo-off guarantee and must not be quietly dropped.

5. **A76 PMU counters.** If, while writing the trivial `perf stat -e cycles true` check, you find a counter the project schema relies on is reported "not supported" on this kernel, **note it but do not block** — confirming the full counter set (branch-misses, cache-misses, IPC) is a calibration-pilot question, not this brief's responsibility. Just flag what you observed.
