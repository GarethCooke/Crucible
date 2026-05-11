# Demo 03 — SIMD: scalar vs SSE vs AVX2+FMA (Black-Scholes call pricing)

European call option pricing under Black-Scholes across four implementations,
measuring how much speedup comes from the algorithm (polynomial vs libm) and
how much comes from SIMD width (4-wide SSE → 8-wide AVX2).

## Variants

| # | Name | ISA flags | Transcendentals |
|---|------|-----------|-----------------|
| 1 | `scalar_libm` | `-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2` | `std::exp`, `std::log`, `std::sqrt`, `std::erfc` |
| 2 | `scalar_poly` | `-O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2` | `fast_expf`, `ncdf_poly` (poly.h); `std::log`, `std::sqrt` |
| 3 | `sse2_intrinsics` | `-O3 -msse4.2 -mno-avx -mno-avx2 -mno-fma` | 4-wide SSE poly (all; log via Cephes) |
| 4 | `avx2_fma_intrinsics` | `-O3 -mavx -mavx2 -mfma` | 8-wide AVX2+FMA poly (all; log via Cephes) |

All compile-time flags override the root `-march=native` via CMake per-TU
options. The scalar and SSE variants explicitly disable AVX/AVX2 to prevent
the compiler from upgrading their ISA baseline.

## Polynomial sources

- **exp**: 6th-order Taylor series on `[-ln2/2, ln2/2]`, bit-trick 2^n scaling.
  Max absolute error ≈ 1.7e-7.
- **N(x)**: Abramowitz & Stegun §26.2.17 (Table 26.2), 5-term rational.
  Max |error| < 7.5e-8 (published bound).
- **log**: Cephes `logf.c` 9-coefficient minimax polynomial, range-reduced to
  `f ∈ [-0.293, 0.414)`. Theoretical peak relative error ≈ 2.1e-7.

## Zen 2 µop-split prediction

Zen 2 (AMD Ryzen 3800X) implements 256-bit AVX2 by splitting each instruction
into two 128-bit µops. A 256-bit FMA dispatch takes two integer cycles, whereas
Zen 3 and later dispatch it in one. Prediction: **AVX2 beats SSE on this
machine, but by less than 2×** — the 8-wide register width provides a real
gain, but the µop-split halves the theoretical throughput advantage.

This is a falsifiable prediction: if the AVX2/SSE ratio on the benchmark output
exceeds 2.0, the memory bandwidth has become the dominant bottleneck (not
compute), which is expected at N = 1M (20 MB input, larger than L3).

## Correctness

`max_abs_error_vs_scalar_libm` < 1e-4 for all non-libm variants.
The `verify_03_simd_blackscholes` binary checks this over 1M inputs and exits
non-zero on failure — run_one.sh invokes it before benchmarking.

## Hardware notes

- **FTZ + DAZ** are set at benchmark start. Deep out-of-the-money options
  produce subnormals from `exp(-large_d²/2)`; without FTZ these cost 50+ cycles
  on Zen 2 and dominate the timing.
- **Alignment**: all input/output arrays are `alignas(32)`; harness aborts
  if this is violated at runtime.
- **N = 16k** (320 KB) fits in L2 per core on Zen 2 → compute-bound reading.
  **N = 1M** (20 MB) spills to L3/DRAM → also tests memory-bandwidth path.

## Files

```
poly.h                 Shared coefficients + scalar fast_expf, ncdf_poly, bs_call_poly
benchmark.cpp          Google Benchmark main: input gen, error check, registration
scalar_libm.cpp        Variant 1
scalar_poly.cpp        Variant 2
sse2_intrinsics.cpp    Variant 3
avx2_fma_intrinsics.cpp Variant 4
verify.cpp             Standalone correctness checker (separate binary)
CMakeLists.txt         Per-TU ISA flags via OBJECT libraries
asm/                   Committed disassembly dumps (generated post-build)
```
