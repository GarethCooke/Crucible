#pragma once

// LSD radix sort — 8 bits per pass, sizeof(T) passes.
// Even pass count for u32 (4 passes) and u64 (8 passes) means the sorted
// result lands back in `a` after all the swaps.
// `tmp` is scratch space of the same size as `a`; allocated once by the
// caller outside any timed region.

#include <cstddef>
#include <cstdint>
#include <type_traits>
#include <vector>

template <class T>
void radix_lsd(std::vector<T>& a, std::vector<T>& tmp) {
    static_assert(std::is_unsigned_v<T>, "LSD radix here assumes unsigned fixed-width keys");
    const size_t n = a.size();
    for (unsigned shift = 0; shift < sizeof(T) * 8; shift += 8) {
        size_t count[256] = {0};
        for (size_t i = 0; i < n; ++i) ++count[(a[i] >> shift) & 0xFFu];
        size_t sum = 0;
        for (int b = 0; b < 256; ++b) { size_t c = count[b]; count[b] = sum; sum += c; }
        for (size_t i = 0; i < n; ++i) tmp[count[(a[i] >> shift) & 0xFFu]++] = a[i];
        a.swap(tmp);
    }
}
