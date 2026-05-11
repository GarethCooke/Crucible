// Variant 4: avx2_fma_intrinsics — 8-wide AVX2+FMA using __m256 intrinsics.
// Same polynomial math as scalar_poly/sse2, widened to 8 lanes.
// Compiled with: -O3 -mavx -mavx2 -mfma
//
// _mm256_fmadd_ps throughout Horner evaluation (replacing separate mul+add).
// On Zen 2: 256-bit AVX2 µops are split into two 128-bit µops internally;
// expect < 2× speedup over SSE on this machine (see README.md for prediction).
// Zen 3 and later dispatch 256-bit natively — the gap would be cleaner there.

#include "poly.h"

#include <immintrin.h>  // AVX, AVX2, FMA
#include <cstdint>

// ─── 8-wide fast_expf (FMA Horner) ───────────────────────────────────────────
static inline __m256 vec_expf_avx2(__m256 x) {
    const __m256 lo  = _mm256_set1_ps(-88.0f);
    const __m256 hi  = _mm256_set1_ps( 88.0f);
    const __m256 l2e = _mm256_set1_ps(EXP_LOG2E);
    const __m256 ln2 = _mm256_set1_ps(EXP_LN2);

    x = _mm256_max_ps(x, lo);
    x = _mm256_min_ps(x, hi);

    __m256 z = _mm256_mul_ps(x, l2e);
    __m256 n = _mm256_round_ps(z, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC);
    // r = x - n*ln2  via FMA: r = -n*ln2 + x
    __m256 r = _mm256_fnmadd_ps(n, ln2, x);

    // 6-stage Horner with FMA: p = C6; p = fmadd(p, r, Ck)
    __m256 p = _mm256_set1_ps(EXP_C6);
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C5));
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C4));
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C3));
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C2));
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C1));
    p = _mm256_fmadd_ps(p, r, _mm256_set1_ps(EXP_C0));

    __m256i ni   = _mm256_cvtps_epi32(n);
    ni           = _mm256_add_epi32(ni, _mm256_set1_epi32(127));
    ni           = _mm256_slli_epi32(ni, 23);
    __m256 scale = _mm256_castsi256_ps(ni);
    return _mm256_mul_ps(p, scale);
}

// ─── 8-wide fast_logf (Cephes polynomial, FMA Horner) ────────────────────────
static inline __m256 vec_logf_avx2(__m256 x) {
    const __m256i mant_mask = _mm256_set1_epi32(0x007FFFFF);
    const __m256i exp_bias  = _mm256_set1_epi32(0x3F800000);
    const __m256i exp_off   = _mm256_set1_epi32(127);
    const __m256  sqrt2     = _mm256_set1_ps(LOG_SQRT2);
    const __m256  one       = _mm256_set1_ps(1.0f);
    const __m256  half      = _mm256_set1_ps(0.5f);
    const __m256  ln2       = _mm256_set1_ps(EXP_LN2);

    __m256i xi = _mm256_castps_si256(x);
    __m256i ei = _mm256_sub_epi32(_mm256_srli_epi32(xi, 23), exp_off);
    __m256i mi = _mm256_or_si256(_mm256_and_si256(xi, mant_mask), exp_bias);
    __m256  m  = _mm256_castsi256_ps(mi);

    __m256  mask  = _mm256_cmp_ps(m, sqrt2, _CMP_GE_OQ);
    m             = _mm256_blendv_ps(m, _mm256_mul_ps(m, half), mask);
    __m256i adj   = _mm256_and_si256(_mm256_castps_si256(mask), _mm256_set1_epi32(1));
    ei            = _mm256_add_epi32(ei, adj);

    __m256 f = _mm256_sub_ps(m, one);

    // 8-stage FMA Horner for Cephes LOG_P[0..8]:
    __m256 p = _mm256_set1_ps(LOG_P[0]);
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[1]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[2]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[3]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[4]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[5]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[6]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[7]));
    p = _mm256_fmadd_ps(p, f, _mm256_set1_ps(LOG_P[8]));

    __m256 z   = _mm256_mul_ps(f, f);
    __m256 e_f = _mm256_cvtepi32_ps(ei);
    // log(1+f) = f³*p - f²/2 + f + e*ln2  (last two terms via FMA)
    __m256 res = _mm256_mul_ps(_mm256_mul_ps(f, z), p);
    res        = _mm256_fnmadd_ps(half, z, res);        // res - 0.5*z
    res        = _mm256_add_ps(res, f);
    res        = _mm256_fmadd_ps(e_f, ln2, res);
    return res;
}

// ─── 8-wide ncdf_poly (A&S §26.2.17, FMA Horner) ────────────────────────────
static inline __m256 vec_ncdf_avx2(__m256 x) {
    const __m256 zero      = _mm256_setzero_ps();
    const __m256 one       = _mm256_set1_ps(1.0f);
    const __m256 sign_mask = _mm256_set1_ps(-0.0f);
    const __m256 neg_half  = _mm256_set1_ps(-0.5f);

    __m256 neg_mask = _mm256_cmp_ps(x, zero, _CMP_LT_OQ);
    __m256 ax       = _mm256_andnot_ps(sign_mask, x);   // abs(x)

    __m256 k = _mm256_div_ps(one,
                   _mm256_fmadd_ps(_mm256_set1_ps(NCDF_P), ax, one));

    // FMA Horner: poly = B5; poly = fmadd(poly, k, Bk)
    __m256 poly = _mm256_set1_ps(NCDF_B5);
    poly = _mm256_fmadd_ps(poly, k, _mm256_set1_ps(NCDF_B4));
    poly = _mm256_fmadd_ps(poly, k, _mm256_set1_ps(NCDF_B3));
    poly = _mm256_fmadd_ps(poly, k, _mm256_set1_ps(NCDF_B2));
    poly = _mm256_fmadd_ps(poly, k, _mm256_set1_ps(NCDF_B1));
    poly = _mm256_mul_ps(poly, k);

    __m256 ax2  = _mm256_mul_ps(ax, ax);
    __m256 nax  = vec_expf_avx2(_mm256_mul_ps(ax2, neg_half));
    nax         = _mm256_mul_ps(nax, _mm256_set1_ps(ONE_OVER_SQRT2PI));

    __m256 tail = _mm256_mul_ps(nax, poly);
    __m256 p    = _mm256_sub_ps(one, tail);
    return _mm256_blendv_ps(p, tail, neg_mask);
}

// ─── 8-wide Black-Scholes call price ─────────────────────────────────────────
static inline void price8(
    const float* S, const float* K,
    const float* T, const float* r, const float* sigma,
    float* C)
{
    __m256 vS   = _mm256_load_ps(S);
    __m256 vK   = _mm256_load_ps(K);
    __m256 vT   = _mm256_load_ps(T);
    __m256 vR   = _mm256_load_ps(r);
    __m256 vSig = _mm256_load_ps(sigma);

    __m256 sig2      = _mm256_mul_ps(vSig, vSig);
    __m256 sqrtT     = _mm256_sqrt_ps(vT);
    __m256 sig_sqrtT = _mm256_mul_ps(vSig, sqrtT);

    __m256 log_SK = vec_logf_avx2(_mm256_div_ps(vS, vK));
    __m256 half   = _mm256_set1_ps(0.5f);
    // d1_num = log(S/K) + (r + 0.5*sigma²)*T
    __m256 d1_num = _mm256_fmadd_ps(
        _mm256_fmadd_ps(half, sig2, vR),   // r + 0.5*sigma²
        vT, log_SK);                        // × T + log(S/K)
    __m256 d1 = _mm256_div_ps(d1_num, sig_sqrtT);
    __m256 d2 = _mm256_sub_ps(d1, sig_sqrtT);

    __m256 Nd1  = vec_ncdf_avx2(d1);
    __m256 Nd2  = vec_ncdf_avx2(d2);
    __m256 disc = vec_expf_avx2(_mm256_mul_ps(_mm256_set1_ps(-1.0f),
                                               _mm256_mul_ps(vR, vT)));

    // C = S*N(d1) - K*disc*N(d2)
    __m256 C_vec = _mm256_fnmadd_ps(
        _mm256_mul_ps(vK, disc), Nd2,
        _mm256_mul_ps(vS, Nd1));
    _mm256_store_ps(C, C_vec);
}

// ─── Entry point ─────────────────────────────────────────────────────────────
void price_options_avx2_fma(
    const float* __restrict__ S,
    const float* __restrict__ K,
    const float* __restrict__ T,
    const float* __restrict__ r,
    const float* __restrict__ sigma,
    float*       __restrict__ C,
    int64_t n)
{
    int64_t i = 0;
    for (; i + 7 < n; i += 8)
        price8(S+i, K+i, T+i, r+i, sigma+i, C+i);
    for (; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}
