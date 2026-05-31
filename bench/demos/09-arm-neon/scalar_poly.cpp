// Variant 2: scalar_poly — demo 03's exact construction, width-ratio denominator.
// libm log + libm sqrt + inline poly exp (fast_expf) + inline poly N(x) (ncdf_poly).
// Single-element serial; directly comparable to demo 03's scalar_poly on Zen 2.
// Compiled with: -O3 -mcpu=cortex-a76 -fno-tree-vectorize
//
// Pilot finding: this variant is dead-equal to scalar_libm on the A76 (within
// 0.05%), unlike Zen 2 where the poly swap is +11%.  The A76 poly advantage
// does not travel.  Consequence: baseline choice does not change the neon ratio.
// Acceptance: logf@plt present, expf@plt and erff@plt absent; zero .4s.

#include "../03-simd-blackscholes/poly.h"
#include <cstdint>

__attribute__((noinline, optimize("no-tree-vectorize")))
void price_options_scalar_poly(
    const float* __restrict__ S,
    const float* __restrict__ K,
    const float* __restrict__ T,
    const float* __restrict__ r,
    const float* __restrict__ sigma,
    float*       __restrict__ C,
    int64_t n)
{
    for (int64_t i = 0; i < n; ++i) {
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
    }
}
