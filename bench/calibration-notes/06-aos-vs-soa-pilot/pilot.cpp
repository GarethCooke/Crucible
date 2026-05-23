// bench/calibration-notes/06-aos-vs-soa-pilot/pilot.cpp
// Throwaway calibration harness. Not committed to main. No JSON, no Google Benchmark.
// Build: g++ -O3 -march=native -std=c++20 -o pilot pilot.cpp
// Run:   sudo -E cset shield --exec -- ./pilot > results.csv

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>

constexpr int FIELDS = 16;
using Field = double;

// 16 × 8 B = 128 B per element, aligned to 64 B (two cache lines).
struct alignas(64) AoSElement {
    Field f[FIELDS];
};

static_assert(sizeof(AoSElement) == 128, "AoSElement must be 128 B");

double bench_aos(const AoSElement* a, size_t n, int k) {
    double sum = 0.0;
    for (size_t i = 0; i < n; ++i)
        for (int j = 0; j < k; ++j)
            sum += a[i].f[j];
    return sum;
}

double bench_soa(const Field* const* cols, size_t n, int k) {
    double sum = 0.0;
    for (int j = 0; j < k; ++j) {
        const Field* col = cols[j];
        for (size_t i = 0; i < n; ++i)
            sum += col[i];
    }
    return sum;
}

template <typename F>
double median_ns_per_op(F&& fn, size_t n, int k) {
    using clk = std::chrono::steady_clock;
    // 3 warmup runs (not timed)
    for (int i = 0; i < 3; ++i) (void)fn();
    double samples[5];
    for (int i = 0; i < 5; ++i) {
        auto t0 = clk::now();
        double s = fn();
        auto t1 = clk::now();
        // Prevent DCE of the reduction result.
        if (s == 0.12345678901234567) std::abort();
        double total_ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
        // ns per (element × field touched) — normalises across (N, K) cells.
        samples[i] = total_ns / (double(n) * double(k));
    }
    std::sort(samples, samples + 5);
    return samples[2]; // median
}

int main() {
    // Working-set sweep: 8 log-spaced points L1 → DRAM at 128 B/struct.
    constexpr size_t Ns[] = {64, 256, 1024, 4096, 16384, 65536, 262144, 1048576};
    constexpr int    Ks[] = {1, 2, 4, 8, 16};
    constexpr int    N_COUNT = sizeof(Ns) / sizeof(Ns[0]);
    constexpr int    K_COUNT = sizeof(Ks) / sizeof(Ks[0]);

    // Allocate at the maximum N; smaller sweeps index into the same allocation.
    constexpr size_t MAX_N = Ns[N_COUNT - 1];

    // AoS allocation.
    std::vector<AoSElement> aos(MAX_N);
    for (size_t i = 0; i < MAX_N; ++i)
        for (int j = 0; j < FIELDS; ++j)
            aos[i].f[j] = double(i * FIELDS + j + 1);

    // SoA: FIELDS separate column vectors, each MAX_N elements.
    // Use separate heap allocations so each column is independently addressed.
    std::vector<std::vector<Field>> soa_storage(FIELDS, std::vector<Field>(MAX_N));
    std::vector<const Field*> soa_cols(FIELDS);
    for (int j = 0; j < FIELDS; ++j) {
        for (size_t i = 0; i < MAX_N; ++i)
            soa_storage[j][i] = double(i * FIELDS + j + 1);
        soa_cols[j] = soa_storage[j].data();
    }

    std::fprintf(stdout, "layout,N,K,bytes,ns_per_op\n");

    for (int ni = 0; ni < N_COUNT; ++ni) {
        size_t n = Ns[ni];
        size_t bytes = n * sizeof(AoSElement);

        for (int ki = 0; ki < K_COUNT; ++ki) {
            int k = Ks[ki];

            double t_aos = median_ns_per_op(
                [&]{ return bench_aos(aos.data(), n, k); }, n, k);

            double t_soa = median_ns_per_op(
                [&]{ return bench_soa(soa_cols.data(), n, k); }, n, k);

            std::fprintf(stdout, "AoS,%zu,%d,%zu,%.4f\n", n, k, bytes, t_aos);
            std::fprintf(stdout, "SoA,%zu,%d,%zu,%.4f\n", n, k, bytes, t_soa);
            std::fflush(stdout);
        }
    }

    return 0;
}
