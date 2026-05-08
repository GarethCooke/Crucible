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
                 cpufrequtils jq build-essential cmake
```

### Kernel boot parameters (core isolation)

Edit `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7"
```

Then:

```bash
sudo update-grub
sudo reboot
# Verify after reboot:
cat /proc/cmdline   # should show isolcpus=4-7
```

### Persistent perf access

```bash
echo "kernel.perf_event_paranoid=1" | sudo tee /etc/sysctl.d/99-perf.conf
sudo sysctl --system
```

### BIOS settings

- **Core Performance Boost: Disabled** — eliminates turbo variance
- **SMT: Disabled** — or leave on and pin only to physical cores 0–3
- **XMP: Enabled** at documented memory speed (DDR4-3200)

---

## Per-boot setup

Run after every reboot, before any benchmark run. (Optionally wrap in a systemd `oneshot` unit at `multi-user.target` to automate.)

```bash
# Pin CPU governor to performance
sudo cpupower frequency-set -g performance

# Disable Turbo in software (belt-and-braces with BIOS CPB off)
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost

# Verify
cpupower frequency-info | grep "current policy"
cat /sys/devices/system/cpu/cpufreq/boost   # should print 0
```

---

## Pre-benchmark runtime discipline

### Server edition

Nothing extra needed — no GUI session, no compositor, no indexer. Run benchmarks directly.

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
The methodology page documents this discipline so readers know the numbers come from a quiescent system.

**Verify the governor survived GNOME login.** GNOME Power settings can override `cpupower`. After logging into GNOME and dropping back to TTY:

```bash
cpupower frequency-info | grep "current policy"   # should still be performance
```

If it's been stomped, add a systemd unit that re-applies `performance` on graphical-session start.

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

Both scripts require per-boot setup applied and (on Desktop edition) the runtime discipline above. JSON output is committed to the repo alongside the site so deploys are purely static.

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

- AMD Ryzen 7 3800X — 8 cores / 16 threads, Zen 2
- 32 GB DDR4-3200
- ASUS ROG STRIX B550-F GAMING (Wi-Fi)
- Ubuntu LTS Desktop edition, dual-boot with Windows
- Boot: `isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7`
- BIOS: Core Performance Boost disabled, SMT disabled

ISA: SSE4.2, AVX, AVX2, FMA. **No AVX-512.** Zen 2 implements 256-bit AVX2 as two 128-bit µops — noted in any SIMD post.

Full spec committed to `bench/machine/` on first benchmark run.

---

## License

MIT — see [LICENSE](LICENSE).