#pragma once
// ARM NEON polynomial kernels for demo 09 (AArch64 / Cortex-A76).
//
// Polynomial coefficients come from demo 03's poly.h — the same definition
// used by scalar_poly.cpp and neon_intrinsics.cpp so the speedup measures
// lane width, not different math.
//
// Open item (§4): demo 03's poly.h is included directly here rather than
// promoted to bench/common/poly.h.  That is a cross-demo decision deferred
// per the brief.  Do not silently fork a third copy.
//
// Exports (all static inline, intended to be inlined into neon_intrinsics.cpp):
//   vec_expf_neon()     — 4-wide fast_expf
//   vec_logf_neon()     — 4-wide fast_logf (Cephes LOG_P coefficients)
//   vec_ncdf_neon()     — 4-wide ncdf_poly (A&S §26.2.17)

#include "../03-simd-blackscholes/poly.h"
#include <arm_neon.h>

// ─── 4-wide fast_expf (NEON) ──────────────────────────────────────────────────
// Width-port of scalar fast_expf from poly.h.  Same EXP_C* Taylor coefficients.
// vrndnq_f32 (round-to-nearest-even) matches the semantics of SSE2 _mm_round_ps.
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
// Uses hardware vdivq_f32 (fdiv instruction) — no reciprocal approximation.
static inline float32x4_t vec_logf_neon(float32x4_t x) {
    int32x4_t  xi = vreinterpretq_s32_f32(x);
    int32x4_t  ei = vsubq_s32(vshrq_n_s32(xi, 23), vdupq_n_s32(127));
    int32x4_t  mi = vorrq_s32(vandq_s32(xi, vdupq_n_s32(0x007FFFFF)),
                               vdupq_n_s32(0x3F800000));
    float32x4_t m = vreinterpretq_f32_s32(mi);
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

// ─── 4-wide ncdf_poly (NEON, A&S §26.2.17 NCDF_* coefficients) ───────────────
// Width-port of scalar ncdf_poly from poly.h.  Uses hardware vdivq_f32.
// Branchless edge handling: vbslq_f32 selects tail vs cdf based on sign of x.
static inline float32x4_t vec_ncdf_neon(float32x4_t x) {
    uint32x4_t  neg  = vcltq_f32(x, vdupq_n_f32(0.0f));
    float32x4_t ax   = vabsq_f32(x);
    // k = 1 / (1 + NCDF_P * |x|)
    float32x4_t k    = vdivq_f32(vdupq_n_f32(1.0f),
                           vfmaq_f32(vdupq_n_f32(1.0f), vdupq_n_f32(NCDF_P), ax));
    // Horner: B5 → ×k+B4 → ×k+B3 → ×k+B2 → ×k+B1 → ×k
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
    float32x4_t tail = vmulq_f32(nax, poly);                    // 1 - N(|x|)
    float32x4_t cdf  = vsubq_f32(vdupq_n_f32(1.0f), tail);     // N(|x|)
    return vbslq_f32(neg, tail, cdf);
}
