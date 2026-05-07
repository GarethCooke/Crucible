# Demo 01 — Branch Prediction

**Sorted vs unsorted: a 6× branch-prediction gap.**

## What it measures

Iterates an array of `int32_t` and sums all elements satisfying `x >= 128`. Two variants:

| Variant | Input | Branch predictor | Typical ns/op (N=32M) |
|---|---|---|---|
| `sorted` | Array sorted ascending | Learns the run of falses then trues — near-zero mispredicts | ~1.2 |
| `unsorted` | Array shuffled (seed 42) | ~50% random mispredicts every iteration | ~7.3 |

Both variants execute **identical code**. The difference is purely the input ordering.

## Key results

- ~6× throughput gap at N=32M
- Unsorted: ~0.5 branch misses per element
- Sorted: ~0.001 branch misses per element
- IPC drops from ~3.2 (sorted) to ~0.9 (unsorted) due to pipeline stalls

## Build

```bash
cd bench
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

## Run

```bash
./bench/scripts/run_one.sh 01-branch-prediction
```

Requires the reference machine with `kernel.perf_event_paranoid=1`.
