// Variant 3: sse2_intrinsics — 4-wide SSE2/SSE4.1 using __m128 intrinsics.
// Same polynomial math as scalar_poly, widened to 4 lanes.
// Compiled with: -O3 -msse4.2 -mno-avx -mno-avx2 -mno-fma
//
// log(S/K): vectorised with fast_logf_sse (Cephes 9-coeff poly).
// sqrt(T):  _mm_sqrt_ps (hardware).
// exp, N(x): vectorised via vec_expf_sse + vec_ncdf_sse.
// Aligned loads via _mm_load_ps (arrays are alignas(32)).
// Scalar tail loop handles N not a multiple of 4.

#include "poly.h"

#include <xmmintrin.h>   // SSE
#include <emmintrin.h>   // SSE2
#include <smmintrin.h>   // SSE4.1 (_mm_round_ps, _mm_blendv_ps)
#include <cstdint>

// ─── 4-wide fast_expf ─────────────────────────────────────────────────────────
static inline __m128 vec_expf_sse(__m128 x) {
    const __m128 lo  = _mm_set1_ps(-88.0f);
    const __m128 hi  = _mm_set1_ps( 88.0f);
    const __m128 l2e = _mm_set1_ps(EXP_LOG2E);
    const __m128 ln2 = _mm_set1_ps(EXP_LN2);

    x = _mm_max_ps(x, lo);
    x = _mm_min_ps(x, hi);

    __m128 z = _mm_mul_ps(x, l2e);
    __m128 n = _mm_round_ps(z, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC);
    __m128 r = _mm_sub_ps(x, _mm_mul_ps(n, ln2));

    // 6-stage Horner: C6 + r*(C5 + r*(C4 + r*(C3 + r*(C2 + r*(C1 + r*C0)))))
    __m128 p = _mm_set1_ps(EXP_C6);
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C5));
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C4));
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C3));
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C2));
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C1));
    p = _mm_add_ps(_mm_mul_ps(p, r), _mm_set1_ps(EXP_C0));

    // Scale by 2^n: (int)n + 127, shift to float exponent field.
    __m128i ni    = _mm_cvtps_epi32(n);
    ni            = _mm_add_epi32(ni, _mm_set1_epi32(127));
    ni            = _mm_slli_epi32(ni, 23);
    __m128 scale  = _mm_castsi128_ps(ni);
    return _mm_mul_ps(p, scale);
}

// ─── 4-wide fast_logf (Cephes polynomial) ────────────────────────────────────
static inline __m128 vec_logf_sse(__m128 x) {
    const __m128i mant_mask = _mm_set1_epi32(0x007FFFFF);
    const __m128i exp_bias  = _mm_set1_epi32(0x3F800000);
    const __m128i exp_off   = _mm_set1_epi32(127);
    const __m128  sqrt2     = _mm_set1_ps(LOG_SQRT2);
    const __m128  one       = _mm_set1_ps(1.0f);
    const __m128  half      = _mm_set1_ps(0.5f);
    const __m128  ln2       = _mm_set1_ps(EXP_LN2);

    __m128i xi   = _mm_castps_si128(x);
    // Unbiased exponent
    __m128i ei   = _mm_sub_epi32(_mm_srli_epi32(xi, 23), exp_off);
    // Mantissa with exponent 127 → m ∈ [1, 2)
    __m128i mi   = _mm_or_si128(_mm_and_si128(xi, mant_mask), exp_bias);
    __m128  m    = _mm_castsi128_ps(mi);

    // If m >= sqrt(2): m = m/2, ei += 1
    __m128 mask   = _mm_cmpge_ps(m, sqrt2);
    m             = _mm_blendv_ps(m, _mm_mul_ps(m, half), mask);
    __m128i adj   = _mm_and_si128(_mm_castps_si128(mask), _mm_set1_epi32(1));
    ei            = _mm_add_epi32(ei, adj);

    __m128 f = _mm_sub_ps(m, one);   // f ∈ [-0.293, 0.414)

    // 8-stage Horner for Cephes LOG_P[0..8]:
    __m128 p = _mm_set1_ps(LOG_P[0]);
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[1]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[2]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[3]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[4]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[5]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[6]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[7]));
    p = _mm_add_ps(_mm_mul_ps(p, f), _mm_set1_ps(LOG_P[8]));

    __m128 z     = _mm_mul_ps(f, f);
    __m128 e_f   = _mm_cvtepi32_ps(ei);
    // log(1+f) = f³*p - f²/2 + f + e*ln2
    __m128 res   = _mm_mul_ps(_mm_mul_ps(f, z), p);
    res          = _mm_sub_ps(res, _mm_mul_ps(half, z));
    res          = _mm_add_ps(res, f);
    res          = _mm_add_ps(res, _mm_mul_ps(e_f, ln2));
    return res;
}

// ─── 4-wide ncdf_poly (A&S §26.2.17) ─────────────────────────────────────────
static inline __m128 vec_ncdf_sse(__m128 x) {
    const __m128 zero       = _mm_setzero_ps();
    const __m128 one        = _mm_set1_ps(1.0f);
    const __m128 sign_mask  = _mm_set1_ps(-0.0f);   // bit pattern for sign bit
    const __m128 half       = _mm_set1_ps(-0.5f);   // used for -x²/2

    __m128 neg_mask = _mm_cmplt_ps(x, zero);
    __m128 ax       = _mm_andnot_ps(sign_mask, x);  // abs(x)

    __m128 k = _mm_div_ps(one, _mm_add_ps(one, _mm_mul_ps(_mm_set1_ps(NCDF_P), ax)));

    // Horner: B5 → ×k+B4 → ×k+B3 → ×k+B2 → ×k+B1 → ×k
    __m128 poly = _mm_set1_ps(NCDF_B5);
    poly = _mm_add_ps(_mm_mul_ps(poly, k), _mm_set1_ps(NCDF_B4));
    poly = _mm_add_ps(_mm_mul_ps(poly, k), _mm_set1_ps(NCDF_B3));
    poly = _mm_add_ps(_mm_mul_ps(poly, k), _mm_set1_ps(NCDF_B2));
    poly = _mm_add_ps(_mm_mul_ps(poly, k), _mm_set1_ps(NCDF_B1));
    poly = _mm_mul_ps(poly, k);

    // n(ax) = exp(-0.5*ax²) / √(2π)
    __m128 ax2  = _mm_mul_ps(ax, ax);
    __m128 nax  = vec_expf_sse(_mm_mul_ps(ax2, half));
    nax         = _mm_mul_ps(nax, _mm_set1_ps(ONE_OVER_SQRT2PI));

    __m128 tail = _mm_mul_ps(nax, poly);           // 1 - N(ax)
    __m128 p    = _mm_sub_ps(one, tail);            // N(ax)
    // For x < 0: return tail; for x >= 0: return p
    return _mm_blendv_ps(p, tail, neg_mask);
}

// ─── 4-wide Black-Scholes call price ─────────────────────────────────────────
static inline void price4(
    const float* S, const float* K,
    const float* T, const float* r, const float* sigma,
    float* C)
{
    __m128 vS   = _mm_load_ps(S);
    __m128 vK   = _mm_load_ps(K);
    __m128 vT   = _mm_load_ps(T);
    __m128 vR   = _mm_load_ps(r);
    __m128 vSig = _mm_load_ps(sigma);

    __m128 sig2      = _mm_mul_ps(vSig, vSig);
    __m128 sqrtT     = _mm_sqrt_ps(vT);
    __m128 sig_sqrtT = _mm_mul_ps(vSig, sqrtT);

    __m128 log_SK = vec_logf_sse(_mm_div_ps(vS, vK));
    __m128 half   = _mm_set1_ps(0.5f);
    __m128 d1_num = _mm_add_ps(log_SK,
                        _mm_mul_ps(_mm_add_ps(vR, _mm_mul_ps(half, sig2)), vT));
    __m128 d1     = _mm_div_ps(d1_num, sig_sqrtT);
    __m128 d2     = _mm_sub_ps(d1, sig_sqrtT);

    __m128 Nd1    = vec_ncdf_sse(d1);
    __m128 Nd2    = vec_ncdf_sse(d2);
    __m128 disc   = vec_expf_sse(_mm_mul_ps(_mm_set1_ps(-1.0f), _mm_mul_ps(vR, vT)));

    __m128 C_vec  = _mm_sub_ps(
        _mm_mul_ps(vS, Nd1),
        _mm_mul_ps(_mm_mul_ps(vK, disc), Nd2));
    _mm_store_ps(C, C_vec);
}

// ─── Entry point ─────────────────────────────────────────────────────────────
void price_options_sse2(
    const float* __restrict__ S,
    const float* __restrict__ K,
    const float* __restrict__ T,
    const float* __restrict__ r,
    const float* __restrict__ sigma,
    float*       __restrict__ C,
    int64_t n)
{
    int64_t i = 0;
    for (; i + 3 < n; i += 4)
        price4(S+i, K+i, T+i, r+i, sigma+i, C+i);
    // Scalar tail for remainder < 4.
    for (; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}
