# Crucible

High-performance C++ benchmarking microsite. Each post is a focused optimisation problem — naive vs tuned implementations, real hardware measurements, and visualisations of system behaviour.

Deployed at [crucible.garethcooke.com](https://crucible.garethcooke.com). Companion to [garethcooke.com](https://garethcooke.com).

---

## Prerequisites

| Tool | Version |
|---|---|
| GCC | 13+ |
| CMake | ≥ 3.20 |
| `perf` | kernel 5.x+ (`linux-tools-$(uname -r)`) |
| `jq` | any recent |
| Node.js | 20 LTS |
| npm | 10+ |

---

## Installing Ubuntu (reference machine)

Either edition of the current Ubuntu LTS works. Pick based on whether you want a GUI on the box.

### Path A — Ubuntu Desktop (used on the reference machine)

Install Ubuntu Desktop LTS from the standard ISO. GNOME, browser, and applications are pre-installed for general use; benchmark discipline is applied at run time (see [Pre-benchmark runtime discipline](#pre-benchmark-runtime-discipline) below).

### Path B — Ubuntu Server (lean baseline)

Install Ubuntu Server LTS. Optionally add a GUI later:

```bash
# Full GNOME with Ubuntu's standard application bundle
sudo apt install ubuntu-desktop

# Or leaner: GNOME without LibreOffice/Thunderbird/etc.
sudo apt install ubuntu-desktop-minimal
```

Either path produces a system capable of running benchmarks credibly. The runtime discipline matters more than the install path — once GNOME is running on either, the same pre-benchmark steps apply.

---

## Persistent setup (one-time)

Run once after Ubuntu install. Identical for both editions. Survives reboot.

### Install required tooling

```bash
sudo apt install linux-tools-$(uname -r) linux-tools-generic \
                 cpufrequtils cpuset jq build-essential cmake
```

The `cpuset` package provides `cset`, used for per-benchmark core shielding.

### Core isolation strategy

Core isolation is applied at runtime via `cpuset` shielding (`cset shield`), invoked per-benchmark by the wrapper scripts in `bench/scripts/`. No `isolcpus=`, `nohz_full=`, or `rcu_nocbs=` boot parameters are committed.

This trades a small amount of strictness — kernel threads and IRQ handlers may briefly touch shielded cores until IRQ affinity is steered — for the flexibility to shield different core sets per demo (intra-CCX vs cross-CCX, for example) without rebooting.

Future demos with hard tail-latency claims (sub-microsecond p99.9) may introduce `nohz_full=` at that point, documented in that demo's methodology notes.

### Persistent perf access

```bash
echo "kernel.perf_event_paranoid=1" | sudo tee /etc/sysctl.d/99-perf.conf
sudo sysctl --system
```

### BIOS settings

- **Core Performance Boost: Disabled** — eliminates turbo variance
- **SMT (Simultaneous Multithreading): Disabled** — removes SMT-sibling sharing of L1/L2/execution-port resources from all measurements. Runtime fallback if BIOS access is unavailable: `echo off | sudo tee /sys/devices/system/cpu/smt/control` (reverts on reboot, must be re-applied per boot).
- **XMP: Enabled** at documented memory speed (DDR4-3200)

---

## Per-boot setup

Run after every reboot, before any benchmark run. (Optionally wrap in a systemd `oneshot` unit at `multi-user.target` to automate.)

```bash
# Pin CPU governor to performance
sudo cpupower frequency-set -g performance

# Disable Turbo in software (belt-and-braces with BIOS CPB off)
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost

# If SMT was not disabled in BIOS, disable at runtime (reverts on reboot)
# echo off | sudo tee /sys/devices/system/cpu/smt/control

# Verify
cpupower frequency-info | grep "current policy"             # should be performance
cat /sys/devices/system/cpu/cpufreq/boost                    # should print 0
cat /sys/devices/system/cpu/smt/active                       # should print 0 (SMT off)
lscpu | grep "^CPU(s):"                                      # should report 8
sudo dmidecode -t memory | grep -i "configured.*speed"       # should report 3200 MT/s (XMP active)
```

The verifications matter because GNOME (Desktop edition) can override the CPU governor at session start, and firmware updates or CMOS resets can revert BIOS settings — re-enabling SMT, or dropping memory back to JEDEC default (typically 2666 or 2933 MT/s on this CPU). If any check fails after a reboot where the configured state is expected, BIOS has likely been reverted; re-check.

---

## Pre-benchmark runtime discipline

### Server edition

Nothing extra needed — no GUI session, no compositor, no indexer. Run benchmarks directly. The per-benchmark wrapper handles `cset shield` setup, IRQ affinity steering, and teardown — manual `cset` invocation isn't required at this layer.

### Desktop edition

GNOME, the compositor, and desktop services introduce variance. Before benchmark runs:

```bash
# Option 1: drop to a TTY (lightest)
# Ctrl+Alt+F3 → log in → run benchmarks
# Ctrl+Alt+F1 (or F2) to return to GNOME afterwards

# Option 2: kill the graphical session entirely
sudo systemctl isolate multi-user.target
# ...run benchmarks...
sudo systemctl isolate graphical.target

# Always: stop indexing and updates during runs
tracker3 daemon --terminate
sudo systemctl stop unattended-upgrades.service
```

Before dropping to TTY (Option 1), fully quit browsers, chat clients, sync agents, and similar — closing windows isn't enough, their background processes keep running in the GNOME session. Option 2 tears all of that down for you, so you can skip this step.

The per-benchmark wrapper handles `cset shield` setup, IRQ affinity steering, and teardown. The methodology page documents this discipline so readers know the numbers come from a quiescent system.

**Verify the governor and SMT survived GNOME login.** GNOME Power settings can override `cpupower`; SMT state can be reset by firmware updates. After logging into GNOME and dropping back to TTY:

```bash
cpupower frequency-info | grep "current policy"     # should still be performance
cat /sys/devices/system/cpu/smt/active              # should still be 0
```

If either has been stomped, re-apply via the per-boot commands; consider a systemd unit that re-applies them on graphical-session start.

---

## Building benchmarks

```bash
cd bench
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

Google Benchmark is fetched automatically via CMake `FetchContent` on first build.

---

## Running benchmarks

Run a single demo and emit JSON to `site/src/data/perf/`:

```bash
./bench/scripts/run_one.sh 01-branch-prediction
```

Run all demos:

```bash
./bench/scripts/run_all.sh
```

Both scripts require per-boot setup applied and (on Desktop edition) the runtime discipline above. The wrappers handle `cset shield` setup, IRQ affinity steering (`/proc/irq/*/smp_affinity`), `perf stat` capture, and JSON emission; the shielded core set used per run is recorded in `machine.isolated_cores` of the demo's JSON. JSON output is committed to the repo alongside the site so deploys are purely static.

---

## Developing the site

```bash
cd site
npm install
npm run dev       # http://localhost:3000
npm run build     # static export → out/
```

---

## Deploying

Connected to AWS Amplify. Push to `main` → Amplify builds and deploys from `amplify.yml`.

Manual deploy: upload `site/out/` to any static host.

---

## Reference machine

- AMD Ryzen 7 3800X — 8 cores / 16 threads, Zen 2 (two 4-core CCXs sharing L3 only via Infinity Fabric)
- 32 GB DDR4-3200
- ASUS ROG STRIX B550-F GAMING (Wi-Fi)
- Ubuntu LTS Desktop edition, dual-boot with Windows
- BIOS: Core Performance Boost disabled, SMT disabled, XMP enabled (DDR4-3200)
- Core isolation: `cset shield` per-benchmark; specific shielded core set recorded per run

CCX layout (verified via `lscpu --extended`): cores 0–3 share L3 instance 0 (CCX0); cores 4–7 share L3 instance 1 (CCX1). With SMT disabled the OS exposes 8 logical CPUs (0–7), one per physical core.

ISA: SSE4.2, AVX, AVX2, FMA. **No AVX-512.** Zen 2 implements 256-bit AVX2 as two 128-bit µops — noted in any SIMD post.

Full spec committed to `bench/machine/` on first benchmark run.

---

## License

MIT — see [LICENSE](LICENSE).
