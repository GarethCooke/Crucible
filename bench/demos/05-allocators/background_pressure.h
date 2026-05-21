#pragma once
// Background heap pressure thread (T_bg).
// Simulates other subsystems sharing the heap with mixed-size malloc/free churn.
// target_rate_hz == 0 means T_bg is NOT spawned at all (no-pressure baseline).

#include <atomic>
#include <cstddef>
#include <cstdlib>
#include <random>
#include <string>
#include <vector>

#include <x86intrin.h>

enum class BgSizeClasses { Default, Large };

static constexpr size_t BG_SIZE_CLASSES_DEFAULT[] = {32, 64, 128, 256, 512, 1024};
static constexpr size_t BG_NUM_CLASSES_DEFAULT     = 6;

// Large: crosses glibc 128KB mmap threshold at 131072, exercises mmap/munmap path.
static constexpr size_t BG_SIZE_CLASSES_LARGE[] = {64, 128, 512, 2048, 8192, 32768, 131072};
static constexpr size_t BG_NUM_CLASSES_LARGE    = 7;

inline std::string bg_size_classes_json(BgSizeClasses sc) {
    if (sc == BgSizeClasses::Large)
        return "[64,128,512,2048,8192,32768,131072]";
    return "[32,64,128,256,512,1024]";
}

inline const char* bg_size_classes_str(BgSizeClasses sc) {
    return (sc == BgSizeClasses::Large) ? "large" : "default";
}

// Convert a nanosecond interval to TSC cycles using ns_per_cycle.
inline uint64_t ns_to_cycles(uint64_t ns, double ns_per_cycle) noexcept {
    return static_cast<uint64_t>(static_cast<double>(ns) / ns_per_cycle);
}

// Main loop for T_bg. Pinned to BG_CORE by the caller before entry.
// Pre-fills bg_live_allocs items to create fragmentation pressure from t=0.
// seed: 42 for first thread, 42+n for additional threads (reproducible).
inline void background_pressure_loop(uint64_t target_rate_hz,
                                     double ns_per_cycle,
                                     std::atomic<bool>& stop,
                                     size_t bg_live_allocs   = 512,
                                     BgSizeClasses size_class = BgSizeClasses::Default,
                                     uint32_t seed           = 42) {
    const size_t* classes;
    size_t num_classes;
    if (size_class == BgSizeClasses::Large) {
        classes     = BG_SIZE_CLASSES_LARGE;
        num_classes = BG_NUM_CLASSES_LARGE;
    } else {
        classes     = BG_SIZE_CLASSES_DEFAULT;
        num_classes = BG_NUM_CLASSES_DEFAULT;
    }

    const size_t cap = 2 * bg_live_allocs;
    std::vector<void*> live;
    live.reserve(cap);

    // Pre-fill — creates fragmentation before measurement starts.
    for (size_t i = 0; i < bg_live_allocs; ++i) {
        void* p = std::malloc(classes[i % num_classes]);
        *reinterpret_cast<uint8_t*>(p) = 0xCC;
        live.push_back(p);
    }

    const uint64_t period_cycles = (target_rate_hz == 0)
        ? 0
        : ns_to_cycles(1'000'000'000ULL / target_rate_hz, ns_per_cycle);
    uint64_t next = __rdtsc() + period_cycles;

    std::mt19937 rng(seed);

    while (!stop.load(std::memory_order_relaxed)) {
        if (period_cycles) {
            while (__rdtsc() < next) { _mm_pause(); }
            next += period_cycles;
        }

        if ((rng() & 1) || live.empty()) {
            const size_t sz = classes[rng() % num_classes];
            void* p = std::malloc(sz);
            *reinterpret_cast<uint8_t*>(p) = 0xCC;
            if (live.size() < cap)
                live.push_back(p);
            else
                std::free(p);
        } else {
            const size_t idx = rng() % live.size();
            std::free(live[idx]);
            live[idx] = live.back();
            live.pop_back();
        }
    }

    for (void* p : live) std::free(p);
}
