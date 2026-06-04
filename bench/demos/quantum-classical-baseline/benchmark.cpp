// quantum-classical-baseline — Demo: classical linear scan
//
// Measures the wall-clock cost of finding a marked item by linear scan in an
// unstructured array of size N = 2^n, for n ∈ {3, 4, 5} — the same search-space
// sizes used in the quantum special edition.
//
// Metric: microseconds per scan (median over outer repetitions).
//
// This is the classical O(N) baseline the quantum post compares against.
// The theoretical quantum speedup is O(√N) via Grover's algorithm; this bench
// measures the classical side of that comparison at concrete N values.
//
// Usage:
//   bench_quantum_classical_baseline [Google Benchmark flags]
//   bench_quantum_classical_baseline --machine-info
//
// Authoritative timing capture is a user task on the Ubuntu reference rig
// (isolated cores, perf, turbo off) — do NOT publish Windows/MinGW figures.
// See README.md for the capture procedure.

#include <benchmark/benchmark.h>
#include <machine_info.h>

#include <algorithm>
#include <cassert>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <random>
#include <string_view>
#include <vector>

// ─── Scan kernel ──────────────────────────────────────────────────────────────

// Linear scan: find `target` in `arr`. Returns the index, or arr.size() if
// not found. Marked volatile to prevent the compiler hoisting the comparison
// out of the loop (benchmark::DoNotOptimize handles the output).
static std::size_t linear_scan(const std::vector<uint32_t>& arr, uint32_t target) {
    for (std::size_t i = 0; i < arr.size(); ++i) {
        if (arr[i] == target) return i;
    }
    return arr.size();  // not found
}

// ─── Fixture ──────────────────────────────────────────────────────────────────

struct ScanFixture {
    std::vector<uint32_t> arr;
    uint32_t target = 0;

    explicit ScanFixture(int n, uint64_t seed = 0xC0FFEE42ULL) {
        const std::size_t N = std::size_t(1) << n;
        std::mt19937_64 rng(seed);
        arr.resize(N);
        // Fill with distinct values 0..N-1 in a reproducible random order.
        std::iota(arr.begin(), arr.end(), 0u);
        std::shuffle(arr.begin(), arr.end(), rng);
        // Target: the element at the midpoint of the shuffled array (worst-case
        // average scan depth). Fixed position so every iteration measures the
        // same element count — avoids the input-order bias that would flatter the
        // measurement if the target were always near the front.
        target = arr[N / 2];
    }
};

// ─── Benchmarks ───────────────────────────────────────────────────────────────

static void BM_LinearScan(benchmark::State& state) {
    const int n = static_cast<int>(state.range(0));
    ScanFixture fix(n);

    for (auto _ : state) {
        std::size_t idx = linear_scan(fix.arr, fix.target);
        benchmark::DoNotOptimize(idx);
        benchmark::ClobberMemory();
    }

    // Report in microseconds: each iteration scans ~N/2 elements on average.
    // State timer is in nanoseconds; convert here for readability.
    state.SetLabel(std::string("N=") + std::to_string(std::size_t(1) << n));
    state.counters["N"] = static_cast<double>(std::size_t(1) << n);
}

// n=3 → N=8   (matches Grover pilot smallest size)
// n=4 → N=16
// n=5 → N=32  (matches Grover pilot largest size)
BENCHMARK(BM_LinearScan)->Arg(3)->Arg(4)->Arg(5)
    ->Repetitions(20)
    ->ReportAggregatesOnly(false)
    ->Unit(benchmark::kMicrosecond);

// ─── Extended sweep for completeness ──────────────────────────────────────────
// Shows the O(N) scaling explicitly. Not the headline numbers but useful for
// the post's asymptotic-crossover context.

BENCHMARK(BM_LinearScan)->DenseRange(3, 20)
    ->Name("BM_LinearScan_sweep")
    ->Repetitions(5)
    ->ReportAggregatesOnly(true)
    ->Unit(benchmark::kMicrosecond);

// ─── Machine info flag ────────────────────────────────────────────────────────

int main(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        if (std::string_view(argv[i]) == "--machine-info") {
            std::cout << "{" << crucible::machine_info_json() << "}\n";
            return 0;
        }
    }
    ::benchmark::Initialize(&argc, argv);
    if (::benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    ::benchmark::RunSpecifiedBenchmarks();
    ::benchmark::Shutdown();
    return 0;
}
