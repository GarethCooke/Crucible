# Demo 04 — Lock-free SPSC vs mutex queue

End-to-end enqueue→dequeue latency across three variants of a single-producer
single-consumer queue. The headline metric is the tail (p99.9), not throughput.

## Variants

| Variant | Description |
|---|---|
| `lockfree-handrolled` | ~50-line ring buffer in `spsc_queue.h`. `acquire`/`release` atomics, 64-byte-padded head/tail. |
| `lockfree-boost` | `boost::lockfree::spsc_queue<MarketTick, capacity<1024>>`. Sanity check on the hand-rolled implementation. |
| `mutex-condvar` | `std::queue` (bounded, 1024 entries) + `std::mutex` + two `std::condition_variable`s (`cv_not_empty`, `cv_not_full`). Back-pressure matches the lock-free ring buffer. |

All three variants use a 1024-slot bounded queue.

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
# Full pipeline (reference machine, requires cset + sudo):
# Stress test → paced → saturated → sweep per variant → merged JSON
./scripts/run_one.sh 04-spsc-queue

# Stress test only (zero-loss, FIFO-order verification, 10M items each):
./build/demos/04-spsc-queue/bench_04_spsc_queue --stress-test
./build/demos/04-spsc-queue/bench_04_spsc_queue --stress-test lockfree-handrolled

# Single variant, default paced mode at 1 MHz:
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-handrolled
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-boost
./build/demos/04-spsc-queue/bench_04_spsc_queue mutex-condvar

# Explicit mode and rate:
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-handrolled --mode paced --rate-hz 1000000
./build/demos/04-spsc-queue/bench_04_spsc_queue mutex-condvar --mode saturated
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-handrolled \
    --mode sweep --rate-from 100000 --rate-to 25000000 --steps 8
```

Output is a JSON array to stdout (single-element for paced/saturated, multi-element
for sweep). `run_one.sh` collects all modes for all three variants and writes the
merged site data file to `site/src/data/perf/04-spsc-queue.json`.

## Measurement modes

| Mode | `--rate-hz` | Queue depth | Purpose |
|---|---|---|---|
| `paced` | 1,000,000 (default) | < 10 items | Headline tail-latency comparison |
| `saturated` | N/A | Varies | Peak throughput numbers |
| `sweep` | 100k → 25M in 8 steps | Varies | Latency-vs-offered-load chart |

## Warmup verification

The benchmark drains 100,000 warmup items before starting measurement, with the
producer waiting for the consumer to confirm drainage via a `warmup_consumed` atomic.
To verify the warmup is effective, run:

```bash
./build/demos/04-spsc-queue/bench_04_spsc_queue lockfree-handrolled \
    --mode paced --rate-hz 1000000 --verify-warmup 2>&1 | grep -A4 'Warmup verification'
```

Reference output from the 3800X (regenerate after any harness change):

```
=== Warmup verification ===
Items 0-9,999   (early): p50=<value> ns  p99=<value> ns
Items 100,000+  (late):  p50=<value> ns  p99=<value> ns
```

Early and late p50/p99 should be within ~10% of each other. A material divergence
indicates the warmup is not fully draining caches or microarchitectural state before
measurement begins.

## Methodology notes

- **Timestamp source**: `rdtscp` with serialising `lfence`. Converted to ns via
  TSC calibration against `CLOCK_MONOTONIC_RAW` over a 100 ms window.
- **Latency definition**: cycle count captured immediately before `try_push` /
  locked `q.push()` → immediately after `try_pop` returns true or mutex lock
  released (for condvar variant). Both timestamps are outside the synchronisation
  primitive.
- **Histogram**: 384 log-spaced buckets, 16 sub-buckets per doubling.
  Percentiles reported as bucket midpoints; the `percentile_convention` field in
  the JSON documents this. `max` in stats is guaranteed ≥ any reported percentile.
  Binning is post-run; the hot loop writes only raw cycle counts.
- **Warmup**: 100,000 items per run. Producer waits for `warmup_consumed == 100,000`
  before starting the measurement phase — symmetric across all three variants.
- **Runs**: 5 per variant per invocation; histograms merged element-wise into a
  5M-sample total.
- **Thread affinity**: verified via `sched_getcpu()` at thread startup; binary
  aborts on mismatch.
- **Top-bucket guard**: samples reaching bucket 383 (≥ ~128 ms) are counted
  and logged; they represent kernel preemptions or page faults, not queue latency.
- **Pacing**: `_mm_pause` busy-wait against `rdtscp` until the next scheduled
  release time. At 1 MHz inter-arrival = 1 µs. If pacing jitter is material,
  the `--verify-warmup` histograms will show it as elevated early-item variance.
