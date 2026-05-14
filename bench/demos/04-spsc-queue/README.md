# Demo 04 — Lock-free SPSC vs mutex queue

End-to-end enqueue→dequeue latency across three variants of a single-producer
single-consumer queue. The headline metric is the tail (p99.9), not throughput.

## Variants

| Variant | Description |
|---|---|
| `lockfree-handrolled` | ~50-line ring buffer in `spsc_queue.h`. `acquire`/`release` atomics, 64-byte-padded head/tail. |
| `lockfree-boost` | `boost::lockfree::spsc_queue<MarketTick, capacity<1024>>`. Sanity check on the hand-rolled implementation. |
| `mutex-condvar` | `std::queue` + `std::mutex` + `std::condition_variable`. Standard deployed pattern. |

## Hardware target

AMD Ryzen 7 3800X (Zen 2). Producer pinned to **core 4**, consumer to **core 5** — both
on CCX1 (same L3 slice). Cross-CCX measurement is deferred.

## TSC / rdtscp status

`rdtscp` requires `constant_tsc` and `nonstop_tsc` in `/proc/cpuinfo`. The benchmark
binary verifies both at startup and aborts with a diagnostic if either is absent.

On the 3800X reference machine with the 6.8 kernel, both flags are present:

```
$ grep -o 'constant_tsc\|nonstop_tsc' /proc/cpuinfo | sort -u
constant_tsc
nonstop_tsc
```

TSC frequency drift across the 5 runs is checked by performing a second calibration
after all measurement phases complete. If the implied drift exceeds 0.1%, it is
logged to stderr and included in the output JSON as `calibration_drift_pct`.

## Installing Boost (header-only)

The `lockfree-boost` variant requires Boost ≥ 1.74 headers. Only the header-only
`lockfree` component is used — no compiled Boost libraries are needed.

### Ubuntu / Debian

```bash
sudo apt-get install libboost-dev   # installs headers to /usr/include/boost
```

### From source (if distro version is too old)

```bash
wget https://boostorg.jfrog.io/artifactory/main/release/1.85.0/source/boost_1_85_0.tar.gz
tar xf boost_1_85_0.tar.gz
sudo cp -r boost_1_85_0/boost /usr/local/include/
```

CMake finds Boost automatically via `find_package(Boost 1.74 REQUIRED)`.

## Building

```bash
cd bench
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target bench_04_spsc_queue
```

## Running

```bash
# All three variants (reference machine, requires cset + sudo):
# Also runs stress test (10M items) before benchmarking.
./scripts/run_one.sh 04-spsc-queue

# Stress test only (zero-loss, FIFO-order verification, 10M items each):
./build/demos/04-spsc-queue/bench_04_spsc_queue --stress-test
./build/demos/04-spsc-queue/bench_04_spsc_queue --stress-test lockfree-handrolled

# Single variant benchmark (for debugging, no cset required):
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-handrolled
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-boost
./build/demos/04-spsc-queue/bench_04_spsc_queue mutex-condvar
```

Output is JSON to stdout. `run_one.sh` collects all three and writes the merged
site data file to `site/src/data/perf/04-spsc-queue.json`.

## Methodology notes

- **Timestamp source**: `rdtscp` with serialising `lfence`. Converted to ns via
  TSC calibration against `CLOCK_MONOTONIC_RAW` over a 100 ms window.
- **Latency definition**: cycle count captured immediately before `try_push` /
  immediately after `try_pop` returns true (or equivalent for condvar variant).
- **Histogram**: 384 log-spaced buckets, 16 sub-buckets per doubling.
  Binning is post-run; the hot loop writes only raw cycle counts.
- **Warmup**: 100,000 items per run before measurement starts.
- **Runs**: 5 per variant; histograms merged element-wise into a 5M-sample total.
- **Thread affinity**: verified via `sched_getcpu()` at thread startup; binary
  aborts on mismatch.
- **Top-bucket guard**: samples reaching bucket 383 (≥ ~128 ms) are counted
  and logged; they represent kernel preemptions or page faults, not queue latency.
