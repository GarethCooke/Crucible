#pragma once
// TSC timing utilities shared across custom-pipeline benchmarks (demos 04, 05, 06).
// Requires x86 with constant_tsc + nonstop_tsc (checked by calibrate_tsc).

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <x86intrin.h>  // __rdtscp, __rdtsc, _mm_lfence

namespace crucible {

// Ordered TSC read: rdtscp retires all prior loads/stores, lfence prevents
// subsequent instructions from executing before rdtscp retires.
inline uint64_t rdtscp_ordered() noexcept {
    unsigned aux;
    uint64_t t = __rdtscp(&aux);
    _mm_lfence();
    return t;
}

// Calibrate TSC against CLOCK_MONOTONIC_RAW over a 100 ms busy-wait window.
// Checks constant_tsc and nonstop_tsc in /proc/cpuinfo; aborts on missing flags.
// Also checks invariant_tsc (non-fatal: noted in output but does not abort).
// Returns ns per cycle.
inline double calibrate_tsc() {
    bool has_constant = false, has_nonstop = false, has_invariant = false;
    if (FILE* f = std::fopen("/proc/cpuinfo", "r")) {
        char line[256];
        while (std::fgets(line, sizeof(line), f)) {
            if (std::strstr(line, "constant_tsc"))  has_constant  = true;
            if (std::strstr(line, "nonstop_tsc"))   has_nonstop   = true;
            if (std::strstr(line, "invariant_tsc")) has_invariant = true;
        }
        std::fclose(f);
    }
    if (!has_constant || !has_nonstop) {
        std::fprintf(stderr,
            "ERROR: TSC stability flags missing in /proc/cpuinfo.\n"
            "  constant_tsc:  %s\n  nonstop_tsc:   %s\n  invariant_tsc: %s\n"
            "  rdtscp-based timing requires constant_tsc and nonstop_tsc.\n",
            has_constant  ? "present" : "MISSING",
            has_nonstop   ? "present" : "MISSING",
            has_invariant ? "present" : "absent (non-fatal)");
        std::exit(1);
    }

    auto mono_ns = []() -> uint64_t {
        struct timespec ts{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
        return static_cast<uint64_t>(ts.tv_sec) * 1'000'000'000ULL
             + static_cast<uint64_t>(ts.tv_nsec);
    };

    const uint64_t t0_ns  = mono_ns();
    const uint64_t t0_cyc = rdtscp_ordered();
    while (mono_ns() - t0_ns < 100'000'000ULL) {}
    const uint64_t t1_cyc = rdtscp_ordered();
    const uint64_t t1_ns  = mono_ns();
    return static_cast<double>(t1_ns - t0_ns) / static_cast<double>(t1_cyc - t0_cyc);
}

// Convert an offered rate in Hz to a TSC pacing period in cycles.
// Returns 0 when rate_hz == 0 (saturated / no pacing).
inline uint64_t pacing_period_cycles(uint64_t rate_hz, double ns_per_cycle) noexcept {
    if (rate_hz == 0) return 0;
    return static_cast<uint64_t>(1.0e9 / (static_cast<double>(rate_hz) * ns_per_cycle));
}

} // namespace crucible
