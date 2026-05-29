# Crucible

High-performance C++ benchmarking microsite. Each post is a focused optimisation problem — naive vs tuned implementations, real hardware measurements, and visualisations of system behaviour.

Deployed at [crucible.garethcooke.com](https://crucible.garethcooke.com). Companion to [garethcooke.com](https://garethcooke.com).

---

## Prerequisites

| Tool             | Version                                 |
| ---------------- | --------------------------------------- |
| Ubuntu Server LTS (or Desktop LTS) | 22.04 or 24.04          |
| GCC              | 13+                                     |
| CMake            | ≥ 3.20                                  |
| Google Benchmark | fetched automatically via CMake FetchContent |
| `perf`           | kernel 5.x+ (`linux-tools-$(uname -r)`) |
| `cpufrequtils`   | any recent                              |
| Node.js          | 20 LTS                                  |
| npm              | 10+                                     |

---

## One-time machine setup

Run once after OS install. Survives reboots.

### Install required tooling

```bash
sudo apt install linux-tools-$(uname -r) linux-tools-generic \
                 cpufrequtils jq build-essential cmake gcc-13
```

### GRUB benchmark entry

Add a second GRUB entry that boots with full core isolation. Edit `/etc/grub.d/40_custom`:

```
menuentry 'Ubuntu (benchmark — cores 0-7 isolated)' {
    search --no-floppy --fs-uuid --set=root <your-root-uuid>
    linux /boot/vmlinuz-<version> root=UUID=<your-root-uuid> ro quiet splash \
          isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7
    initrd /boot/initrd.img-<version>
}
```

Replace `<your-root-uuid>` and kernel `<version>` with the values from your existing default GRUB entry (`grep -A5 'menuentry' /boot/grub/grub.cfg | head -20`). Then regenerate:

```bash
sudo update-grub
```

This entry isolates all 8 cores from the kernel scheduler, RCU, and tick interrupts. Boot into it before every capture run.

### BIOS settings

- **Core Performance Boost: Disabled** — eliminates turbo variance
- **SMT (Simultaneous Multithreading): Disabled** — removes SMT-sibling sharing of L1/L2/execution ports from all measurements
- **XMP: Enabled** at documented memory speed (DDR4-3200 on reference machine)

If BIOS access is unavailable, SMT can be disabled at runtime (reverts on reboot):

```bash
echo off | sudo tee /sys/devices/system/cpu/smt/control
```

### perf access

```bash
# Persist across reboots:
echo "kernel.perf_event_paranoid=1" | sudo tee /etc/sysctl.d/99-perf.conf
sudo sysctl --system
```

If `cache-references` / `cache-misses` events are still inaccessible after setting paranoid=1, grant capabilities per built binary:

```bash
sudo setcap cap_perf_event=ep bench/build/<benchmark-binary>
```

---

## Before each capture run

Perform these steps after every boot into the benchmark GRUB entry, before running any capture script.

```bash
# 1. Pin CPU governor to performance
sudo cpupower frequency-set -g performance

# 2. Verify turbo is off (Core Performance Boost disabled in BIOS)
cpupower frequency-info | grep "Active: no"

# 3. Set turbo env var for this shell session
export CRUCIBLE_TURBO=off
```

The `CRUCIBLE_TURBO` variable is read by the capture harness to record the turbo state in the output JSON. Captures made without it set will record a null turbo field.

Verify SMT and governor have not been reset by a firmware update or GNOME session start:

```bash
cat /sys/devices/system/cpu/smt/active    # should print 0 (SMT off)
cpupower frequency-info | grep "current policy"  # should show performance
```

---

## Build

```bash
cd bench
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

Google Benchmark is fetched automatically via CMake `FetchContent` on first build. No manual install required.

---

## Capture

Run a single demo and emit JSON to `site/src/data/perf/`:

```bash
export CRUCIBLE_TURBO=off
./bench/scripts/run_one.sh 01-branch-prediction
./bench/scripts/run_one.sh 02-false-sharing
./bench/scripts/run_one.sh 03-simd-blackscholes
./bench/scripts/run_one.sh 04-spsc-queue
```

Run all demos:

```bash
export CRUCIBLE_TURBO=off
./bench/scripts/run_all.sh
```

JSON output is committed to the repo alongside the site so deploys are purely static.

---

## Site

```bash
cd site
npm install
npm run dev       # http://localhost:3000
npm run build     # static export → out/
```

---

## Deploy

Connected to AWS Amplify. Push to `main` → Amplify builds and deploys from `amplify.yml`.

Manual deploy: upload `site/out/` to any static host.

---

## Reference machine

- AMD Ryzen 7 3800X — 8 cores, Zen 2 (two 4-core CCXs sharing L3 only via Infinity Fabric), SMT disabled
- 32 GB DDR4-3200 (XMP enabled)
- ASUS ROG STRIX B550-F GAMING (Wi-Fi)
- Ubuntu LTS, dual-boot with Windows
- BIOS: Core Performance Boost disabled, SMT disabled, XMP enabled (DDR4-3200)
- Core isolation: `isolcpus=1-7 nohz_full=1-7 rcu_nocbs=1-7` via dedicated GRUB entry

CCX layout (verified via `lscpu --extended`): cores 0–3 share L3 instance 0 (CCX0); cores 4–7 share L3 instance 1 (CCX1). With SMT disabled the OS exposes 8 logical CPUs (0–7), one per physical core.

ISA: SSE4.2, AVX, AVX2, FMA. **No AVX-512.** Zen 2 implements 256-bit AVX2 as two 128-bit µops — noted in any SIMD post.

Full machine spec committed to `bench/machine/` on first benchmark run.

---

## License

MIT — see [LICENSE](LICENSE).
