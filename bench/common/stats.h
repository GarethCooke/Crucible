#pragma once
#include <algorithm>
#include <cstddef>
#include <stdexcept>
#include <vector>

namespace crucible {

// All functions leave the caller's vector unchanged.

namespace detail {

// Linear interpolation on a pre-sorted, non-empty vector.
inline double pct_impl(const std::vector<double>& s, double p) {
    const double idx  = p / 100.0 * static_cast<double>(s.size() - 1);
    const size_t lo   = static_cast<size_t>(idx);
    const double frac = idx - static_cast<double>(lo);
    if (lo + 1 >= s.size()) return s.back();
    return s[lo] * (1.0 - frac) + s[lo + 1] * frac;
}

} // namespace detail

inline double median(std::vector<double> v) {
    if (v.empty()) throw std::invalid_argument("stats::median — empty input");
    std::sort(v.begin(), v.end());
    return detail::pct_impl(v, 50.0);
}

inline double percentile(std::vector<double> v, double p) {
    if (v.empty()) throw std::invalid_argument("stats::percentile — empty input");
    std::sort(v.begin(), v.end());
    return detail::pct_impl(v, p);
}

inline double iqr(const std::vector<double>& v) {
    if (v.empty()) throw std::invalid_argument("stats::iqr — empty input");
    auto s = v;
    std::sort(s.begin(), s.end());
    return detail::pct_impl(s, 75.0) - detail::pct_impl(s, 25.0);
}

inline double minimum(const std::vector<double>& v) {
    if (v.empty()) throw std::invalid_argument("stats::minimum — empty input");
    return *std::min_element(v.begin(), v.end());
}

} // namespace crucible
