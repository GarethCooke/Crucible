// Variant 2: scalar_poly — same loop as scalar_libm but with polynomial
// approximations for exp and erfc/N(x); std::log and std::sqrt remain libm.
// Compiled with: -O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2
//
// Isolates the *algorithm win* (polynomial vs libm transcendentals) before
// adding SIMD width.  See poly.h for coefficients and sources.

#include "poly.h"
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
