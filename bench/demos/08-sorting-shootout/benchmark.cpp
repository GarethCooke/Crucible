// Sorting shootout benchmark — Demo 08
//
// Usage:
//   bench_08_sorting_shootout [Google Benchmark flags]
//   bench_08_sorting_shootout --machine-info
//   bench_08_sorting_shootout --verify-restore
//
// Benchmark naming scheme (embedded in the registered name so assemble_results_08.py
// can extract all three dimensions without side-channel files):
//   BM_Sort_u32/<variant>/<distribution>/<n>
//   BM_Sort_u64/<variant>/<distribution>/<n>
//
// Set A — N-sweep (chart 1):  distribution=random, key_type=u32,
//         N = 2^10 … 2^26, 5 repetitions each.
// Set B — distribution sweep (chart 2): key_type=u32, N=2^22,
//         all five distributions except random (random comes from Set A),
//         5 repetitions each.
// Set C — u64 confirmation: key_type=u64, distribution=random, N=2^22,
//         5 repetitions. Quantifies the key-width penalty for the callout.
//
// Destructive-sort hazard:
//   Each timed iteration restores a pristine master copy into the work buffer
//   with memcpy in the PauseTiming region. A broken restore collapses std::sort
//   from ~iteration-1-cost to its sorted-input cost from iteration 2 onward,
//   while leaving radix unaffected. --verify-restore checks for this signature.

#include <benchmark/benchmark.h>
#include <machine_info.h>

#include "inputs.h"
#include "radix.h"

#include <algorithm>
#include <cassert>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <iostream>
#include <random>
#include <string_view>
#include <vector>

#include <pdqsort.h>

// ─── Seeds ────────────────────────────────────────────────────────────────────
// Fixed seeds ensure the master input is identical across all invocations.
// Documented in README.md.
static constexpr uint64_t MASTER_SEED_U32 = 0xC0FFEE42ULL;
static constexpr uint64_t MASTER_SEED_U64 = 0xDEADBEEF1234ULL;

// ─── Sort wrappers ────────────────────────────────────────────────────────────
// Uniform two-argument signature: (work_buf, scratch_buf).
// Scratch is only used by radix; the other variants ignore it.

template <class T>
static void sort_std(std::vector<T>& a, std::vector<T>&) {
    std::sort(a.begin(), a.end());
}

template <class T>
static void sort_pdq(std::vector<T>& a, std::vector<T>&) {
    pdqsort(a.begin(), a.end());
}

template <class T>
static void sort_radix(std::vector<T>& a, std::vector<T>& tmp) {
    radix_lsd(a, tmp);
}

// ─── Core benchmark ───────────────────────────────────────────────────────────

template <class T>
using SortFn = void (*)(std::vector<T>&, std::vector<T>&);

template <class T>
static void BM_Sort(benchmark::State& state, SortFn<T> sort_fn, Dist dist, uint64_t seed) {
    const size_t n = static_cast<size_t>(state.range(0));
    std::mt19937_64 rng(seed);
    const std::vector<T> master = make_input<T>(dist, n, rng);
    std::vector<T> work(n), tmp(n);

    for (auto _ : state) {
        state.PauseTiming();
        std::memcpy(work.data(), master.data(), n * sizeof(T));  // restore — UNTIMED
        state.ResumeTiming();
        sort_fn(work, tmp);
        benchmark::DoNotOptimize(work.data());
        benchmark::ClobberMemory();
    }
    state.SetItemsProcessed(state.iterations() * static_cast<int64_t>(n));
}

// ─── Registration helpers ─────────────────────────────────────────────────────

static constexpr int REPS = 5;

// Set A: N-sweep on random u32.
// Names: BM_Sort_u32/std_sort/random/<n>, BM_Sort_u32/pdqsort/random/<n>, etc.
static void reg_u32_random(SortFn<uint32_t> fn, const char* name) {
    auto* b = benchmark::RegisterBenchmark(
        name, BM_Sort<uint32_t>, fn, Dist::Random, MASTER_SEED_U32);
    b->RangeMultiplier(2)->Range(1024, 67108864)->Repetitions(REPS)->ReportAggregatesOnly(false);
}

// Set B: distribution sweep at fixed N=2^22 (all dists except random, which comes from Set A).
static void reg_u32_dist(SortFn<uint32_t> fn, const char* name, Dist dist) {
    auto* b = benchmark::RegisterBenchmark(
        name, BM_Sort<uint32_t>, fn, dist, MASTER_SEED_U32);
    b->Arg(4194304)->Repetitions(REPS)->ReportAggregatesOnly(false);
}

// Set C: u64 confirmation at N=2^22 random.
static void reg_u64_random(SortFn<uint64_t> fn, const char* name) {
    auto* b = benchmark::RegisterBenchmark(
        name, BM_Sort<uint64_t>, fn, Dist::Random, MASTER_SEED_U64);
    b->Arg(4194304)->Repetitions(REPS)->ReportAggregatesOnly(false);
}

// ─── --verify-restore check ───────────────────────────────────────────────────
// Runs std::sort on random u32 data with and without the per-iteration restore.
// Prints per-rep ns/elem to stderr. Exit 0 if WITH-restore timings are steady;
// exit 1 if they trend downward (restore is broken).

static int verify_restore() {
    constexpr size_t N = 1 << 20;  // 1 M elements
    constexpr int VERIFY_REPS = 8;

    std::mt19937_64 rng(MASTER_SEED_U32);
    const std::vector<uint32_t> master = make_input<uint32_t>(Dist::Random, N, rng);

    using clk = std::chrono::steady_clock;
    auto ns_per_elem = [](clk::time_point t0, clk::time_point t1) {
        return std::chrono::duration<double, std::nano>(t1 - t0).count() / N;
    };

    std::fprintf(stderr, "\n=== verify-restore: std::sort, N=%zu, u32 ===\n", N);
    std::fprintf(stderr, "Expected: WITH-restore reps are steady; WITHOUT-restore collapses from rep 1 onward.\n\n");

    for (int mode = 0; mode < 2; ++mode) {
        const bool do_restore = (mode == 0);
        std::fprintf(stderr, "%s restore:\n", do_restore ? "WITH" : "WITHOUT");
        std::vector<uint32_t> work = master;
        std::vector<double> times;
        for (int r = 0; r < VERIFY_REPS; ++r) {
            if (do_restore) std::memcpy(work.data(), master.data(), N * sizeof(uint32_t));
            const auto t0 = clk::now();
            std::sort(work.begin(), work.end());
            const auto t1 = clk::now();
            benchmark::DoNotOptimize(work.data());
            const double ns = ns_per_elem(t0, t1);
            times.push_back(ns);
            std::fprintf(stderr, "  rep %d  %.3f ns/elem\n", r, ns);
        }
        std::fprintf(stderr, "\n");

        // For the WITH-restore mode, check that reps do not trend downward.
        // A 50%+ drop from rep 0 to any later rep is the destructive-sort signature.
        if (do_restore && times.size() >= 2) {
            const double rep0 = times[0];
            for (int r = 1; r < VERIFY_REPS; ++r) {
                if (times[r] < rep0 * 0.50) {
                    std::fprintf(stderr,
                        "FAIL: rep %d (%.3f ns/elem) is <50%% of rep 0 (%.3f ns/elem).\n"
                        "      The restore is broken — do not capture.\n", r, times[r], rep0);
                    return 1;
                }
            }
            std::fprintf(stderr, "PASS: WITH-restore timings are steady (no downward trend).\n\n");
        }
    }

    return 0;
}

// ─── Registration ─────────────────────────────────────────────────────────────

// Called once at program startup (before main) via BENCHMARK macro side-effects.
// Using RegisterBenchmark in a [[gnu::constructor]] ensures the names are
// registered before benchmark::Initialize sees argc/argv.

[[gnu::constructor]]
static void register_benchmarks() {
    // Set A: N-sweep, random u32
    reg_u32_random(sort_std<uint32_t>,   "BM_Sort_u32/std_sort/random");
    reg_u32_random(sort_pdq<uint32_t>,   "BM_Sort_u32/pdqsort/random");
    reg_u32_random(sort_radix<uint32_t>, "BM_Sort_u32/radix_lsd/random");

    // Set B: distribution sweep, u32, N=2^22
    for (Dist dist : {Dist::Sorted, Dist::Reverse, Dist::FewUnique, Dist::Sawtooth}) {
        const char* dn = dist_name(dist);
        char name_std[64], name_pdq[64], name_rad[64];
        std::snprintf(name_std, sizeof(name_std), "BM_Sort_u32/std_sort/%s", dn);
        std::snprintf(name_pdq, sizeof(name_pdq), "BM_Sort_u32/pdqsort/%s", dn);
        std::snprintf(name_rad, sizeof(name_rad), "BM_Sort_u32/radix_lsd/%s", dn);
        // NOTE: snprintf-allocated strings are consumed immediately by RegisterBenchmark,
        // which copies the name internally, so stack buffers are safe here.
        reg_u32_dist(sort_std<uint32_t>,   name_std, dist);
        reg_u32_dist(sort_pdq<uint32_t>,   name_pdq, dist);
        reg_u32_dist(sort_radix<uint32_t>, name_rad, dist);
    }

    // Set C: u64 confirmation, N=2^22
    reg_u64_random(sort_std<uint64_t>,   "BM_Sort_u64/std_sort/random");
    reg_u64_random(sort_pdq<uint64_t>,   "BM_Sort_u64/pdqsort/random");
    reg_u64_random(sort_radix<uint64_t>, "BM_Sort_u64/radix_lsd/random");
}

// ─── Main ─────────────────────────────────────────────────────────────────────

int main(int argc, char** argv) {
    if (argc > 1 && std::string_view(argv[1]) == "--machine-info") {
        std::cout << "{" << crucible::machine_info_json() << "}\n";
        return 0;
    }

    if (argc > 1 && std::string_view(argv[1]) == "--verify-restore") {
        return verify_restore();
    }

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
