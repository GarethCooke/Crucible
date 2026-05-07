#pragma once
#include <algorithm>
#include <cstddef>
#include <stdexcept>
#include <vector>

namespace crucible {

// All functions take a copy so the caller's vector is not sorted in place.

inline double median(std::vector<double> v) {
    if (v.empty()) throw std::invalid_argument("stats::median — empty input");
    std::sort(v.begin(), v.end());
    const size_t n = v.size();
    return n % 2 == 0 ? (v[n / 2 - 1] + v[n / 2]) / 2.0 : v[n / 2];
}

inline double percentile(std::vector<double> v, double p) {
    if (v.empty()) throw std::invalid_argument("stats::percentile — empty input");
    std::sort(v.begin(), v.end());
    const double idx  = p / 100.0 * static_cast<double>(v.size() - 1);
    const size_t lo   = static_cast<size_t>(idx);
    const double frac = idx - static_cast<double>(lo);
    if (lo + 1 >= v.size()) return v.back();
    return v[lo] * (1.0 - frac) + v[lo + 1] * frac;
}

inline double iqr(const std::vector<double>& v) {
    return percentile(v, 75.0) - percentile(v, 25.0);
}

inline double minimum(const std::vector<double>& v) {
    if (v.empty()) throw std::invalid_argument("stats::minimum — empty input");
    return *std::min_element(v.begin(), v.end());
}

} // namespace crucible
