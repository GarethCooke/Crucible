#pragma once

// Input distributions for the sorting shootout benchmark.
// Fixed seed: documented in README.md.
// All distributions use the RNG passed in; callers must fix the seed before
// calling to ensure reproducibility.

#include <algorithm>
#include <cstddef>
#include <random>
#include <type_traits>
#include <vector>

enum class Dist { Random, Sorted, Reverse, FewUnique, Sawtooth };

inline const char* dist_name(Dist d) {
    switch (d) {
        case Dist::Random:    return "random";
        case Dist::Sorted:    return "sorted";
        case Dist::Reverse:   return "reverse";
        case Dist::FewUnique: return "few_unique";
        case Dist::Sawtooth:  return "sawtooth";
    }
    return "unknown";
}

// make_input<T>
//   Random   — uniform over the full key range; uses rng.
//   Sorted   — 0, 1, …, n-1  (wraps at T::max).
//   Reverse  — n-1, …, 1, 0  (wraps at T::max).
//   FewUnique— uniform over [0, 99]; exercises pdqsort's few-unique fast path
//              and radix's "high passes are all one bucket" locality.
//   Sawtooth — i % (n/8), eight repeating ramps. The pdqsort-defeat case.

template <class T>
std::vector<T> make_input(Dist d, size_t n, std::mt19937_64& rng) {
    static_assert(std::is_unsigned_v<T>, "make_input supports unsigned keys only");
    std::vector<T> v(n);
    switch (d) {
        case Dist::Random: {
            std::uniform_int_distribution<T> u;
            for (auto& x : v) x = u(rng);
            break;
        }
        case Dist::Sorted:
            for (size_t i = 0; i < n; ++i) v[i] = static_cast<T>(i);
            break;
        case Dist::Reverse:
            for (size_t i = 0; i < n; ++i) v[i] = static_cast<T>(n - 1 - i);
            break;
        case Dist::FewUnique: {
            std::uniform_int_distribution<T> u(0, 99);
            for (auto& x : v) x = u(rng);
            break;
        }
        case Dist::Sawtooth: {
            T period = static_cast<T>(std::max<size_t>(1, n / 8));
            for (size_t i = 0; i < n; ++i) v[i] = static_cast<T>(i % period);
            break;
        }
    }
    return v;
}
