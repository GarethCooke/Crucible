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

enum class Kind : std::uint8_t { FIND, MODIFY };

struct Op {
    Kind kind;
    Key  target;
    Key  replacement;
};

// ---- populate ----

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

// ---- find_one ----

static Val find_one(const M_ordered& m, Key k)   { return m.find(k)->second; }
static Val find_one(const M_unordered& m, Key k) { return m.find(k)->second; }
static Val find_one(const M_absl& m, Key k)       { return m.find(k)->second; }
static Val find_one(const M_flat& m, Key k)       { return m.find(k)->second; }

static Val find_one(const M_sorted_vec& v, Key k) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
                               [](const std::pair<Key,Val>& p, Key x){ return p.first < x; });
    return it->second;
}

// ---- erase_one ----

static void erase_one(M_ordered& m, Key k)   { m.erase(k); }
static void erase_one(M_unordered& m, Key k) { m.erase(k); }
static void erase_one(M_absl& m, Key k)       { m.erase(k); }
static void erase_one(M_flat& m, Key k)       { m.erase(k); }

static void erase_one(M_sorted_vec& v, Key k) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
                               [](const std::pair<Key,Val>& p, Key x){ return p.first < x; });
    v.erase(it);
}

// ---- insert_one ----

static void insert_one(M_ordered& m, Key k, Val val)   { m.emplace(k, val); }
static void insert_one(M_unordered& m, Key k, Val val) { m.emplace(k, val); }
static void insert_one(M_absl& m, Key k, Val val)       { m.emplace(k, val); }
static void insert_one(M_flat& m, Key k, Val val)       { m.emplace(k, val); }

static void insert_one(M_sorted_vec& v, Key k, Val val) {
    auto it = std::lower_bound(v.begin(), v.end(), k,
                               [](const std::pair<Key,Val>& p, Key x){ return p.first < x; });
    v.insert(it, {k, val});
}

// ---- iteration count ----

static std::size_t iters_for(int N) {
    if (N <= 256)  return 2'000'000;
    if (N <= 4096) return   500'000;
    return                  100'000;
}

// ---- op precomputation ----
// Steady-state workload: every MODIFY is an erase+insert pair keeping map size at N.
// First N keys of all_keys are the initial live set; remaining N are the insertion pool.
static std::vector<Op> precompute_ops(
    int N, int insert_pct, std::size_t ITERATIONS,
    const std::vector<Key>& all_keys)
{
    std::vector<Key> live(all_keys.begin(), all_keys.begin() + N);
    std::vector<Key> freed;
    std::size_t pool_next = static_cast<std::size_t>(N);

    std::mt19937_64 op_rng(1337);

    std::size_t n_modify = ITERATIONS * static_cast<std::size_t>(insert_pct) / 100;
    std::vector<Kind> kinds(ITERATIONS, Kind::FIND);
    for (std::size_t i = 0; i < n_modify; ++i)
        kinds[i] = Kind::MODIFY;
    std::shuffle(kinds.begin(), kinds.end(), op_rng);

    std::vector<Op> ops(ITERATIONS);
    for (std::size_t i = 0; i < ITERATIONS; ++i) {
        ops[i].kind = kinds[i];
        std::size_t idx = op_rng() % static_cast<std::uint64_t>(N);
        ops[i].target = live[idx];

        if (kinds[i] == Kind::MODIFY) {
            Key replacement;
            if (pool_next < all_keys.size()) {
                replacement = all_keys[pool_next++];
            } else {
                replacement = freed.back();
                freed.pop_back();
            }
            ops[i].replacement = replacement;
            freed.push_back(live[idx]);
            live[idx] = replacement;
        }
    }
    return ops;
}

// ---- timing ----

template<typename M>
static double time_mix(
    const std::vector<Key>& init_keys,
    const std::vector<Val>& init_vals,
    const std::vector<Op>& ops,
    std::size_t ITERATIONS)
{
    {
        M m;
        populate(m, init_keys, init_vals);
        constexpr std::size_t PROBE = 1000;
        std::size_t probe_n = std::min(PROBE, ITERATIONS);
        Val warmup = 0;
        auto p0 = std::chrono::steady_clock::now();
        for (std::size_t i = 0; i < probe_n; ++i) {
            const Op& o = ops[i];
            if (o.kind == Kind::FIND) {
                warmup ^= find_one(m, o.target);
            } else {
                erase_one(m, o.target);
                insert_one(m, o.replacement, o.replacement ^ 0xDEADBEEFULL);
            }
        }
        auto p1 = std::chrono::steady_clock::now();
        volatile Val ws = warmup; (void)ws;
        double ns_per_op = static_cast<double>((p1 - p0).count()) / static_cast<double>(probe_n);
        if (ns_per_op * static_cast<double>(ITERATIONS) > 5e9)
            return -1.0;
    }

    M m;
    populate(m, init_keys, init_vals);
    Val total = 0;
    auto t0 = std::chrono::steady_clock::now();
    for (std::size_t i = 0; i < ITERATIONS; ++i) {
        const Op& o = ops[i];
        if (o.kind == Kind::FIND) {
            total ^= find_one(m, o.target);
        } else {
            erase_one(m, o.target);
            insert_one(m, o.replacement, o.replacement ^ 0xDEADBEEFULL);
        }
    }
    auto t1 = std::chrono::steady_clock::now();
    volatile Val sink = total; (void)sink;
    return static_cast<double>((t1 - t0).count()) / static_cast<double>(ITERATIONS);
}

// ---- provenance ----

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
    constexpr std::array<int, 3> N_VALUES    = { 256, 4096, 65536 };
    constexpr std::array<int, 6> INSERT_PCTS = { 0, 10, 25, 50, 75, 90 };

    constexpr int COL_W = 13;
    const char* sep = "-------------------------------------------------------------------------------";

    std::printf("Stage 2: insert-mix sensitivity — ns_per_op (steady state, erase+insert on modify)\n");
    std::printf("%s\n", sep);

    auto fmt_cell = [](char* buf, std::size_t sz, double v) {
        if (v < 0.0) std::snprintf(buf, sz, "%*s",   COL_W, "--");
        else         std::snprintf(buf, sz, "%*.1f", COL_W, v);
    };

    for (int ni = 0; ni < static_cast<int>(N_VALUES.size()); ++ni) {
        int N = N_VALUES[ni];
        if (ni > 0) std::printf("\n");

        std::printf("N = %d\n", N);
        std::printf("  %10s %*s %*s %*s %*s %*s\n",
                    "insert_pct",
                    COL_W, "std::map",
                    COL_W, "vec+lb",
                    COL_W, "boost::flat",
                    COL_W, "std::unord",
                    COL_W, "absl::flat");

        std::mt19937_64 key_rng(42);
        std::unordered_set<Key> seen;
        seen.reserve(static_cast<std::size_t>(2 * N));
        std::vector<Key> all_keys;
        all_keys.reserve(static_cast<std::size_t>(2 * N));
        while (static_cast<int>(all_keys.size()) < 2 * N) {
            Key k = key_rng();
            if (seen.insert(k).second)
                all_keys.push_back(k);
        }

        std::vector<Key> init_keys(all_keys.begin(), all_keys.begin() + N);
        std::vector<Val> init_vals(static_cast<std::size_t>(N));
        for (int j = 0; j < N; ++j)
            init_vals[static_cast<std::size_t>(j)] = init_keys[static_cast<std::size_t>(j)] ^ 0xDEADBEEFULL;

        std::size_t ITERATIONS = iters_for(N);

        for (int insert_pct : INSERT_PCTS) {
            std::vector<Op> ops = precompute_ops(N, insert_pct, ITERATIONS, all_keys);

            double r0 = time_mix<M_ordered>   (init_keys, init_vals, ops, ITERATIONS);
            double r1 = time_mix<M_sorted_vec>(init_keys, init_vals, ops, ITERATIONS);
            double r2 = time_mix<M_flat>      (init_keys, init_vals, ops, ITERATIONS);
            double r3 = time_mix<M_unordered> (init_keys, init_vals, ops, ITERATIONS);
            double r4 = time_mix<M_absl>      (init_keys, init_vals, ops, ITERATIONS);

            char c0[32], c1[32], c2[32], c3[32], c4[32];
            fmt_cell(c0, sizeof(c0), r0);
            fmt_cell(c1, sizeof(c1), r1);
            fmt_cell(c2, sizeof(c2), r2);
            fmt_cell(c3, sizeof(c3), r3);
            fmt_cell(c4, sizeof(c4), r4);

            std::printf("  %9d%% %s %s %s %s %s\n",
                        insert_pct, c0, c1, c2, c3, c4);
            std::fflush(stdout);
        }
    }

    std::printf("\n%s\n", sep);

    const char* turbo = std::getenv("CRUCIBLE_TURBO");
    std::printf("host=%s  kernel=%s  gcc=%s  CRUCIBLE_TURBO=%s  ts=%s\n",
                get_hostname().c_str(),
                get_kernel().c_str(),
                __VERSION__,
                turbo ? turbo : "",
                iso8601().c_str());

    return 0;
}
