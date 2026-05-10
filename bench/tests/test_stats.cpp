// Unit tests for bench/common/stats.h
// Build: cmake --build bench/build --target test_stats
// Run:   ctest --test-dir bench/build --output-on-failure

#include "stats.h"

#include <algorithm>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>

// ─── Minimal test harness ─────────────────────────────────────────────────────

static int g_pass = 0, g_fail = 0;

#define EXPECT(cond) do { \
    if (cond) { ++g_pass; } \
    else { \
        std::fprintf(stderr, "  FAIL [%s:%d]: %s\n", __FILE__, __LINE__, #cond); \
        ++g_fail; \
    } \
} while(0)

#define EXPECT_NEAR(a, b, eps) EXPECT(std::fabs((a) - (b)) < (eps))

#define EXPECT_THROWS(expr, exc_type) do { \
    bool threw = false; \
    try { (expr); } catch (const exc_type&) { threw = true; } \
    EXPECT(threw); \
} while(0)

static void section(const char* name) { std::printf("  %s\n", name); }

// ─── Tests ────────────────────────────────────────────────────────────────────

static void test_median() {
    section("median");
    using crucible::median;

    // empty input throws
    EXPECT_THROWS(median({}), std::invalid_argument);

    // singleton
    EXPECT_NEAR(median({3.0}), 3.0, 1e-12);

    // odd length — middle element
    EXPECT_NEAR(median({1.0, 2.0, 3.0}),             2.0, 1e-12);
    EXPECT_NEAR(median({1.0, 2.0, 3.0, 4.0, 5.0}),  3.0, 1e-12);

    // even length — average of two centre values
    EXPECT_NEAR(median({1.0, 2.0, 3.0, 4.0}),        2.5, 1e-12);
    EXPECT_NEAR(median({0.0, 10.0}),                  5.0, 1e-12);

    // unordered input (function sorts internally)
    EXPECT_NEAR(median({5.0, 1.0, 3.0}), 3.0, 1e-12);

    // all identical values
    EXPECT_NEAR(median({7.0, 7.0, 7.0}), 7.0, 1e-12);
}

static void test_percentile() {
    section("percentile");
    using crucible::percentile;

    // empty input throws
    EXPECT_THROWS(percentile({}, 50.0), std::invalid_argument);

    // singleton — any p returns the single value
    for (double p : {0.0, 25.0, 50.0, 75.0, 100.0})
        EXPECT_NEAR(percentile({42.0}, p), 42.0, 1e-12);

    // p=0 equals minimum, p=100 equals maximum
    std::vector<double> v = {1.0, 2.0, 3.0, 4.0, 5.0};
    EXPECT_NEAR(percentile(v,   0.0), 1.0, 1e-12);
    EXPECT_NEAR(percentile(v, 100.0), 5.0, 1e-12);

    // p=50 matches median for odd-length vector
    EXPECT_NEAR(percentile(v, 50.0), crucible::median(v), 1e-12);

    // linear interpolation: [0, 10] at p=25 → 2.5
    EXPECT_NEAR(percentile({0.0, 10.0}, 25.0), 2.5, 1e-12);
    EXPECT_NEAR(percentile({0.0, 10.0}, 75.0), 7.5, 1e-12);

    // monotone in p
    std::vector<double> u = {1.0, 3.0, 5.0, 7.0, 9.0};
    double prev = percentile(u, 0.0);
    for (double p : {10.0, 25.0, 50.0, 75.0, 90.0, 100.0}) {
        double val = percentile(u, p);
        EXPECT(val >= prev - 1e-12);
        prev = val;
    }

    // unordered input is sorted internally
    EXPECT_NEAR(percentile({5.0, 1.0, 3.0}, 50.0), 3.0, 1e-12);
}

static void test_iqr() {
    section("iqr");
    using crucible::iqr;

    // always non-negative
    EXPECT(iqr({1.0})                   >= 0.0);
    EXPECT(iqr({1.0, 2.0})              >= 0.0);
    EXPECT(iqr({1.0, 2.0, 3.0, 4.0})   >= 0.0);

    // identical values → zero spread
    EXPECT_NEAR(iqr({5.0, 5.0, 5.0, 5.0}), 0.0, 1e-12);

    // IQR for [0,10]: Q3-Q1 = 7.5-2.5 = 5.0
    EXPECT_NEAR(iqr({0.0, 10.0}), 5.0, 1e-12);

    // IQR of [0..4]: Q1=1, Q3=3 → IQR=2
    EXPECT_NEAR(iqr({0.0, 1.0, 2.0, 3.0, 4.0}), 2.0, 1e-12);
}

static void test_minimum() {
    section("minimum");
    using crucible::minimum;

    // empty input throws
    EXPECT_THROWS(minimum({}), std::invalid_argument);

    // singleton
    EXPECT_NEAR(minimum({9.0}), 9.0, 1e-12);

    // matches std::min_element
    std::vector<double> v = {3.0, 1.0, 4.0, 1.0, 5.0, 9.0};
    EXPECT_NEAR(minimum(v), *std::min_element(v.begin(), v.end()), 1e-12);

    // negative values
    EXPECT_NEAR(minimum({-1.0, -5.0, -3.0}), -5.0, 1e-12);

    // caller's vector is not modified (function takes a const ref)
    std::vector<double> orig = {3.0, 1.0, 2.0};
    const auto before = orig;
    minimum(orig);
    EXPECT(orig == before);
}

// ─── main ─────────────────────────────────────────────────────────────────────

int main() {
    std::printf("stats.h unit tests\n");
    test_median();
    test_percentile();
    test_iqr();
    test_minimum();

    if (g_fail == 0)
        std::printf("All %d tests passed.\n", g_pass);
    else
        std::fprintf(stderr, "%d FAILED, %d passed.\n", g_fail, g_pass);

    return g_fail > 0 ? 1 : 0;
}
