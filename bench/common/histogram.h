#pragma once
// Log-spaced histogram with 16 sub-buckets per doubling.
// Designed for per-item latency recording in nanoseconds.
// Binning happens post-run — this header is not in the hot path.
//
// Percentile convention: bucket midpoint, i.e. (lower(i) + lower(i+1)) / 2.
// The "percentile_convention": "log2_bucket_midpoint" field in emitted JSON
// documents this choice.

#include <algorithm>
#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <string>

namespace crucible {

static constexpr size_t HISTOGRAM_BUCKET_COUNT = 384;

// Maps a nanosecond latency value to a histogram bucket index.
// bucket(0)     = 0
// bucket(1..15) = value          (linear region)
// bucket(v>=16): hb = floor(log2(v)), sub = (v >> (hb-4)) & 0xF
//               result = 16 + (hb-4)*16 + sub
// Branch-free hot path via __builtin_clzll.
inline size_t histogram_bucket(uint64_t v) noexcept {
    if (v < 16) return static_cast<size_t>(v);
    const int hb = 63 - __builtin_clzll(v);
    // hb >= 4 guaranteed since v >= 16 = 2^4
    const size_t sub = static_cast<size_t>((v >> (hb - 4)) & 0xF);
    const size_t b   = 16u + static_cast<size_t>(hb - 4) * 16u + sub;
    return (b < HISTOGRAM_BUCKET_COUNT) ? b : HISTOGRAM_BUCKET_COUNT - 1u;
}

// Lower bound of bucket i in the same unit as recorded values.
inline uint64_t histogram_bucket_lower(size_t i) noexcept {
    if (i < 16) return static_cast<uint64_t>(i);
    const size_t idx = i - 16;
    const int    hb  = static_cast<int>(idx / 16) + 4;
    const size_t sub = idx % 16;
    return (uint64_t(1) << hb) | (uint64_t(sub) << (hb - 4));
}

struct Histogram {
    std::array<uint64_t, HISTOGRAM_BUCKET_COUNT> counts{};
    uint64_t total  = 0;
    uint64_t minval = UINT64_MAX;
    uint64_t maxval = 0;

    void record(uint64_t v) noexcept {
        counts[histogram_bucket(v)]++;
        total++;
        if (v < minval) minval = v;
        if (v > maxval) maxval = v;
    }

    void merge(const Histogram& o) noexcept {
        for (size_t i = 0; i < HISTOGRAM_BUCKET_COUNT; ++i)
            counts[i] += o.counts[i];
        total += o.total;
        if (o.minval < minval) minval = o.minval;
        if (o.maxval > maxval) maxval = o.maxval;
    }

    // Returns the midpoint of the bucket containing the p-th percentile.
    // p in [0, 100]. Midpoint = (lower(i) + lower(i+1)) / 2.
    uint64_t percentile(double p) const noexcept {
        if (total == 0) return 0;
        const uint64_t target = static_cast<uint64_t>(total * p / 100.0);
        uint64_t cumulative = 0;
        for (size_t i = 0; i < HISTOGRAM_BUCKET_COUNT; ++i) {
            cumulative += counts[i];
            if (cumulative > target) {
                const uint64_t lo = histogram_bucket_lower(i);
                const uint64_t hi = (i + 1 < HISTOGRAM_BUCKET_COUNT)
                    ? histogram_bucket_lower(i + 1)
                    : (total ? maxval : lo);
                return (lo + hi) / 2;
            }
        }
        return maxval;
    }

    // Serialise counts array to JSON array string.
    std::string counts_json() const {
        std::string s;
        s.reserve(HISTOGRAM_BUCKET_COUNT * 4);
        s += '[';
        for (size_t i = 0; i < HISTOGRAM_BUCKET_COUNT; ++i) {
            if (i) s += ',';
            s += std::to_string(counts[i]);
        }
        s += ']';
        return s;
    }

    // Serialise the stats sub-object.
    // max is guaranteed >= any reported percentile.
    std::string stats_json() const {
        const uint64_t p50   = percentile(50.0);
        const uint64_t p90   = percentile(90.0);
        const uint64_t p99   = percentile(99.0);
        const uint64_t p99_9 = percentile(99.9);
        // Clamp max upward to ensure max >= any reported percentile.
        const uint64_t raw_max = total ? maxval : 0;
        const uint64_t reported_max = std::max({raw_max, p50, p90, p99, p99_9});

        char buf[512];
        std::snprintf(buf, sizeof(buf),
            "{\"count\":%llu,\"min\":%llu,\"max\":%llu"
            ",\"p50\":%llu,\"p90\":%llu,\"p99\":%llu,\"p99_9\":%llu}",
            (unsigned long long)total,
            (unsigned long long)(total ? minval : 0),
            (unsigned long long)reported_max,
            (unsigned long long)p50,
            (unsigned long long)p90,
            (unsigned long long)p99,
            (unsigned long long)p99_9);
        return std::string(buf);
    }
};

// Assemble a complete latency_ns JSON field from a header prefix, histogram,
// and trailer suffix. Avoids repeating the three-step assembly across benchmark
// emit_json functions. hdr must end with "\"counts\":" ready to receive the array.
inline std::string assemble_histogram_json(const std::string& hdr,
                                            const Histogram&   h,
                                            const std::string& trailer) {
    std::string result;
    result.reserve(hdr.size() + HISTOGRAM_BUCKET_COUNT * 8 + trailer.size() + 64);
    result += hdr;
    result += h.counts_json();
    result += ",\"stats\":";
    result += h.stats_json();
    result += trailer;
    return result;
}

} // namespace crucible
