// Variant 1: scalar_libm — correctness oracle.
// Uses std::exp, std::log, std::sqrt, std::erfc from <cmath> for every option.
// Compiled with: -O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2
// __attribute__ redundantly guards against per-function auto-vectorisation in
// case -fno-tree-vectorize is insufficient on a future compiler revision.

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
    static constexpr float M_SQRT1_2F = 0.70710678118654752f; // 1/√2
    for (int64_t i = 0; i < n; ++i) {
        float s = S[i], k = K[i], t = T[i], rv = r[i], sig = sigma[i];
        float sig_sqrtT = sig * std::sqrt(t);
        float d1 = (std::log(s / k) + (rv + 0.5f * sig * sig) * t) / sig_sqrtT;
        float d2 = d1 - sig_sqrtT;
        // N(x) = 0.5 * erfc(-x / √2)
        float Nd1 = 0.5f * std::erfc(-d1 * M_SQRT1_2F);
        float Nd2 = 0.5f * std::erfc(-d2 * M_SQRT1_2F);
        C[i] = s * Nd1 - k * std::exp(-rv * t) * Nd2;
    }
}
