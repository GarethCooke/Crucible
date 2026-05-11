#pragma once
// Shared polynomial coefficients and scalar inline implementations.
// Used by scalar_poly.cpp, sse2_intrinsics.cpp, avx2_fma_intrinsics.cpp.
// scalar_libm.cpp does NOT include this — it uses <cmath> directly.
//
// ─── Flop count per Black-Scholes call price ─────────────────────────────────
//
//  fast_expf (6th-order Taylor on [-ln2/2, ln2/2]):
//    1 mul (scale to log2)  + 2 (range reduce)  + 6×2 (Horner) + 1 mul (2^n)
//    = 16 flops
//
//  ncdf_poly (A&S §26.2.17, 5-term rational):
//    2 (1+P*x)  + 1 div  + 4×2+1 (Horner 5-term × k)  + 2 (ax²)
//    + 16 (fast_expf)  + 1 (* 1/√2π)  + 1 (n_ax × poly)  + 1 sub
//    = 33 flops
//
//  bs_call_scalar (scalar_poly variant, using libm log/sqrt as 1 flop each):
//    1 (σ²) + 1 (√T) + 1 (σ√T) + 1 (S/K) + 1 (log) + 1 (½σ²)
//    + 1 (r+½σ²) + 1 (*T) + 1 (+log) + 1 (/σ√T) + 1 (d2=d1-σ√T)
//    + 33 (ncdf d1) + 33 (ncdf d2)
//    + 1 (-r*T) + 16 (fast_expf) + 1 (K*disc) + 1 (S*Nd1) + 1 (K*disc*Nd2)
//    + 1 (subtract) = 98 flops
//
//  SIMD variants replace libm log(S/K) with fast_logf (~29 flops, Cephes §4),
//  giving ~125 flops per option.
//
//  GFLOP formula used by assemble_results_03.py:
//    scalar variants:  98 flops × ops_per_sec / 1e9
//    SIMD variants:   125 flops × ops_per_sec / 1e9
// ─────────────────────────────────────────────────────────────────────────────

#include <cmath>
#include <cstring>  // memcpy

// ─── exp polynomial constants ─────────────────────────────────────────────────
// fast_expf: exp(x) via range reduction x = n*ln2 + r, |r| <= ln2/2,
//   then 6th-order Taylor exp(r) ≈ C0 + r*(C1 + r*(C2 + ... + r*C6))
// Source: Taylor series 1/k! for k=0..6.
// Max absolute error over full float domain (after clamping): ~1.7e-7

static constexpr float EXP_LOG2E = 1.44269504088896341f; // log2(e)
static constexpr float EXP_LN2   = 0.69314718055994531f; // ln(2)

static constexpr float EXP_C0 = 1.00000000000000000e+00f; // 1/0!
static constexpr float EXP_C1 = 1.00000000000000000e+00f; // 1/1!
static constexpr float EXP_C2 = 5.00000000000000000e-01f; // 1/2!
static constexpr float EXP_C3 = 1.66666666666666657e-01f; // 1/3!
static constexpr float EXP_C4 = 4.16666666666666644e-02f; // 1/4!
static constexpr float EXP_C5 = 8.33333333333333322e-03f; // 1/5!
static constexpr float EXP_C6 = 1.38888888888888894e-03f; // 1/6!

// ─── N(x) (standard normal CDF) polynomial constants ─────────────────────────
// A&S §26.2.17, Table 26.2 (Abramowitz & Stegun, 1964).
// For x >= 0: 1 - N(x) ≈ n(x) × k × poly(k), where k = 1/(1+P*x), n(x)=exp(-x²/2)/√(2π)
// Max |error| < 7.5e-8 (published bound for the rational form).
// Source: Abramowitz, M.; Stegun, I.A. (1964). Handbook of Mathematical Functions.
//         Dover, §26.2.17, p.932.

static constexpr float NCDF_P  =  2.316419e-01f;
static constexpr float NCDF_B1 =  3.193815302e-01f;
static constexpr float NCDF_B2 = -3.565638279e-01f;
static constexpr float NCDF_B3 =  1.781477937e+00f;
static constexpr float NCDF_B4 = -1.821255978e+00f;
static constexpr float NCDF_B5 =  1.330274429e+00f;

static constexpr float ONE_OVER_SQRT2PI = 3.98942280401432678e-01f; // 1/√(2π)

// ─── log polynomial constants ─────────────────────────────────────────────────
// Cephes logf.c: 9-coefficient minimax polynomial for log(1+f), f ∈ [-0.293, 0.414).
// Theoretical peak relative error: 2.1e-7 (near-single-precision accurate).
// Source: Moshier, S.L. (1984-2000). Cephes Mathematical Library. BSD license.
//         http://www.netlib.org/cephes/
// Used by fast_logf (scalar) and the vectorised log in SSE/AVX2 TUs.

static constexpr float LOG_SQRT2 = 1.41421356237309514f; // √2 threshold for range reduction

static constexpr float LOG_P[9] = {
     7.0376836292e-02f,
    -1.1514610310e-01f,
     1.1676998740e-01f,
    -1.2420140846e-01f,
     1.4249322787e-01f,
    -1.6668057665e-01f,
     2.0000714765e-01f,
    -2.4999993993e-01f,
     3.3333331174e-01f,
};

// ─── Scalar inline helpers ────────────────────────────────────────────────────

inline float fast_expf(float x) {
    // Clamp to avoid overflow/underflow (exp(-88) is subnormal; FTZ handles it).
    x = x < -88.0f ? -88.0f : (x > 88.0f ? 88.0f : x);
    float z = x * EXP_LOG2E;
    // Round to nearest integer (no FP rounding mode dependency).
    float n = static_cast<float>(static_cast<int>(z + (z >= 0.0f ? 0.5f : -0.5f)));
    float r = x - n * EXP_LN2;
    // 6-stage Horner: exp(r) ≈ C0 + r*(C1 + r*(C2 + ... + r*C6))
    float p = EXP_C6;
    p = p * r + EXP_C5;
    p = p * r + EXP_C4;
    p = p * r + EXP_C3;
    p = p * r + EXP_C2;
    p = p * r + EXP_C1;
    p = p * r + EXP_C0;
    // Scale by 2^n via float exponent field.
    int ni = static_cast<int>(n) + 127;
    int exp_bits = ni << 23;
    float scale;
    __builtin_memcpy(&scale, &exp_bits, sizeof(float));
    return p * scale;
}

inline float ncdf_poly(float x) {
    bool neg = (x < 0.0f);
    float ax = neg ? -x : x;
    float k = 1.0f / (1.0f + NCDF_P * ax);
    // Horner: k*(B1 + k*(B2 + k*(B3 + k*(B4 + k*B5))))
    float poly = NCDF_B5;
    poly = poly * k + NCDF_B4;
    poly = poly * k + NCDF_B3;
    poly = poly * k + NCDF_B2;
    poly = poly * k + NCDF_B1;
    poly = poly * k;
    float n_ax = fast_expf(-0.5f * ax * ax) * ONE_OVER_SQRT2PI;
    float tail = n_ax * poly;    // 1 - N(ax)
    float p    = 1.0f - tail;    // N(ax)
    return neg ? tail : p;
}

// fast_logf: Cephes polynomial, ~2.1e-7 peak relative error.
// Used by SIMD variant scalar fallback paths and verify.cpp.
// scalar_poly.cpp uses std::log directly (see brief §variants/2).
inline float fast_logf(float x) {
    int xi;
    __builtin_memcpy(&xi, &x, sizeof(float));
    int ei = ((xi >> 23) & 0xFF) - 127;
    int mi_bits = (xi & 0x007FFFFF) | 0x3F800000;
    float m;
    __builtin_memcpy(&m, &mi_bits, sizeof(float));
    if (m >= LOG_SQRT2) { m *= 0.5f; ++ei; }
    float f = m - 1.0f;
    // 8-stage Horner for LOG_P[0]*f^8 + ... + LOG_P[8]:
    float p = LOG_P[0];
    p = p * f + LOG_P[1];
    p = p * f + LOG_P[2];
    p = p * f + LOG_P[3];
    p = p * f + LOG_P[4];
    p = p * f + LOG_P[5];
    p = p * f + LOG_P[6];
    p = p * f + LOG_P[7];
    p = p * f + LOG_P[8];
    float z = f * f;
    // log(1+f) = f³*P_eval - f²/2 + f + e*ln2
    return f * (z * p) - 0.5f * z + f + static_cast<float>(ei) * EXP_LN2;
}

// Full scalar Black-Scholes call price using fast_expf + ncdf_poly + std::log + std::sqrt.
// This is the implementation used by scalar_poly.cpp.
inline float bs_call_poly(float S, float K, float T, float r, float sigma) {
    float sig2      = sigma * sigma;
    float sqrtT     = std::sqrt(T);
    float sig_sqrtT = sigma * sqrtT;
    float d1 = (std::log(S / K) + (r + 0.5f * sig2) * T) / sig_sqrtT;
    float d2 = d1 - sig_sqrtT;
    return S * ncdf_poly(d1) - K * fast_expf(-r * T) * ncdf_poly(d2);
}
