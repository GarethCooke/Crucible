# quantum-classical-baseline

Classical linear scan baseline for the Quantum special edition post.

Measures the wall-clock cost of finding a marked item by linear scan in an
unstructured array of size N = 2^n, for n ∈ {3, 4, 5} — the same search-space
sizes used in the quantum experiment.

## What this measures

`O(N)` linear search: iterate through an unsorted array until the marked element
is found. This is the algorithm Grover's search theoretically beats by the
quadratic `O(√N)` factor. This bench produces the classical side of that
comparison as a real timing number on the reference machine.

The target element is fixed at the midpoint of the shuffled array (N/2 elements
scanned on average), giving a stable expected scan depth rather than a
best-case or worst-case figure.

## Important caveats

**Do not publish Windows/MinGW-built figures.** The authoritative capture must
be run on the Ubuntu reference rig with the standard isolation setup (isolated
cores, turbo off, governor=performance). See the main methodology page.

At N ∈ {8, 16, 32}, a linear scan completes in sub-microsecond time — the
benchmark timer overhead is non-trivial relative to the work. The reported
figures are median over 20 repetitions; treat them as order-of-magnitude
context ("classical at N=32 runs in ~X ns") rather than high-precision timing.
The quantum experiment's metric is P(success), not ns/op; these numbers provide
scale context, not a direct head-to-head comparison.

## Build and run (Ubuntu reference rig)

```bash
cd Crucible/bench
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build --target bench_quantum_classical_baseline
./build/bench/demos/quantum-classical-baseline/bench_quantum_classical_baseline \
    --benchmark_filter=BM_LinearScan$ \
    --benchmark_repetitions=20 \
    --benchmark_report_aggregates_only=false
```

For the extended N-sweep:

```bash
./build/.../bench_quantum_classical_baseline \
    --benchmark_filter=BM_LinearScan_sweep \
    --benchmark_repetitions=5
```
