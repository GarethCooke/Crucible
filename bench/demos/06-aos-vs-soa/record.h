#pragma once
#include <cassert>
#include <cstddef>
#include <cstdlib>
#include <new>

// ─── AoS record ──────────────────────────────────────────────────────────────

struct alignas(64) RecordAoS {
    double f0,  f1,  f2,  f3;
    double f4,  f5,  f6,  f7;
    double f8,  f9,  f10, f11;
    double f12, f13, f14, f15;
};

static_assert(sizeof(RecordAoS)  == 128, "RecordAoS must be 128 bytes (2 cache lines)");
static_assert(alignof(RecordAoS) ==  64, "RecordAoS must be cache-line aligned");

// ─── Aligned buffer ───────────────────────────────────────────────────────────
// Owning buffer of T values allocated with 64-byte alignment.
// The data pointer is guaranteed to be 64-byte aligned at construction; an
// assertion fires if std::aligned_alloc does not satisfy it.

template <typename T>
struct aligned_buffer {
    T*     data  = nullptr;
    size_t count = 0;

    explicit aligned_buffer(size_t n) : count(n) {
        // aligned_alloc requires size to be a multiple of alignment.
        const size_t sz = ((n * sizeof(T) + 63) / 64) * 64;
        data = static_cast<T*>(std::aligned_alloc(64, sz));
        if (!data) throw std::bad_alloc{};
        assert(reinterpret_cast<uintptr_t>(data) % 64 == 0);
    }

    ~aligned_buffer() { std::free(data); }

    aligned_buffer(const aligned_buffer&)            = delete;
    aligned_buffer& operator=(const aligned_buffer&) = delete;
    aligned_buffer(aligned_buffer&& o) noexcept : data(o.data), count(o.count) {
        o.data = nullptr; o.count = 0;
    }
};

// ─── SoA record ──────────────────────────────────────────────────────────────
// Sixteen separate aligned column buffers, each holding N doubles.
// Each buffer's data pointer is 64-byte aligned (guaranteed by aligned_buffer).
// Sixteen separate allocations rather than one partitioned block so that TLB
// pressure from SoA at large N is honestly captured rather than obscured by a
// single huge-page allocation.

struct RecordSoA {
    aligned_buffer<double> f0,  f1,  f2,  f3;
    aligned_buffer<double> f4,  f5,  f6,  f7;
    aligned_buffer<double> f8,  f9,  f10, f11;
    aligned_buffer<double> f12, f13, f14, f15;

    explicit RecordSoA(size_t n)
        : f0(n),  f1(n),  f2(n),  f3(n),
          f4(n),  f5(n),  f6(n),  f7(n),
          f8(n),  f9(n),  f10(n), f11(n),
          f12(n), f13(n), f14(n), f15(n) {}
};
