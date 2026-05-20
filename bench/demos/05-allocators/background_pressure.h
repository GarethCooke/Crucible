#pragma once
// Background heap pressure thread (T_bg).
// Simulates other subsystems sharing the heap with mixed-size malloc/free churn.
// target_rate_hz == 0 means T_bg is NOT spawned at all (no-pressure baseline).

#include <atomic>
#include <cstddef>
#include <cstdlib>
#include <random>
#include <vector>

#include <x86intrin.h>

static constexpr size_t BG_SIZE_CLASSES[] = {32, 64, 128, 256, 512, 1024};
static constexpr size_t BG_NUM_CLASSES = sizeof(BG_SIZE_CLASSES) / sizeof(BG_SIZE_CLASSES[0]);

// Convert a nanosecond interval to TSC cycles using ns_per_cycle.
inline uint64_t ns_to_cycles(uint64_t ns, double ns_per_cycle) noexcept {
    return static_cast<uint64_t>(static_cast<double>(ns) / ns_per_cycle);
}

// Main loop for T_bg. Pinned to BG_CORE by the caller before entry.
// Pre-fills 512 live allocations to create fragmentation pressure from t=0.
// Allocates and frees at target_rate_hz using the same TSC pacing as the producer.
inline void background_pressure_loop(uint64_t target_rate_hz,
                                     double ns_per_cycle,
                                     std::atomic<bool>& stop) {
    std::vector<void*> live;
    live.reserve(2048);

    // Pre-fill — creates fragmentation before measurement starts.
    for (int i = 0; i < 512; ++i) {
        void* p = std::malloc(BG_SIZE_CLASSES[i % BG_NUM_CLASSES]);
        *reinterpret_cast<uint8_t*>(p) = 0xCC;
        live.push_back(p);
    }

    const uint64_t period_cycles = (target_rate_hz == 0)
        ? 0
        : ns_to_cycles(1'000'000'000ULL / target_rate_hz, ns_per_cycle);
    uint64_t next = __rdtsc() + period_cycles;

    std::mt19937 rng(42);  // fixed seed for reproducibility (documented in README)

    while (!stop.load(std::memory_order_relaxed)) {
        if (period_cycles) {
            while (__rdtsc() < next) { _mm_pause(); }
            next += period_cycles;
        }

        if ((rng() & 1) || live.empty()) {
            const size_t sz = BG_SIZE_CLASSES[rng() % BG_NUM_CLASSES];
            void* p = std::malloc(sz);
            *reinterpret_cast<uint8_t*>(p) = 0xCC;
            live.push_back(p);
        } else {
            const size_t idx = rng() % live.size();
            std::free(live[idx]);
            live[idx] = live.back();
            live.pop_back();
        }
    }

    for (void* p : live) std::free(p);
}
