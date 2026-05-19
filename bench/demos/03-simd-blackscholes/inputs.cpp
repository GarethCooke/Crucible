#include "inputs.h"

#include <cstdint>
#include <random>

void gen_inputs(float* spot, float* strike, float* time,
                float* rate, float* vol, int64_t n) {
    std::mt19937 rng(0xCAFEBABE);
    std::uniform_real_distribution<float> dS  (50.0f, 150.0f);
    std::uniform_real_distribution<float> dK  (50.0f, 150.0f);
    std::uniform_real_distribution<float> dT  (0.05f, 2.0f  );
    std::uniform_real_distribution<float> dR  (0.0f,  0.08f );
    std::uniform_real_distribution<float> dSig(0.1f,  0.6f  );
    for (int64_t i = 0; i < n; ++i) {
        spot  [i] = dS  (rng);
        strike[i] = dK  (rng);
        time  [i] = dT  (rng);
        rate  [i] = dR  (rng);
        vol   [i] = dSig(rng);
    }
}
