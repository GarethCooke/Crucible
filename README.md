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

## One-time reference machine setup

These commands configure the Linux reference machine for reproducible benchmarking. Run once after boot, before any benchmark run.

```bash
# Pin CPU governor to performance
sudo cpupower frequency-set -g performance

# Disable Turbo Boost in software (also disable CPB in BIOS)
echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost

# Allow user-mode perf access (no CAP_SYS_ADMIN required)
sudo sysctl kernel.perf_event_paranoid=1

# Verify isolation (should show isolcpus=4-7 in output)
cat /proc/cmdline
```

Add to `/etc/default/grub` (then `update-grub`) for persistent isolation:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7"
```

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

The scripts require the one-time machine setup above and must run on the reference machine. JSON output is committed to the repo alongside the site so deploys are purely static.

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
- Ubuntu Server LTS, dual-boot
- Boot: `isolcpus=4-7 nohz_full=4-7 rcu_nocbs=4-7`
- BIOS: Core Performance Boost disabled

ISA: SSE4.2, AVX, AVX2, FMA. **No AVX-512.** Zen 2 implements 256-bit AVX2 as two 128-bit µops — noted in any SIMD post.

Full spec committed to `bench/machine/` on first benchmark run.

---

## License

MIT — see [LICENSE](LICENSE).
