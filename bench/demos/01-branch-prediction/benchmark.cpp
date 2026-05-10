#include <benchmark/benchmark.h>
#include <perf_wrapper.h>
#include <stats.h>
#include <machine_info.h>

#include <algorithm>
#include <cstdint>
#include <iostream>
#include <random>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
// Input generation
// ---------------------------------------------------------------------------

// Values cycle 0..255 so exactly half satisfy x >= 128.
static std::vector<int32_t> make_base(int64_t n) {
    std::vector<int32_t> v(static_cast<size_t>(n));
    for (int64_t i = 0; i < n; ++i)
        v[static_cast<size_t>(i)] = static_cast<int32_t>(i % 256);
    return v;
}

static std::vector<int32_t> make_sorted(int64_t n) {
    auto v = make_base(n);
    std::sort(v.begin(), v.end());
    return v;
}

static std::vector<int32_t> make_shuffled(int64_t n) {
    auto v = make_base(n);
    std::mt19937 rng(42); // fixed seed for reproducibility
    std::shuffle(v.begin(), v.end(), rng);
    return v;
}

// ---------------------------------------------------------------------------
// Hot loop — identical code for both variants, only input ordering differs.
// ---------------------------------------------------------------------------

// Disable the two transformations that defeat this experiment:
//   - tree-vectorize  -> SIMD masked add (no branch)
//   - if-conversion   -> scalar cmov     (no branch)
// Keeping -O3 elsewhere; only this function is constrained.
__attribute__((noinline, optimize("no-tree-vectorize",
                                  "no-if-conversion",
                                  "no-if-conversion2")))
static int64_t sum_threshold(const std::vector<int32_t>& data) {
    int64_t sum = 0;
    for (auto x : data) {
        if (x >= 128) sum += x;
    }
    return sum;
}

// ---------------------------------------------------------------------------
// Benchmarks
// ---------------------------------------------------------------------------

static void BM_impl(benchmark::State& state, bool sorted) {
    const int64_t n = state.range(0);
    const auto data = sorted ? make_sorted(n) : make_shuffled(n);

    crucible::PerfCounters perf;
    crucible::PerfCounters::Counts total{};

    for (auto _ : state) {
        perf.start();
        auto result = sum_threshold(data);
        benchmark::DoNotOptimize(result);
        perf.stop();
        total += perf.read();
    }

    const int64_t ops = static_cast<int64_t>(state.iterations()) * n;
    state.counters["branch_misses_per_op"] = total.branch_misses_per_op(ops);
    state.counters["ipc"]                  = total.ipc();
    state.SetItemsProcessed(ops);
}

static void BM_Sorted(benchmark::State& state)   { BM_impl(state, true);  }
static void BM_Unsorted(benchmark::State& state) { BM_impl(state, false); }

// Run at six sizes. --benchmark_repetitions=20 is set in run_one.sh.
static void sizes(benchmark::internal::Benchmark* b) {
    for (int64_t n : {1024LL, 10240LL, 102400LL, 1048576LL, 10485760LL, 33554432LL})
        b->Arg(n)->MinTime(0.5);
}

BENCHMARK(BM_Sorted)  ->Apply(sizes);
BENCHMARK(BM_Unsorted)->Apply(sizes);

// ---------------------------------------------------------------------------
// Custom main: optionally print machine info before running benchmarks.
// ---------------------------------------------------------------------------

int main(int argc, char** argv) {
    // --machine-info flag: print machine JSON and exit (used by run_one.sh)
    for (int i = 1; i < argc; ++i) {
        if (std::string(argv[i]) == "--machine-info") {
            std::cout << "{" << crucible::machine_info_json() << "}\n";
            return 0;
        }
    }

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
