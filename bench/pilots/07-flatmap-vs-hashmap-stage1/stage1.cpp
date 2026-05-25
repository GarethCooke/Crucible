#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <random>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>
#include <map>
#include <unordered_map>

#include <boost/container/flat_map.hpp>
#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>

// hostname / uname
#ifdef _WIN32
#  include <winsock2.h>
#else
#  include <sys/utsname.h>
#  include <unistd.h>
#endif

using Key = std::uint64_t;
using Val = std::uint64_t;

using M_ordered    = std::map<Key, Val>;
using M_sorted_vec = std::vector<std::pair<Key, Val>>;
using M_flat       = boost::container::flat_map<Key, Val>;
using M_unordered  = std::unordered_map<Key, Val, absl::Hash<Key>>;
using M_absl       = absl::flat_hash_map<Key, Val, absl::Hash<Key>>;

// ---- populate overloads ----

static void populate(M_ordered& m, const std::vector<Key>& keys, const std::vector<Val>& vals) {
    for (std::size_t i = 0; i < keys.size(); ++i)
        m.emplace(keys[i], vals[i]);
}

static void populate(M_sorted_vec& m, const std::vector<Key>& keys, const std::vector<Val>& vals) {
    m.reserve(keys.size());
    for (std::size_t i = 0; i < keys.size(); ++i)
        m.emplace_back(keys[i], vals[i]);
    std::sort(m.begin(), m.end(), [](const auto& a, const auto& b){ return a.first < b.first; });
}

static void populate(M_flat& m, const std::vector<Key>& keys, const std::vector<Val>& vals) {
    for (std::size_t i = 0; i < keys.size(); ++i)
        m.emplace(keys[i], vals[i]);
}

static void populate(M_unordered& m, const std::vector<Key>& keys, const std::vector<Val>& vals) {
    m.reserve(keys.size());
    for (std::size_t i = 0; i < keys.size(); ++i)
        m.emplace(keys[i], vals[i]);
}

static void populate(M_absl& m, const std::vector<Key>& keys, const std::vector<Val>& vals) {
    m.reserve(keys.size());
    for (std::size_t i = 0; i < keys.size(); ++i)
        m.emplace(keys[i], vals[i]);
}

// ---- find_one overloads ----

static Val find_one(const M_ordered& m, Key k)    { return m.find(k)->second; }
static Val find_one(const M_unordered& m, Key k)  { return m.find(k)->second; }
static Val find_one(const M_absl& m, Key k)        { return m.find(k)->second; }
static Val find_one(const M_flat& m, Key k)        { return m.find(k)->second; }

static Val find_one(const M_sorted_vec& m, Key k) {
    auto it = std::lower_bound(m.begin(), m.end(), k,
                               [](const std::pair<Key,Val>& p, Key v){ return p.first < v; });
    return it->second;
}

// ---- timing ----

template<typename M>
static double time_lookup(int N) {
    // 1. Generate N distinct keys
    std::mt19937_64 rng(42);
    std::unordered_set<Key> seen;
    seen.reserve(N);
    std::vector<Key> keys;
    keys.reserve(N);
    while ((int)keys.size() < N) {
        Key k = rng();
        if (seen.insert(k).second)
            keys.push_back(k);
    }

    // 2. Deterministic values
    std::vector<Val> vals(N);
    for (int i = 0; i < N; ++i)
        vals[i] = keys[i] ^ 0xDEADBEEFULL;

    // 3. Populate (outside timed region)
    M m;
    populate(m, keys, vals);

    // 4. Fixed lookup sequence (separate RNG)
    std::array<int, 4096> lookup_idx;
    {
        std::mt19937_64 rng2(1337);
        for (auto& idx : lookup_idx)
            idx = static_cast<int>(rng2() % static_cast<std::uint64_t>(N));
    }

    // 5. Iteration count
    const std::size_t ITERATIONS =
        (N <= 1024)  ? 10'000'000ULL :
        (N <= 65536) ?  1'000'000ULL :
                          100'000ULL;

    // 6. Skip if single cell would exceed 5 s: do a quick probe (1000 iters)
    {
        Val warmup = 0;
        const auto p0 = std::chrono::steady_clock::now();
        for (std::size_t i = 0; i < 1000; ++i)
            warmup += find_one(m, keys[lookup_idx[i & 4095]]);
        const auto p1 = std::chrono::steady_clock::now();
        volatile Val ws = warmup; (void)ws;
        double probe_ns = static_cast<double>((p1 - p0).count()) / 1000.0;
        if (probe_ns * static_cast<double>(ITERATIONS) > 5e9)
            return -1.0;  // signal skip
    }

    // 7. Timed inner loop
    Val total = 0;
    const auto t0 = std::chrono::steady_clock::now();
    for (std::size_t i = 0; i < ITERATIONS; ++i) {
        const Key k = keys[lookup_idx[i & 4095]];
        total ^= find_one(m, k);
    }
    const auto t1 = std::chrono::steady_clock::now();
    volatile Val sink = total; (void)sink;

    return static_cast<double>((t1 - t0).count()) / static_cast<double>(ITERATIONS);
}

// ---- provenance helpers ----

static std::string get_hostname() {
    char buf[256] = {};
#ifdef _WIN32
    DWORD sz = sizeof(buf);
    GetComputerNameA(buf, &sz);
#else
    gethostname(buf, sizeof(buf) - 1);
#endif
    return buf;
}

static std::string get_kernel() {
#ifdef _WIN32
    return "windows";
#else
    struct utsname u;
    uname(&u);
    return u.release;
#endif
}

static std::string iso8601() {
    std::time_t t = std::time(nullptr);
    char buf[32] = {};
    std::strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", std::gmtime(&t));
    return buf;
}

// ---- main ----

int main() {
    constexpr std::array<int, 14> N_VALUES = {
        8, 16, 32, 64, 128, 256, 512,
        1024, 4096, 16384, 65536, 262144, 1048576, 4194304
    };

    constexpr int COL_W = 13;
    const char* sep = "-------------------------------------------------------------------------------";

    std::printf("Stage 1: lookup-only crossover sweep — ns_per_op (100%% hit rate, random keys)\n");
    std::printf("%s\n", sep);
    std::printf("%8s %*s %*s %*s %*s %*s\n",
                "N",
                COL_W, "std::map",
                COL_W, "vec+lb",
                COL_W, "boost::flat",
                COL_W, "std::unord",
                COL_W, "absl::flat");

    auto fmt_cell = [](char* buf, std::size_t sz, double v) {
        if (v < 0.0) std::snprintf(buf, sz, "%*s", COL_W, "--");
        else         std::snprintf(buf, sz, "%*.1f", COL_W, v);
    };

    for (int N : N_VALUES) {
        double r0 = time_lookup<M_ordered>(N);
        double r1 = time_lookup<M_sorted_vec>(N);
        double r2 = time_lookup<M_flat>(N);
        double r3 = time_lookup<M_unordered>(N);
        double r4 = time_lookup<M_absl>(N);

        char c0[32], c1[32], c2[32], c3[32], c4[32];
        fmt_cell(c0, sizeof(c0), r0);
        fmt_cell(c1, sizeof(c1), r1);
        fmt_cell(c2, sizeof(c2), r2);
        fmt_cell(c3, sizeof(c3), r3);
        fmt_cell(c4, sizeof(c4), r4);

        std::printf("%8d %s %s %s %s %s\n", N, c0, c1, c2, c3, c4);
        std::fflush(stdout);
    }

    std::printf("%s\n", sep);

    const char* turbo = std::getenv("CRUCIBLE_TURBO");
    std::printf("host=%s  kernel=%s  gcc=%s  CRUCIBLE_TURBO=%s  ts=%s\n",
                get_hostname().c_str(),
                get_kernel().c_str(),
                __VERSION__,
                turbo ? turbo : "",
                iso8601().c_str());

    return 0;
}
