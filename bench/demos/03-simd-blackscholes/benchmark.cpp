#include "inputs.h"

#include <benchmark/benchmark.h>
#include <bs_bench_harness.h>
#include <machine_info.h>

#include <xmmintrin.h>  // _MM_SET_FLUSH_ZERO_MODE
#include <pmmintrin.h>  // _MM_SET_DENORMALS_ZERO_MODE

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
extern void price_options_sse2(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_avx2_fma(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);

// ─── Variant index mapping ────────────────────────────────────────────────────
enum Variant : int { kScalarLibm = 0, kScalarPoly = 1, kSSE2 = 2, kAVX2FMA = 3, kVariantCount = 4 };

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
static float g_max_abs_err[kVariantCount] = {};

// ─── Alignment check ─────────────────────────────────────────────────────────
static void check_alignment() {
    crucible::bs_check_alignment({gS, gK, gT, gR, gSigma, gC});
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

    g_max_abs_err[kScalarLibm] = 0.0f; // scalar_libm vs itself

    price_options_scalar_poly(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[kScalarPoly] = max_err(gC);

    price_options_sse2(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[kSSE2] = max_err(gC);

    price_options_avx2_fma(gS, gK, gT, gR, gSigma, gC, MAX_N);
    g_max_abs_err[kAVX2FMA] = max_err(gC);
}

// ─── Benchmark registrations ──────────────────────────────────────────────────
static const crucible::BsArrayRefs g_arrs{gS, gK, gT, gR, gSigma, gC};

static void BM_ScalarLibm(benchmark::State& s) { crucible::bs_run_bm(s, price_options_scalar_libm, kScalarLibm, g_arrs, g_max_abs_err); }
static void BM_ScalarPoly(benchmark::State& s) { crucible::bs_run_bm(s, price_options_scalar_poly, kScalarPoly, g_arrs, g_max_abs_err); }
static void BM_SSE2      (benchmark::State& s) { crucible::bs_run_bm(s, price_options_sse2,        kSSE2,       g_arrs, g_max_abs_err); }
static void BM_AVX2FMA   (benchmark::State& s) { crucible::bs_run_bm(s, price_options_avx2_fma,    kAVX2FMA,   g_arrs, g_max_abs_err); }

BENCHMARK(BM_ScalarLibm)->Apply(crucible::bs_register_sizes);
BENCHMARK(BM_ScalarPoly)->Apply(crucible::bs_register_sizes);
BENCHMARK(BM_SSE2      )->Apply(crucible::bs_register_sizes);
BENCHMARK(BM_AVX2FMA   )->Apply(crucible::bs_register_sizes);

// ─── Custom main ─────────────────────────────────────────────────────────────
int main(int argc, char** argv) {
    if (argc > 1 && std::string_view(argv[1]) == "--machine-info") {
        std::cout << "{" << crucible::machine_info_json() << "}\n";
        return 0;
    }

    // Set FTZ + DAZ: Black-Scholes produces subnormals in deep-OTM tails.
    // Without these, subnormal results cost 50+ cycles each on Zen 2.
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);

    gen_inputs(gS, gK, gT, gR, gSigma, MAX_N);
    check_alignment();
    compute_errors();

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;
    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
