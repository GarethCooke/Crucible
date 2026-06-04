#pragma once
// Warmup verification helper: accumulates early vs late latency samples to
// confirm the measurement window is fully warmed up before the headline data.

#include "histogram.h"
#include <cstdio>

namespace crucible {

struct WarmupVerify {
    bool      enabled = false;
    Histogram early;  // items 0..9,999 of measurement phase
    Histogram late;   // items 100,000+ of measurement phase

    void report() const {
        if (!enabled) return;
        std::fprintf(stderr,
            "\n=== Warmup verification ===\n"
            "Items 0-9,999   (early): p50=%llu ns  p99=%llu ns\n"
            "Items 100,000+  (late):  p50=%llu ns  p99=%llu ns\n",
            (unsigned long long)early.percentile(50.0),
            (unsigned long long)early.percentile(99.0),
            (unsigned long long)late.percentile(50.0),
            (unsigned long long)late.percentile(99.0));
    }
};

} // namespace crucible
