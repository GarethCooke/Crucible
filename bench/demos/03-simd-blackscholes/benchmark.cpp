#include <benchmark/benchmark.h>
#include <machine_info.h>
#include <perf_wrapper.h>

#include <xmmintrin.h>  // _MM_SET_FLUSH_ZERO_MODE
#include <pmmintrin.h>  // _MM_SET_DENORMALS_ZERO_MODE

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <random>
#include <string>

// ─── Variant declarations (defined in separate TUs with per-variant ISA flags)
extern void price_options_scalar_libm(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_scalar_poly(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_sse2(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_avx2_fma(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);

// ─── Input / output arrays ────────────────────────────────────────────────────
// alignas(32): SIMD loads require 32-byte alignment; harness aborts on violation.
static constexpr int64_t MAX_N = 1 << 20; // 1M options

alignas(32) static float gS    [MAX_N];
alignas(32) static float gK    [MAX_N];
alignas(32) static float gT    [MAX_N];
alignas(32) static float gR    [MAX_N];
alignas(32) static float gSigma[MAX_N];
alignas(32) static float gC    [MAX_N]; // shared output scratch

// Per-variant max absolute error against scalar_libm (computed once at start).
static float g_max_abs_err[4] = {};

// ─── Input generation ─────────────────────────────────────────────────────────
static void gen_inputs() {
    std::mt19937 rng(0xCAFEBABE);
    std::uniform_real_distribution<float> dS   (50.0f, 150.0f);
    std::uniform_real_distribution<float> dK   (50.0f, 150.0f);
    std::uniform_real_distribution<float> dT   (0.05f, 2.0f  );
    std::uniform_real_distribution<float> dR   (0.0f,  0.08f );
    std::uniform_real_distribution<float> dSig (0.1f,  0.6f  );
    for (int64_t i = 0; i < MAX_N; ++i) {
        gS    [i] = dS(rng);
        gK    [i] = dK(rng);
        gT    [i] = dT(rng);
        gR    [i] = dR(rng);
        gSigma[i] = dSig(rng);
    }
}

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
// Computes per-variant max|C_variant - C_libm| over the full 1M input set.
// Results cached in g_max_abs_err[].
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

    price_options_sse2(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[2] = max_err(gC);

    price_options_avx2_fma(gS, gK, gT, gR, gSigma, gC, MAX_N);
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
static void BM_SSE2      (benchmark::State& s) { run_bm(s, price_options_sse2,        2); }
static void BM_AVX2FMA   (benchmark::State& s) { run_bm(s, price_options_avx2_fma,    3); }

static void sizes(benchmark::internal::Benchmark* b) {
    for (int64_t n : {1024LL, 16384LL, 262144LL, 1048576LL})
        b->Arg(n)->MinTime(0.5);
}

BENCHMARK(BM_ScalarLibm)->Apply(sizes);
BENCHMARK(BM_ScalarPoly)->Apply(sizes);
BENCHMARK(BM_SSE2      )->Apply(sizes);
BENCHMARK(BM_AVX2FMA   )->Apply(sizes);

// ─── Custom main ─────────────────────────────────────────────────────────────
int main(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        if (std::string(argv[i]) == "--machine-info") {
            std::cout << "{" << crucible::machine_info_json() << "}\n";
            return 0;
        }
    }

    // Set FTZ + DAZ: Black-Scholes produces subnormals in deep-OTM tails.
    // Without these, subnormal results cost 50+ cycles each on Zen 2.
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);

    gen_inputs();
    check_alignment();
    compute_errors();

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
