// demo08_pilot.cpp
// THROWAWAY calibration pilot for Crucible demo 8 (sorting shootout).
// NOT for commit: no JSON, no chart, no schema. It reads SHAPES, not magnitudes.
// Every printed number is ordinal — crossover *locations* and *spreads* carry
// forward to the brief; absolute ns/elem do not (that is §4's job, on the
// isolated boot through the real harness).
//
// Build:
//   g++ -O3 -march=native -std=c++20 demo08_pilot.cpp -o demo08_pilot
//   (Drop Orson Peters' pdqsort.h beside this file for Phase 2. Without it,
//    Phases 1 and 3 still run and Phase 2 is skipped.)
//
// Run (pin to one core; isolation NOT required for the pilot):
//   taskset -c 7 ./demo08_pilot

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <random>
#include <vector>

#if __has_include("pdqsort.h")
  #include "pdqsort.h"
  #define HAVE_PDQSORT 1
#else
  #define HAVE_PDQSORT 0
#endif

using clk = std::chrono::steady_clock;
static double ns(clk::duration d) {
    return std::chrono::duration<double, std::nano>(d).count();
}

// --- LSD radix for u32: 4 passes of 8 bits. Even pass count => result in `a`.
static void radix_u32(std::vector<uint32_t>& a, std::vector<uint32_t>& tmp) {
    const size_t n = a.size();
    for (int shift = 0; shift < 32; shift += 8) {
        size_t count[256] = {0};
        for (size_t i = 0; i < n; ++i) ++count[(a[i] >> shift) & 0xFFu];
        size_t sum = 0;
        for (int b = 0; b < 256; ++b) { size_t c = count[b]; count[b] = sum; sum += c; }
        for (size_t i = 0; i < n; ++i) tmp[count[(a[i] >> shift) & 0xFFu]++] = a[i];
        a.swap(tmp);  // 4 swaps total -> sorted data ends back in `a`
    }
}

enum class Dist { Random, Sorted, Reverse, FewUnique, Sawtooth };
static const char* dist_name(Dist d) {
    switch (d) {
        case Dist::Random:    return "random";
        case Dist::Sorted:    return "sorted";
        case Dist::Reverse:   return "reverse";
        case Dist::FewUnique: return "few-uniq";
        case Dist::Sawtooth:  return "sawtooth";
    }
    return "?";
}

static std::vector<uint32_t> make_input(Dist d, size_t n, std::mt19937& rng) {
    std::vector<uint32_t> v(n);
    switch (d) {
        case Dist::Random: {
            std::uniform_int_distribution<uint32_t> u;
            for (auto& x : v) x = u(rng);
            break;
        }
        case Dist::Sorted:
            for (size_t i = 0; i < n; ++i) v[i] = (uint32_t)i;
            break;
        case Dist::Reverse:
            for (size_t i = 0; i < n; ++i) v[i] = (uint32_t)(n - 1 - i);
            break;
        case Dist::FewUnique: {
            std::uniform_int_distribution<uint32_t> u(0, 99);
            for (auto& x : v) x = u(rng);
            break;
        }
        case Dist::Sawtooth: {
            const uint32_t period = (uint32_t)std::max<size_t>(1, n / 8);
            for (size_t i = 0; i < n; ++i) v[i] = (uint32_t)(i % period);
            break;
        }
    }
    return v;
}

// Median ns/elem over `reps`, pristine buffer restored each rep (OUTSIDE timer).
template <class SortFn>
static double timed_median(const std::vector<uint32_t>& master, SortFn sortfn,
                           int reps, uint64_t& sink) {
    std::vector<uint32_t> work(master.size());
    std::vector<uint32_t> tmp(master.size());  // radix scratch; ignored by others
    std::vector<double> samples;
    samples.reserve(reps);
    for (int r = 0; r < reps; ++r) {
        work = master;                         // restore — same capacity, so memcpy
        auto t0 = clk::now();
        sortfn(work, tmp);
        auto t1 = clk::now();
        sink ^= work.front() ^ work[work.size() / 2] ^ work.back();
        samples.push_back(ns(t1 - t0) / (double)master.size());
    }
    std::sort(samples.begin(), samples.end());
    return samples[samples.size() / 2];
}

int main() {
    std::mt19937 rng(0xC0FFEE);
    uint64_t sink = 0;

    auto std_sort = [](std::vector<uint32_t>& a, std::vector<uint32_t>&) {
        std::sort(a.begin(), a.end());
    };
    auto radix = [](std::vector<uint32_t>& a, std::vector<uint32_t>& t) {
        radix_u32(a, t);
    };
#if HAVE_PDQSORT
    auto pdq = [](std::vector<uint32_t>& a, std::vector<uint32_t>&) {
        pdqsort(a.begin(), a.end());
    };
#endif

    // ---- PHASE 1: crossover + cache staircase (random input, N sweep) -------
    // GOAL (a): find N where radix overtakes std::sort (winner column flips).
    // GOAL (b): watch ns/elem step up as the working set crosses L1/L2/L3.
    // Zen 2 / 3800X tiers (u32 = 4 B): L1d 32 KB ~ 8 K elems, L2 512 KB ~ 128 K,
    // L3 16 MB/CCX ~ 4 M. Look for the curve steepening near those N.
    printf("== PHASE 1: random u32, N sweep -- ns/elem (median) ==\n");
    printf("%12s %10s %10s", "N", "std::sort", "radix");
#if HAVE_PDQSORT
    printf(" %10s", "pdqsort");
#endif
    printf("   winner\n");
    for (int e = 10; e <= 26; ++e) {            // 1 K .. 67 M elements
        size_t n = (size_t)1 << e;
        int reps = (e <= 22) ? 7 : 3;
        auto in = make_input(Dist::Random, n, rng);
        double s = timed_median(in, std_sort, reps, sink);
        double r = timed_median(in, radix, reps, sink);
        printf("%12zu %10.3f %10.3f", n, s, r);
#if HAVE_PDQSORT
        double p = timed_median(in, pdq, reps, sink);
        printf(" %10.3f", p);
#endif
        printf("   %s\n", (r < s ? "radix" : "std::sort"));
    }

    // ---- PHASE 2: distribution sensitivity (fixed N) -----------------------
    // GOAL (c): does input shape spread the comparison sorts enough to carry
    // chart 2? Expect pdqsort to collapse on sorted/few-unique; radix ~flat.
#if HAVE_PDQSORT
    {
        const size_t n = (size_t)1 << 22;       // 4 M ~ L3/CCX boundary
        printf("\n== PHASE 2: N=%zu -- ns/elem (median) by distribution ==\n", n);
        printf("%10s %10s %10s %10s\n", "dist", "std::sort", "pdqsort", "radix");
        for (Dist d : {Dist::Random, Dist::Sorted, Dist::Reverse,
                       Dist::FewUnique, Dist::Sawtooth}) {
            auto in = make_input(d, n, rng);
            double s = timed_median(in, std_sort, 7, sink);
            double p = timed_median(in, pdq, 7, sink);
            double r = timed_median(in, radix, 7, sink);
            printf("%10s %10.3f %10.3f %10.3f\n", dist_name(d), s, p, r);
        }
    }
#else
    printf("\n== PHASE 2 skipped: pdqsort.h not found beside the source ==\n");
#endif

    // ---- PHASE 3: destructive-sort harness check ---------------------------
    // GOAL (d): prove the pristine-buffer restore matters. WITH restore, every
    // rep sorts fresh random data (times steady). WITHOUT restore, rep 0 sorts
    // random data and reps 1+ re-sort already-sorted data -> std::sort collapses.
    // That collapse is the signature §3/§4 must never see in the real harness.
    // (Radix would NOT collapse here -- it is distribution-insensitive -- which
    //  is exactly why the bug silently flatters the comparison sorts only.)
    {
        const size_t n = (size_t)1 << 20;       // 1 M
        const int reps = 6;
        auto master = make_input(Dist::Random, n, rng);

        printf("\n== PHASE 3: std::sort, N=%zu -- per-rep ns/elem ==\n", n);
        for (int mode = 0; mode < 2; ++mode) {
            bool restore = (mode == 0);
            printf("  %s restore:\n", restore ? "WITH" : "WITHOUT");
            std::vector<uint32_t> work = master;
            for (int r = 0; r < reps; ++r) {
                if (restore) work = master;     // outside timer
                auto t0 = clk::now();
                std::sort(work.begin(), work.end());
                auto t1 = clk::now();
                sink ^= work.front() ^ work.back();
                printf("    rep %d  %.3f ns/elem\n", r, ns(t1 - t0) / (double)n);
            }
        }
        printf("  Expect WITH ~ steady; WITHOUT: rep 0 normal, reps 1+ collapse.\n");
    }

    if (sink == 0x1234) fprintf(stderr, "");    // defeat dead-code elimination
    return 0;
}
