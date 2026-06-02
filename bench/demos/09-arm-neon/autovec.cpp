// Variant 3: autovec — natural libm kernel, no anti-autovec guard.
// Same loop body as scalar_libm.cpp; only the function name and the
// optimize("no-tree-vectorize") attribute differ.  GCC is free to autovectorise.
// Compiled with: -O3 -mcpu=cortex-a76
//
// Pilot finding (and §2 acceptance criterion): GCC cannot cross the logf@plt
// call — it cannot prove logf is side-effect-free and vectorisable.  The
// generated asm is scalar, byte-identical to scalar_libm after address
// normalisation, and timed within 0.1%.  This is the "baseline ≠ free" story:
// on AArch64 where NEON is always on, "doing nothing" still leaves 4.5× on the
// table; the compiler cannot collect it automatically.
// Acceptance: zero .4s parallel-float compute ops in the hot loop.

#include "inputs.h"
#include <cmath>
#include <cstdint>

__attribute__((noinline))
void price_options_autovec(
    const float* __restrict__ S,
    const float* __restrict__ K,
    const float* __restrict__ T,
    const float* __restrict__ r,
    const float* __restrict__ sigma,
    float*       __restrict__ C,
    int64_t n)
{
    for (int64_t i = 0; i < n; ++i) {
        float s = S[i], k = K[i], t = T[i], rv = r[i], sig = sigma[i];
        float sig_sqrtT = sig * std::sqrt(t);
        float d1 = (std::log(s / k) + (rv + 0.5f * sig * sig) * t) / sig_sqrtT;
        float d2 = d1 - sig_sqrtT;
        float Nd1 = 0.5f * std::erfc(-d1 * BS_SQRT1_2F);
        float Nd2 = 0.5f * std::erfc(-d2 * BS_SQRT1_2F);
        C[i] = s * Nd1 - k * std::exp(-rv * t) * Nd2;
    }
}
