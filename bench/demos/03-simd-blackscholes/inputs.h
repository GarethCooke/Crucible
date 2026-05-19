#pragma once
#include <cstdint>

// Populate spot, strike, time, rate, and vol arrays with N random inputs.
// Uses mt19937 seeded 0xCAFEBABE — both benchmark.cpp and verify.cpp must call
// this to guarantee they price the same set of options.
void gen_inputs(float* spot, float* strike, float* time,
                float* rate, float* vol, int64_t n);
