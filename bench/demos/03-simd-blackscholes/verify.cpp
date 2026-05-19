// Standalone correctness checker. Built as verify_03_simd_blackscholes.
// Run by run_one.sh before the benchmark proper.
//
// Generates the same 1M inputs as benchmark.cpp (same RNG seed 0xCAFEBABE),
// prices them with all four variants, and reports max|C_variant - C_libm|.
// Exits 0 if all variants meet the 1e-4 threshold; exits 1 otherwise.

#include "inputs.h"
#include "poly.h"

#include <xmmintrin.h>
#include <pmmintrin.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <vector>

extern void price_options_scalar_libm(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_scalar_poly(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_sse2(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);
extern void price_options_avx2_fma(
    const float*, const float*, const float*, const float*, const float*, float*, int64_t);

static constexpr int64_t N = 1 << 20;

alignas(32) static float gS    [N];
alignas(32) static float gK    [N];
alignas(32) static float gT    [N];
alignas(32) static float gR    [N];
alignas(32) static float gSigma[N];
alignas(32) static float gRef  [N];
alignas(32) static float gOut  [N];

static float max_abs_err(const float* a, const float* b, int64_t n) {
    float e = 0.0f;
    for (int64_t i = 0; i < n; ++i)
        e = std::max(e, std::abs(a[i] - b[i]));
    return e;
}

int main() {
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);

    gen_inputs(gS, gK, gT, gR, gSigma, N);
    price_options_scalar_libm(gS, gK, gT, gR, gSigma, gRef, N);

    static constexpr float THRESHOLD = 1e-4f;
    bool all_pass = true;

    struct { const char* name; void(*fn)(const float*, const float*, const float*, const float*, const float*, float*, int64_t); } variants[] = {
        {"scalar_poly",    price_options_scalar_poly},
        {"sse2_intrinsics",price_options_sse2       },
        {"avx2_fma",       price_options_avx2_fma   },
    };

    for (auto& v : variants) {
        v.fn(gS, gK, gT, gR, gSigma, gOut, N);
        float err = max_abs_err(gRef, gOut, N);
        bool pass = (err < THRESHOLD);
        std::printf("%-22s  max_abs_error = %.2e  %s\n",
            v.name, static_cast<double>(err), pass ? "PASS" : "FAIL");
        if (!pass) all_pass = false;
    }

    return all_pass ? 0 : 1;
}
