// Demo 09 pilot bench — scalar polynomial vs hand-NEON Black-Scholes (AArch64).
// Answers scope §A go/no-go questions before the demo 9 implementation brief.
// Self-contained; no Google Benchmark.  Build and run on the Pi 5 rig only.
// See README.md for exact run lines.
//
// Usage: pilot_blackscholes [--variant {scalar|neon}] [--n N]
//   Default N = 1048576.

#include "poly_neon.h"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <string>

// ─── price_scalar ─────────────────────────────────────────────────────────────
// Scalar loop over bs_call_poly (poly.h): polynomial exp + ncdf, libm log/sqrt.
//
// __attribute__ guards against GCC autovectorising this on AArch64, where NEON
// is part of the base ISA and -O3 would silently widen the loop.  Without it
// the A2/A3 ratio measures autovec-vs-autovec rather than scalar-vs-hand-NEON.
// See scope §A5 and brief §4 (open item 1).
__attribute__((noinline, optimize("no-tree-vectorize")))
void price_scalar(
    const float* __restrict__ S, const float* __restrict__ K,
    const float* __restrict__ T, const float* __restrict__ r,
    const float* __restrict__ sigma, float* __restrict__ C, size_t n)
{
    for (size_t i = 0; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}

// ─── price_autovec ────────────────────────────────────────────────────────────
// Same scalar polynomial as price_scalar but WITHOUT the -fno-tree-vectorize
// guard.  At -O3 -mcpu=cortex-a76 GCC autovectorises this to NEON.
// Comparing its ns/op against price_neon answers scope §A3 (Framing A).
__attribute__((noinline))
void price_autovec(
    const float* __restrict__ S, const float* __restrict__ K,
    const float* __restrict__ T, const float* __restrict__ r,
    const float* __restrict__ sigma, float* __restrict__ C, size_t n)
{
    for (size_t i = 0; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}

// ─── price_neon ───────────────────────────────────────────────────────────────
// 4-wide hand-vectorised path.  vec_expf/logf/ncdf_neon (poly_neon.h) inline
// here.  Scalar tail handles n % 4 remainder via bs_call_poly.
__attribute__((noinline))
void price_neon(
    const float* __restrict__ S, const float* __restrict__ K,
    const float* __restrict__ T, const float* __restrict__ r,
    const float* __restrict__ sigma, float* __restrict__ C, size_t n)
{
    size_t i = 0;
    for (; i + 3 < n; i += 4) {
        float32x4_t vS   = vld1q_f32(S     + i);
        float32x4_t vK   = vld1q_f32(K     + i);
        float32x4_t vT   = vld1q_f32(T     + i);
        float32x4_t vR   = vld1q_f32(r     + i);
        float32x4_t vSig = vld1q_f32(sigma + i);

        float32x4_t sig2      = vmulq_f32(vSig, vSig);
        float32x4_t sqrtT     = vsqrtq_f32(vT);
        float32x4_t sig_sqrtT = vmulq_f32(vSig, sqrtT);

        // d1 = (log(S/K) + (r + 0.5*sig²)*T) / (sig*sqrt(T))
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

        vst1q_f32(C + i, vsubq_f32(
            vmulq_f32(vS, Nd1),
            vmulq_f32(vmulq_f32(vK, disc), Nd2)));
    }
    // Scalar tail for n % 4 remainder
    for (; i < n; ++i)
        C[i] = bs_call_poly(S[i], K[i], T[i], r[i], sigma[i]);
}

// ─── libm oracle ──────────────────────────────────────────────────────────────
// Reference implementation using std::exp / std::erfc from <cmath>.
// Used only by the correctness gate (256-sample pre-timing check).
static float bs_call_libm(float S, float K, float T, float r, float sigma) {
    float sig2      = sigma * sigma;
    float sqrtT     = std::sqrt(T);
    float sig_sqrtT = sigma * sqrtT;
    float d1 = (std::log(S / K) + (r + 0.5f * sig2) * T) / sig_sqrtT;
    float d2 = d1 - sig_sqrtT;
    auto nd = [](float x) -> float {
        // N(x) = 0.5 * erfc(-x / sqrt(2))
        return 0.5f * std::erfc(-x * 0.7071067811865476f);
    };
    return S * nd(d1) - K * std::exp(-r * T) * nd(d2);
}

int main(int argc, char* argv[]) {
    std::string variant = "scalar";
    size_t N = 1048576;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp(argv[i], "--variant") == 0 && i + 1 < argc)
            variant = argv[++i];
        else if (std::strcmp(argv[i], "--n") == 0 && i + 1 < argc)
            N = std::stoul(argv[++i]);
    }
    if (variant != "scalar" && variant != "neon" && variant != "autovec") {
        fprintf(stderr, "Usage: %s --variant {scalar|neon|autovec} [--n N]\n", argv[0]);
        return 1;
    }

    // FTZ must be set before any pricing — scope §A5
    set_ftz();

    // 16-byte aligned allocations (NEON 128-bit vld1q_f32 reads 4×float)
    auto alloc16 = [](size_t n) -> float* {
        void* p = nullptr;
        if (posix_memalign(&p, 16, n * sizeof(float)) != 0) {
            fprintf(stderr, "posix_memalign failed\n");
            std::exit(1);
        }
        return static_cast<float*>(p);
    };

    float* S   = alloc16(N);
    float* K   = alloc16(N);
    float* T   = alloc16(N);
    float* r   = alloc16(N);
    float* sig = alloc16(N);
    float* C   = alloc16(N);

    // Input generation — identical seed and ranges as demo 3
    {
        std::mt19937 rng(0xCAFEBABE);
        std::uniform_real_distribution<float> dS  (50.0f, 150.0f);
        std::uniform_real_distribution<float> dK  (50.0f, 150.0f);
        std::uniform_real_distribution<float> dT  (0.05f,  2.0f );
        std::uniform_real_distribution<float> dR  (0.0f,   0.08f);
        std::uniform_real_distribution<float> dSig(0.1f,   0.6f );
        for (size_t i = 0; i < N; ++i) {
            S  [i] = dS  (rng);
            K  [i] = dK  (rng);
            T  [i] = dT  (rng);
            r  [i] = dR  (rng);
            sig[i] = dSig(rng);
        }
    }

    // ── Correctness gate ──────────────────────────────────────────────────────
    // Price a small sample against the libm oracle before trusting any timing.
    // Abort if max_abs_error >= 1e-4 — same bar as demo 3.
    {
        static constexpr size_t ORACLE_N = 256;
        float oracle[ORACLE_N];
        for (size_t i = 0; i < ORACLE_N; ++i)
            oracle[i] = bs_call_libm(S[i], K[i], T[i], r[i], sig[i]);

        if (variant == "scalar")
            price_scalar  (S, K, T, r, sig, C, ORACLE_N);
        else if (variant == "autovec")
            price_autovec (S, K, T, r, sig, C, ORACLE_N);
        else
            price_neon    (S, K, T, r, sig, C, ORACLE_N);

        float max_err = 0.0f;
        for (size_t i = 0; i < ORACLE_N; ++i) {
            float e = std::fabs(C[i] - oracle[i]);
            if (e > max_err) max_err = e;
        }
        if (max_err >= 1e-4f) {
            fprintf(stderr,
                    "CORRECTNESS FAIL variant=%s max_abs_error=%.3e >= 1e-4\n",
                    variant.c_str(), static_cast<double>(max_err));
            return 1;
        }
        printf("correctness OK: max_abs_error=%.3e (threshold 1e-4)\n",
               static_cast<double>(max_err));
    }

    // ── Timing: 5 runs, report each + median ──────────────────────────────────
    printf("variant=%s  N=%zu\n", variant.c_str(), N);
    double run_ns[5];
    for (int run = 0; run < 5; ++run) {
        auto t0 = std::chrono::steady_clock::now();
        if (variant == "scalar")
            price_scalar  (S, K, T, r, sig, C, N);
        else if (variant == "autovec")
            price_autovec (S, K, T, r, sig, C, N);
        else
            price_neon    (S, K, T, r, sig, C, N);
        auto t1 = std::chrono::steady_clock::now();

        // Volatile sink — prevents the compiler eliminating the output array
        volatile float sink = 0.0f;
        for (size_t j = 0; j < N; j += (N >> 4) + 1) sink += C[j];
        (void)sink;

        double ns    = std::chrono::duration<double, std::nano>(t1 - t0).count();
        double ns_op = ns / static_cast<double>(N);
        run_ns[run]  = ns_op;
        printf("run %d: %8.3f ns/op  %10.3e ops/sec\n",
               run + 1, ns_op, static_cast<double>(N) / (ns * 1e-9));
    }

    double sorted[5];
    std::copy(run_ns, run_ns + 5, sorted);
    std::sort(sorted, sorted + 5);
    double median = sorted[2];
    printf("median:  %8.3f ns/op  %10.3e ops/sec\n",
           median, 1e9 / median);

    free(S); free(K); free(T); free(r); free(sig); free(C);
    return 0;
}
