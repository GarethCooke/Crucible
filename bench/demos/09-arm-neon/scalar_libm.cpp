// Variant 1: scalar_libm — correctness oracle and autovec comparand.
// Uses std::log, std::sqrt, std::exp, std::erfc from <cmath> for every option.
// Compiled with: -O3 -mcpu=cortex-a76 -fno-tree-vectorize
//
// On AArch64, NEON is always available at -O3; -fno-tree-vectorize + the
// __attribute__ guard together ensure genuinely 1-wide scalar code so this
// variant is the "baseline = not free" comparand for autovec.
// Acceptance: logf@plt present in the hot loop; zero .4s parallel-float ops.

#include "inputs.h"
#include <cmath>
#include <cstdint>

__attribute__((noinline, optimize("no-tree-vectorize")))
void price_options_scalar_libm(
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
        // N(x) = 0.5 * erfc(-x / √2)
        float Nd1 = 0.5f * std::erfc(-d1 * BS_SQRT1_2F);
        float Nd2 = 0.5f * std::erfc(-d2 * BS_SQRT1_2F);
        C[i] = s * Nd1 - k * std::exp(-rv * t) * Nd2;
    }
}
