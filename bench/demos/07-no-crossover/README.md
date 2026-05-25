# Demo 07 — No Crossover: use `absl::flat_hash_map`

Benchmarks five map implementations across two workloads to establish that there
is no N or modify-mix ratio where sorted containers or `std::unordered_map` beat
`absl::flat_hash_map`. Data feeds the post at `site/src/posts/07-no-crossover.mdx`.

**Prior art:** `bench/pilots/07-flatmap-vs-hashmap-stage1/` (lookup-only sweep)
and `bench/pilots/07-flatmap-vs-hashmap-stage2/` (modify-mix sweep) — throwaway
pilots; the formal harness here must reproduce their results to within 1σ of
pilot run-to-run noise on the reference machine.

## Variants

| id          | implementation                                          |
|-------------|---------------------------------------------------------|
| `std_map`   | `std::map<uint64_t, uint64_t>`                          |
| `sorted_vec`| `std::vector<pair<…>>` + `std::lower_bound`             |
| `boost_flat`| `boost::container::flat_map<uint64_t, uint64_t>`        |
| `std_unord` | `std::unordered_map<uint64_t, uint64_t, absl::Hash<…>>` |
| `absl_flat` | `absl::flat_hash_map<uint64_t, uint64_t>`               |

## Workloads

**Workload A — lookup-only** (chart 1): pre-populate with N random keys; time
`find()` on a 4096-entry cyclic index. N sweep:
`{8, 16, 32, 64, 128, 256, 512, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304}`.

**Workload B — modify-mix** (chart 3): steady-state fixed-size map; each op is
either `find()` or `erase()+insert()`. `modify_pct` ∈ {0,10,25,50,75,90} at
N ∈ {256, 4096, 65536}. Note: pilot called this `insert_pct`; formal harness
uses `modify_pct` (the more accurate name).

## Key generation

- Populated keys: `std::mt19937_64(seed=42)`, rejection on `unordered_set`.
- Op/lookup sequence: `std::mt19937_64(seed=1337)`.
- Seeds are fixed for cross-variant reproducibility.

## Building

```bash
cmake -B bench/build -S bench -DCMAKE_BUILD_TYPE=Release
cmake --build bench/build --target bench_07_no_crossover
```

## Running a single cell (manual)

```bash
./bench/build/demos/07-no-crossover/bench_07_no_crossover \
    absl_flat lookup --n 4096 --reps 5
```

## Calibration

```bash
./bench/demos/07-no-crossover/calibrate.sh
```

Runs a fast reduced sweep and compares against pilot bounds. Exit code 0 = in
bounds. Must pass before running the headline capture.

## Full sweep

```bash
sudo cset shield --reset
CRUCIBLE_TURBO=off ./bench/scripts/run_one.sh 07-no-crossover
```

Output: `site/src/data/perf/07-no-crossover.json`
