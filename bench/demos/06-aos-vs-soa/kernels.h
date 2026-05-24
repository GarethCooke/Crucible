#pragma once
#include "record.h"

// ─── Scan kernels ─────────────────────────────────────────────────────────────
// All three kernels are marked noinline so they appear as named symbols in the
// binary for --verify-codegen (objdump -d) checks.
//
// Access pattern: sequential, contiguous-prefix — the kernel sums fields
// f0 .. f(K-1) for all N records. Strided or random patterns would tell a
// different story and are out of scope for this demo.
//
// K is a runtime parameter. The inner K-loop is short and typically unrolled by
// the compiler; calibration confirmed negligible overhead vs template-specialised
// versions (well within noise). If a future regression shows otherwise, switch to
// template specialisation and re-verify codegen.

// ─── AoS scalar ──────────────────────────────────────────────────────────────
// Strided 128 B access defeats auto-vectorisation; no pragma needed.
__attribute__((noinline))
double scan_aos(const RecordAoS* records, size_t n, int k) {
    double sum = 0.0;
    for (size_t i = 0; i < n; ++i) {
        const double* fields = &records[i].f0;
        for (int j = 0; j < k; ++j)
            sum += fields[j];
    }
    return sum;
}

// ─── SoA scalar ──────────────────────────────────────────────────────────────
// Vectorisation explicitly disabled to isolate the bandwidth advantage of SoA
// from the SIMD advantage. The attribute applies at function scope only; the
// rest of the TU still vectorises normally.
__attribute__((noinline, optimize("no-tree-vectorize")))
double scan_soa_scalar(const RecordSoA& s, size_t n, int k) {
    double sum = 0.0;
    const double* cols[16] = {
        s.f0.data,  s.f1.data,  s.f2.data,  s.f3.data,
        s.f4.data,  s.f5.data,  s.f6.data,  s.f7.data,
        s.f8.data,  s.f9.data,  s.f10.data, s.f11.data,
        s.f12.data, s.f13.data, s.f14.data, s.f15.data,
    };
    for (int j = 0; j < k; ++j) {
        const double* col = cols[j];
        for (size_t i = 0; i < n; ++i)
            sum += col[i];
    }
    return sum;
}

// ─── SoA auto-vectorised ──────────────────────────────────────────────────────
// fast-math is required: GCC won't reorder FP ops to vectorize a reduction
// without -fassociative-math. The attribute applies to this function only.
// Emits AVX2 vaddpd ymm over the column inner loop, stacking SIMD throughput
// on top of the bandwidth advantage of SoA layout.
__attribute__((noinline, optimize("O3,fast-math")))
double scan_soa_autovec(const RecordSoA& s, size_t n, int k) {
    double sum = 0.0;
    const double* cols[16] = {
        s.f0.data,  s.f1.data,  s.f2.data,  s.f3.data,
        s.f4.data,  s.f5.data,  s.f6.data,  s.f7.data,
        s.f8.data,  s.f9.data,  s.f10.data, s.f11.data,
        s.f12.data, s.f13.data, s.f14.data, s.f15.data,
    };
    for (int j = 0; j < k; ++j) {
        const double* col = cols[j];
        for (size_t i = 0; i < n; ++i)
            sum += col[i];
    }
    return sum;
}
