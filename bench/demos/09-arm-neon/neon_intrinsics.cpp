// Variant 4: neon_intrinsics — 4-wide hand-written AArch64 NEON.
// Uses float32x4_t and ARM intrinsics from <arm_neon.h>.
// All transcendentals are inline polynomial approximations (no PLT calls in
// the main vector loop): vec_logf_neon, vec_expf_neon, vec_ncdf_neon.
// vsqrtq_f32 maps to the hardware fsqrt instruction.
// Compiled with: -O3 -mcpu=cortex-a76
//
// Scalar tail (n % 4 remainder) uses bs_call_poly from poly.h — logf@plt is
// permissible there since the main loop processes ≥4 elements at a time.
// Acceptance: .4s ops present, no bl ...@plt in the main vector loop,
//             4-element stride, max_abs_error < 1e-4.

#include "poly_neon.h"  // vec_expf_neon, vec_logf_neon, vec_ncdf_neon

#include <cstdint>

// ─── 4-wide Black-Scholes call price ─────────────────────────────────────────
static inline void price4(
    const float* __restrict__ S, const float* __restrict__ K,
    const float* __restrict__ T, const float* __restrict__ r,
    const float* __restrict__ sigma, float* __restrict__ C)
{
    float32x4_t vS   = vld1q_f32(S);
    float32x4_t vK   = vld1q_f32(K);
    float32x4_t vT   = vld1q_f32(T);
    float32x4_t vR   = vld1q_f32(r);
    float32x4_t vSig = vld1q_f32(sigma);

    float32x4_t sig2      = vmulq_f32(vSig, vSig);
    float32x4_t sqrtT     = vsqrtq_f32(vT);
    float32x4_t sig_sqrtT = vmulq_f32(vSig, sqrtT);

    // d1 = (log(S/K) + (r + 0.5*σ²)*T) / (σ*√T)
    float32x4_t log_SK = vec_logf_neon(vdivq_f32(vS, vK));
    float32x4_t d1_num = vfmaq_f32(log_SK,
                             vfmaq_f32(vR, vdupq_n_f32(0.5f), sig2),
                             vT);
    float32x4_t d1 = vdivq_f32(d1_num, sig_sqrtT);
    float32x4_t d2 = vsubq_f32(d1, sig_sqrtT);

    float32x4_t Nd1  = vec_ncdf_neon(d1);
    float32x4_t Nd2  = vec_ncdf_neon(d2);
    // discount = exp(-r*T)
    float32x4_t disc = vec_expf_neon(vnegq_f32(vmulq_f32(vR, vT)));

    vst1q_f32(C, vsubq_f32(
        vmulq_f32(vS, Nd1),
        vmulq_f32(vmulq_f32(vK, disc), Nd2)));
}

// ─── Entry point ─────────────────────────────────────────────────────────────
void price_options_neon(
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
    // Scalar tail for n % 4 remainder — uses libm log (acceptable outside main loop).
    for (; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}
