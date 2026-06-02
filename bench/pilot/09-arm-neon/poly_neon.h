#pragma once
// ARM NEON polynomial kernels — demo 09 pilot bench (AArch64 / Cortex-A76).
//
// Polynomial coefficients are sourced from demo 3's poly.h — a single shared
// definition referenced by both scalar and NEON paths (A3 fairness requirement:
// the speedup measures width, not different math).
//
// Exports:
//   set_ftz()           — set FPCR FZ bit before any pricing
//   vec_expf_neon()     — 4-wide fast_expf (inlined into price_neon)
//   vec_logf_neon()     — 4-wide fast_logf (inlined into price_neon)
//   vec_ncdf_neon()     — 4-wide ncdf_poly  (inlined into price_neon)
//
// Entry-point declarations (defined in pilot_blackscholes.cpp):
//   price_scalar()      — scalar polynomial loop, A2/A3 baseline
//   price_neon()        — hand-vectorised 4-wide NEON, A2/A3 candidate

#include "../../demos/03-simd-blackscholes/poly.h"  // EXP_*, NCDF_*, LOG_P, bs_call_poly
#include <arm_neon.h>
#include <cstddef>
#include <cstdint>
#include <cstdio>

// ─── FPCR flush-to-zero ───────────────────────────────────────────────────────
// AArch64 FPCR bit 24 (FZ): flushes both input and output denormals to zero.
// ARM equivalent of x86 _MM_SET_FLUSH_ZERO_MODE.  Without it, deep-OTM
// Black-Scholes tails produce subnormals that contaminate timing (scope §A5).
inline void set_ftz() {
    uint64_t fpcr;
    __asm__ volatile("mrs %0, fpcr" : "=r"(fpcr));
    fpcr |= (1ULL << 24);
    __asm__ volatile("msr fpcr, %0" :: "r"(fpcr));
    uint64_t check;
    __asm__ volatile("mrs %0, fpcr" : "=r"(check));
    printf("FPCR FZ bit: %s (fpcr=0x%016llx)\n",
           ((check >> 24) & 1u) ? "SET" : "NOT SET",
           (unsigned long long)check);
}

// ─── 4-wide fast_expf (NEON) ──────────────────────────────────────────────────
// Width-port of scalar fast_expf from poly.h.  Same EXP_C* coefficients.
// vrndnq_f32 (round-to-nearest-even) matches the SSE2 _mm_round_ps semantics.
static inline float32x4_t vec_expf_neon(float32x4_t x) {
    x = vmaxq_f32(x, vdupq_n_f32(-88.0f));
    x = vminq_f32(x, vdupq_n_f32( 88.0f));
    float32x4_t z = vmulq_f32(x, vdupq_n_f32(EXP_LOG2E));
    float32x4_t n = vrndnq_f32(z);
    float32x4_t r = vsubq_f32(x, vmulq_f32(n, vdupq_n_f32(EXP_LN2)));
    // 6-stage Horner: C0 + r*(C1 + r*(C2 + ... + r*C6))
    float32x4_t p = vdupq_n_f32(EXP_C6);
    p = vfmaq_f32(vdupq_n_f32(EXP_C5), p, r);
    p = vfmaq_f32(vdupq_n_f32(EXP_C4), p, r);
    p = vfmaq_f32(vdupq_n_f32(EXP_C3), p, r);
    p = vfmaq_f32(vdupq_n_f32(EXP_C2), p, r);
    p = vfmaq_f32(vdupq_n_f32(EXP_C1), p, r);
    p = vfmaq_f32(vdupq_n_f32(EXP_C0), p, r);
    // Scale by 2^n via float exponent field
    int32x4_t ni = vcvtq_s32_f32(n);
    ni = vaddq_s32(ni, vdupq_n_s32(127));
    ni = vshlq_n_s32(ni, 23);
    return vmulq_f32(p, vreinterpretq_f32_s32(ni));
}

// ─── 4-wide fast_logf (NEON, Cephes LOG_P coefficients) ──────────────────────
// Width-port of scalar fast_logf from poly.h.  Same LOG_P[0..8] coefficients.
// Uses hardware vdivq_f32 (fdiv instruction) for full-precision reciprocal.
static inline float32x4_t vec_logf_neon(float32x4_t x) {
    int32x4_t  xi  = vreinterpretq_s32_f32(x);
    int32x4_t  ei  = vsubq_s32(vshrq_n_s32(xi, 23), vdupq_n_s32(127));
    int32x4_t  mi  = vorrq_s32(vandq_s32(xi, vdupq_n_s32(0x007FFFFF)),
                                vdupq_n_s32(0x3F800000));
    float32x4_t m  = vreinterpretq_f32_s32(mi);
    // If m >= sqrt(2): m /= 2, ei++
    uint32x4_t adj = vcgeq_f32(m, vdupq_n_f32(LOG_SQRT2));
    m  = vbslq_f32(adj, vmulq_f32(m, vdupq_n_f32(0.5f)), m);
    ei = vaddq_s32(ei, vreinterpretq_s32_u32(vandq_u32(adj, vdupq_n_u32(1u))));
    float32x4_t f = vsubq_f32(m, vdupq_n_f32(1.0f));
    // 8-stage Horner: LOG_P[0]*f^8 + ... + LOG_P[8]
    float32x4_t p = vdupq_n_f32(LOG_P[0]);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[1]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[2]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[3]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[4]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[5]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[6]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[7]), p, f);
    p = vfmaq_f32(vdupq_n_f32(LOG_P[8]), p, f);
    float32x4_t z   = vmulq_f32(f, f);
    float32x4_t e_f = vcvtq_f32_s32(ei);
    // log(1+f) = f³*p - f²/2 + f + e*ln2
    float32x4_t res = vmulq_f32(vmulq_f32(f, z), p);
    res = vsubq_f32(res, vmulq_f32(vdupq_n_f32(0.5f), z));
    res = vaddq_f32(res, f);
    res = vfmaq_f32(res, e_f, vdupq_n_f32(EXP_LN2));
    return res;
}

// ─── Scalar twin of the NEON kernel (for scalar_poly variant) ────────────────
// Mirrors the NEON body one-to-one: fast_logf/fast_expf/ncdf_poly, __builtin_sqrtf.
// Width-isolating baseline: scalar_poly → neon ratio reflects lane count only.
// __builtin_sqrtf emits fsqrt on AArch64 unconditionally — no logf/sqrtf@plt.
static inline float bs_call_scalar_poly(float S, float K, float T, float r, float sigma) {
    float sig2      = sigma * sigma;
    // vsqrt_f32 emits fsqrt unconditionally (no sqrtf@plt for negative inputs).
    // __builtin_sqrtf branches to sqrtf@plt for T < 0 to preserve errno, same
    // as std::sqrt.  NEON vsqrtq_f32 returns NaN for T < 0 with no PLT call;
    // this scalar twin matches that behaviour via the 2s lane form.
    float sqrtT     = vget_lane_f32(vsqrt_f32(vdup_n_f32(T)), 0);
    float sig_sqrtT = sigma * sqrtT;
    float d1 = (fast_logf(S / K) + (r + 0.5f * sig2) * T) / sig_sqrtT;
    float d2 = d1 - sig_sqrtT;
    return S * ncdf_poly(d1) - K * fast_expf(-r * T) * ncdf_poly(d2);
}

// ─── 4-wide ncdf_poly (NEON, A&S §26.2.17 NCDF_* coefficients) ───────────────
// Width-port of scalar ncdf_poly from poly.h.  Uses hardware vdivq_f32.
static inline float32x4_t vec_ncdf_neon(float32x4_t x) {
    uint32x4_t  neg  = vcltq_f32(x, vdupq_n_f32(0.0f));
    float32x4_t ax   = vabsq_f32(x);
    // k = 1 / (1 + NCDF_P * |x|)
    float32x4_t k    = vdivq_f32(vdupq_n_f32(1.0f),
                           vfmaq_f32(vdupq_n_f32(1.0f), vdupq_n_f32(NCDF_P), ax));
    // Horner: B5 → ×k+B4 → ... → ×k
    float32x4_t poly = vdupq_n_f32(NCDF_B5);
    poly = vfmaq_f32(vdupq_n_f32(NCDF_B4), poly, k);
    poly = vfmaq_f32(vdupq_n_f32(NCDF_B3), poly, k);
    poly = vfmaq_f32(vdupq_n_f32(NCDF_B2), poly, k);
    poly = vfmaq_f32(vdupq_n_f32(NCDF_B1), poly, k);
    poly = vmulq_f32(poly, k);
    // n(ax) = exp(-0.5*ax²) / sqrt(2π)
    float32x4_t nax  = vmulq_f32(
                           vec_expf_neon(vmulq_f32(vdupq_n_f32(-0.5f), vmulq_f32(ax, ax))),
                           vdupq_n_f32(ONE_OVER_SQRT2PI));
    float32x4_t tail = vmulq_f32(nax, poly);           // 1 - N(|x|)
    float32x4_t cdf  = vsubq_f32(vdupq_n_f32(1.0f), tail);  // N(|x|)
    return vbslq_f32(neg, tail, cdf);
}
