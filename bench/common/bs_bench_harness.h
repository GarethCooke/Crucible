#pragma once
// Shared harness for Black-Scholes benchmark TUs (demos 03 and 09).
// Provides: PriceFn alias, BsArrayRefs, alignment check, run_bm, sizes.
// The demo's benchmark.cpp still owns: extern declarations, global arrays,
// g_max_abs_err, Variant enum, compute_errors(), and BM_ registrations.

#include <perf_wrapper.h>
#include <benchmark/benchmark.h>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <optional>

namespace crucible {

using PriceFn = void(*)(const float*, const float*, const float*,
                         const float*, const float*, float*, int64_t);

struct BsArrayRefs {
    const float* S;
    const float* K;
    const float* T;
    const float* R;
    const float* Sigma;
    float*       C;
};

[[noreturn]] inline void bs_abort_misaligned(const char* name, const void* ptr) {
    std::cerr << "FATAL: " << name << " at " << ptr
              << " is not 32-byte aligned\n";
    std::abort();
}

inline void bs_check_alignment(BsArrayRefs arr) {
    auto chk = [](const char* n, const void* p) {
        if (reinterpret_cast<uintptr_t>(p) % 32 != 0)
            bs_abort_misaligned(n, p);
    };
    chk("gS",     arr.S);
    chk("gK",     arr.K);
    chk("gT",     arr.T);
    chk("gR",     arr.R);
    chk("gSigma", arr.Sigma);
    chk("gC",     arr.C);
}

inline void bs_run_bm(benchmark::State& state,
                       PriceFn fn, int var_idx,
                       BsArrayRefs arr,
                       const float* max_abs_err) {
    const int64_t n = state.range(0);

#if defined(__x86_64__)
    PerfCounters perf{std::optional<uint64_t>{0xC1}}; // Zen 2 ExRetCops (retired µops), same event uop_diag.sh uses
#else
    PerfCounters perf;
#endif
    PerfCounters::Counts total{};

    for (auto _ : state) {
        perf.start();
        fn(arr.S, arr.K, arr.T, arr.R, arr.Sigma, arr.C, n);
        benchmark::DoNotOptimize(arr.C[0]);
        perf.stop();
        total += perf.read();
    }

    const int64_t ops = static_cast<int64_t>(state.iterations()) * n;
    state.counters["ipc"]                 = total.ipc();
    state.counters["instructions_per_op"] = static_cast<double>(total.instructions) / ops;
    if (total.raw_ok && total.instructions > 0)
        state.counters["uops_per_instruction"] =
            static_cast<double>(total.raw) / total.instructions;
    state.counters["max_abs_error"] = max_abs_err[var_idx];
    state.SetItemsProcessed(ops);
}

inline void bs_register_sizes(benchmark::internal::Benchmark* b) {
    for (int64_t n : {1024LL, 16384LL, 262144LL, 1048576LL})
        b->Arg(n)->MinTime(0.5);
}

} // namespace crucible
