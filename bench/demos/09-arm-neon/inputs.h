#pragma once
#include <cstdint>

// Populate spot, strike, time, rate, and vol arrays with N random inputs.
// Uses mt19937 seeded 0xCAFEBABE — both benchmark.cpp and verify.cpp must call
// this to guarantee they price the same set of options.
// Identical seed and ranges as demo 03 (direct cross-arch comparability).
// TODO(post-ship): extract to bench/common/bs_inputs.* shared with demo 03.
void gen_inputs(float* spot, float* strike, float* time,
                float* rate, float* vol, int64_t n);

// 1/√2 — used by scalar_libm.cpp and autovec.cpp for the N(x) = 0.5*erfc(-x/√2) form.
static constexpr float BS_SQRT1_2F = 0.70710678118654752f;
