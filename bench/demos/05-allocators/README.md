# Demo 05 — Allocators: cross-thread Order pipeline

Benchmarks three allocator strategies for a cross-thread Order pipeline where the producer thread constructs 64 B Orders and the consumer thread frees them after a simulated risk check. The benchmark reuses the SPSC queue primitive from Demo 04.

## Variants

| Variant | Allocate | Deallocate | Story |
|---|---|---|---|
| `cross-thread-malloc` | `new Order` | `delete` | glibc per-arena; baseline |
| `freelist-return-queue` | local freelist pop | push to return SPSC (C→P) | thread-local magazine pattern |
| `arena-batch-handoff` | bump pointer in rotating arena | increment consumer_pos | arena recycles when fully drained |

## Build

```bash
cd bench
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build --target bench_05_allocators
```

## Running

```bash
# Paced headline (1 MHz offered load, 1 M/s background pressure, 5 × 1M items)
./build/demos/05-allocators/bench_05_allocators cross-thread-malloc --mode paced
./build/demos/05-allocators/bench_05_allocators freelist-return-queue --mode paced
./build/demos/05-allocators/bench_05_allocators arena-batch-handoff --mode paced

# Pressure sweep (9 points: baseline + 8 log-spaced 100k→10M, 1 × 1M items each)
./build/demos/05-allocators/bench_05_allocators cross-thread-malloc --mode pressure_sweep
./build/demos/05-allocators/bench_05_allocators freelist-return-queue --mode pressure_sweep
./build/demos/05-allocators/bench_05_allocators arena-batch-handoff --mode pressure_sweep

# Cross-CCX side experiment (consumer on core 1 instead of core 5)
./build/demos/05-allocators/bench_05_allocators cross-thread-malloc --mode paced --consumer-core 1
./build/demos/05-allocators/bench_05_allocators freelist-return-queue --mode paced --consumer-core 1
./build/demos/05-allocators/bench_05_allocators arena-batch-handoff --mode paced --consumer-core 1

# Machine info
./build/demos/05-allocators/bench_05_allocators --machine-info

# Warmup verification (run once; inspect stderr)
./build/demos/05-allocators/bench_05_allocators cross-thread-malloc --verify-warmup
```

Full capture (all variants, both modes, cross-CCX side experiment) via the orchestrator:

```bash
./bench/scripts/run_one.sh 05-allocators
```

Output: `site/src/data/perf/05-allocators.json` (primary), `site/src/data/perf/05-allocators-cross-ccx.json` (side note).

## Hardware configuration

| Thread | Core | Notes |
|---|---|---|
| Producer (T_p) | 4 | CCX1 on Zen 2 3800X |
| Consumer (T_c) | 5 | CCX1 — same L3 slice as producer |
| Background pressure (T_bg) | 6 | CCX1 — shares L3 with P/C (realistic NUMA peer) |
| Consumer (cross-CCX) | 1 | CCX0 — for side experiment only |

SMT must be off. Cores 4–7 must be isolated (`isolcpus=4-7`). `cset shield` wraps the run.

## RNG seeds

All RNGs use fixed seeds for reproducibility:
- Producer order generator: seed `12345 + iteration_index` (one per iteration to prevent correlation)
- Background pressure T_bg: seed `42`

## Calibration targets

| Parameter | Target | How to adjust |
|---|---|---|
| Consumer work (simulated risk check) | 150–300 ns wall-clock | Expand: add fourth lookup (open-orders-per-symbol). Reduce: drop velocity check |
| Background pressure separation | ≥ 2× malloc p99.9 vs arena at 1 M/s | Raise to 3 M/s if separation too small |
| Freelist drain batch | 32 (default) | Sweep 8/32/128 if drain-induced spikes appear in producer latency |

`consumer_work_target_ns` in the JSON output records the calibrated value.

## Acceptance checks

- `static_assert(sizeof(Order) == 64)` and `alignof(Order) == 64` — enforced at compile time.
- All `std::atomic` ops in hot paths use `acquire`/`release` (no `seq_cst`).
- Arena producer should report `arena_wait_count == 0` (or near-zero) under correct sizing; any non-zero count is logged to stderr.
- `latency_ns.stats.max >= latency_ns.stats.p99_9` — enforced by the histogram's `stats_json()` clamp.
- Pressure sweep emits exactly 9 points (1 zero-baseline + 8 log-spaced).

## Warmup verification

Run once with `--verify-warmup`. Compare early (items 0–9,999) vs late (items 100,000+) histograms on stderr. Expected: late p50 ≤ early p50 (JIT caches warmed, branch predictors settled). Lock in once confirmed; result recorded here:

> _To be filled after first capture on reference machine._
