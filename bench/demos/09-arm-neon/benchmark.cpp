#include "inputs.h"

#include <benchmark/benchmark.h>
#include <machine_info.h>
#include <perf_wrapper.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <string>

// ─── Variant declarations (defined in separate TUs with per-variant ISA flags)
extern void price_options_scalar_libm(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_scalar_poly(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_autovec(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_neon(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);

// ─── Input / output arrays ────────────────────────────────────────────────────
// alignas(16): NEON vld1q_f32 requires 16-byte alignment minimum.
// Using 32 for consistency with demo 03 harness convention.
static constexpr int64_t MAX_N = 1 << 20; // 1M options

alignas(32) static float gS    [MAX_N];
alignas(32) static float gK    [MAX_N];
alignas(32) static float gT    [MAX_N];
alignas(32) static float gR    [MAX_N];
alignas(32) static float gSigma[MAX_N];
alignas(32) static float gC    [MAX_N];

// Per-variant max absolute error against scalar_libm (computed once at start).
static float g_max_abs_err[4] = {};

// ─── Alignment check ─────────────────────────────────────────────────────────
[[noreturn]] static void abort_misaligned(const char* name, const void* ptr) {
    std::cerr << "FATAL: " << name << " at " << ptr
              << " is not 32-byte aligned\n";
    std::abort();
}

static void check_alignment() {
    auto chk = [](const char* n, const void* p) {
        if (reinterpret_cast<uintptr_t>(p) % 32 != 0)
            abort_misaligned(n, p);
    };
    chk("gS",     gS);
    chk("gK",     gK);
    chk("gT",     gT);
    chk("gR",     gR);
    chk("gSigma", gSigma);
    chk("gC",     gC);
}

// ─── Correctness check ───────────────────────────────────────────────────────
alignas(32) static float gC_ref[MAX_N];

static void compute_errors() {
    price_options_scalar_libm(gS, gK, gT, gR, gSigma, gC_ref, MAX_N);

    auto max_err = [&](float* out) -> float {
        float e = 0.0f;
        for (int64_t i = 0; i < MAX_N; ++i)
            e = std::max(e, std::abs(out[i] - gC_ref[i]));
        return e;
    };

    g_max_abs_err[0] = 0.0f; // scalar_libm vs itself

    price_options_scalar_poly(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[1] = max_err(gC);

    price_options_autovec(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[2] = max_err(gC);

    price_options_neon(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[3] = max_err(gC);
}

// ─── Benchmark helper ─────────────────────────────────────────────────────────
using PriceFn = void(*)(const float*, const float*, const float*, const float*, const float*, float*, int64_t);

static void run_bm(benchmark::State& state, PriceFn fn, int var_idx) {
    const int64_t n = state.range(0);

    crucible::PerfCounters perf;
    crucible::PerfCounters::Counts total{};

    for (auto _ : state) {
        perf.start();
        fn(gS, gK, gT, gR, gSigma, gC, n);
        benchmark::DoNotOptimize(gC[0]);
        perf.stop();
        total += perf.read();
    }

    const int64_t ops = static_cast<int64_t>(state.iterations()) * n;
    state.counters["ipc"]           = total.ipc();
    state.counters["max_abs_error"] = g_max_abs_err[var_idx];
    state.SetItemsProcessed(ops);
}

// ─── Benchmark registrations ──────────────────────────────────────────────────
static void BM_ScalarLibm(benchmark::State& s) { run_bm(s, price_options_scalar_libm, 0); }
static void BM_ScalarPoly(benchmark::State& s) { run_bm(s, price_options_scalar_poly, 1); }
static void BM_Autovec   (benchmark::State& s) { run_bm(s, price_options_autovec,     2); }
static void BM_Neon      (benchmark::State& s) { run_bm(s, price_options_neon,        3); }

static void sizes(benchmark::internal::Benchmark* b) {
    for (int64_t n : {1024LL, 16384LL, 262144LL, 1048576LL})
        b->Arg(n)->MinTime(0.5);
}

BENCHMARK(BM_ScalarLibm)->Apply(sizes);
BENCHMARK(BM_ScalarPoly)->Apply(sizes);
BENCHMARK(BM_Autovec   )->Apply(sizes);
BENCHMARK(BM_Neon      )->Apply(sizes);

// ─── Custom main ─────────────────────────────────────────────────────────────
int main(int argc, char** argv) {
    if (argc > 1 && std::string_view(argv[1]) == "--machine-info") {
        std::cout << "{" << crucible::machine_info_json() << "}\n";
        return 0;
    }

    // Set FPCR FZ bit: Black-Scholes produces subnormals in deep-OTM tails.
    // Without FZ, subnormal results cost 50+ cycles each on the A76.
    // AArch64 equivalent of x86 _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON).
#ifdef __aarch64__
    {
        uint64_t fpcr;
        __asm__ volatile("mrs %0, fpcr" : "=r"(fpcr));
        fpcr |= (1ULL << 24);
        __asm__ volatile("msr fpcr, %0" :: "r"(fpcr));
    }
#endif

    gen_inputs(gS, gK, gT, gR, gSigma, MAX_N);
    check_alignment();
    compute_errors();

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
