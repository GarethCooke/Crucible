// No Crossover benchmark — Demo 07
//
// Usage:
//   bench_07_no_crossover <variant> <workload> --n N [--modify-pct P] [--reps R]
//   bench_07_no_crossover --machine-info
//
// Variants:  std_map | sorted_vec | boost_flat | std_unord | absl_flat
// Workloads: lookup | modify_mix
//
// Emits one JSON object to stdout per invocation; run_one.sh loops over cells.

#include "machine_info.h"
#include "stats.h"

#include <algorithm>
#include <array>
#include <cassert>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <iterator>
#include <limits>
#include <map>
#include <type_traits>
#include <random>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#include <boost/container/flat_map.hpp>
#include <absl/container/flat_hash_map.h>
#include <absl/hash/hash.h>

// ─── Types ────────────────────────────────────────────────────────────────────

using Key = std::uint64_t;
using Val = std::uint64_t;

using M_StdMap    = std::map<Key, Val>;
using M_SortedVec = std::vector<std::pair<Key, Val>>;
using M_BoostFlat = boost::container::flat_map<Key, Val>;
using M_StdUnord  = std::unordered_map<Key, Val, absl::Hash<Key>>;
using M_AbslFlat  = absl::flat_hash_map<Key, Val>;

// ─── Populate ─────────────────────────────────────────────────────────────────

template<typename M>
static void populate(M& m, const std::vector<Key>& keys, std::size_t n) {
    // C++20 requires-expression: probe for reserve() without a separate overload per container.
    if constexpr (requires { m.reserve(n); })
        m.reserve(n);
    std::for_each_n(keys.begin(), n, [&m](Key k){ m.emplace(k, k ^ 0xDEADBEEFULL); });
}

// specialization for M_BoostFlat which was taking far too long to populate with generic function above.
static void populate(M_BoostFlat& m, const std::vector<Key>& keys, std::size_t n) {
    std::vector<std::pair<Key, Val>> pairs;
    pairs.reserve(n);
    for (std::size_t i = 0; i < n; ++i) {
        pairs.emplace_back(keys[i], keys[i] ^ 0xDEADBEEFULL);
    }
    std::sort(pairs.begin(), pairs.end(),
              [](const auto& a, const auto& b) { return a.first < b.first; });

    // ordered_unique_range tag: input is sorted and unique, no per-element search.
    m = M_BoostFlat(boost::container::ordered_unique_range,
               pairs.begin(), pairs.end());
}

static void populate(M_SortedVec& m, const std::vector<Key>& keys, std::size_t n) {
    m.reserve(n);
    std::transform(keys.begin(), keys.begin() + static_cast<std::ptrdiff_t>(n),
        std::back_inserter(m), [](Key k){ return std::pair<Key,Val>{k, k ^ 0xDEADBEEFULL}; });
    std::sort(m.begin(), m.end(), [](const auto& a, const auto& b){ return a.first < b.first; });
}

// ─── Find ─────────────────────────────────────────────────────────────────────

template<typename M>
static Val find_one(const M& m, Key k) { return m.find(k)->second; }

template<typename Vec>
static auto svec_lower_bound(Vec& v, Key k) {
    return std::lower_bound(v.begin(), v.end(), k,
        [](const std::pair<Key,Val>& p, Key x){ return p.first < x; });
}

static Val find_one(const M_SortedVec& m, Key k) {
    auto it = svec_lower_bound(m, k);
    assert(it != m.end() && it->first == k);
    return it->second;
}

// ─── Erase / Insert ───────────────────────────────────────────────────────────

template<typename M>
static void erase_one(M& m, Key k) { m.erase(k); }

static void erase_one(M_SortedVec& v, Key k) {
    auto it = svec_lower_bound(v, k);
    assert(it != v.end() && it->first == k);
    v.erase(it);
}

template<typename M>
static void insert_one(M& m, Key k, Val v) { m.emplace(k, v); }

static void insert_one(M_SortedVec& v, Key k, Val val) {
    v.insert(svec_lower_bound(v, k), {k, val});
}

// ─── Op sequence (modify_mix) ─────────────────────────────────────────────────

enum class OpKind : std::uint8_t { FIND, MODIFY };

struct Op {
    OpKind kind;
    Key    target;
    Key    replacement;
};

// Replicates pilot stage2.cpp::precompute_ops verbatim (seed=1337).
static std::vector<Op> precompute_ops(
    std::size_t N, int modify_pct, std::size_t ITERATIONS,
    const std::vector<Key>& all_keys)
{
    std::vector<Key> live(all_keys.begin(), all_keys.begin() + N);
    std::vector<Key> freed;
    std::size_t pool_next = N;

    // Fixed seed matches pilot stage2.cpp — op sequences must be identical across variants.
    std::mt19937_64 op_rng(1337);

    // Integer division truncates — intentional, matches pilot.
    const std::size_t n_modify = ITERATIONS * static_cast<std::size_t>(modify_pct) / 100;
    // Pre-fill then shuffle: gives an exact ratio rather than a probabilistic one.
    std::vector<OpKind> kinds(ITERATIONS, OpKind::FIND);
    std::fill_n(kinds.begin(), n_modify, OpKind::MODIFY);
    std::shuffle(kinds.begin(), kinds.end(), op_rng);

    std::vector<Op> ops(ITERATIONS);
    for (std::size_t i = 0; i < ITERATIONS; ++i) {
        ops[i].kind = kinds[i];
        const std::size_t idx = op_rng() % N;
        ops[i].target = live[idx];

        if (kinds[i] == OpKind::MODIFY) {
            Key replacement;
            // Exhaust fresh keys first; fall back to recycled freed keys to keep live size fixed at N.
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

// ─── Iteration count heuristics ───────────────────────────────────────────────

// Smaller maps fit in L1/L2 and run fast; more iterations amortize clock-read noise.
static std::size_t iters_for_lookup(std::size_t N) {
    if (N <= 1024)  return 10'000'000ULL;
    if (N <= 65536) return  1'000'000ULL;
    return                    100'000ULL;
}

static std::size_t iters_for_modify(std::size_t N) {
    if (N <= 256)  return 2'000'000ULL;
    if (N <= 4096) return   500'000ULL;
    return                  100'000ULL;
}

// ─── Lookup workload ─────────────────────────────────────────────────────────

// Returns ns/op for one rep, or -1.0 if over-budget.
template<typename M>
static double run_lookup_rep(
    const std::vector<Key>& keys,
    const std::array<int, 4096>& lookup_idx,
    std::size_t N,
    std::size_t ITERATIONS)
{
    M m;
    populate(m, keys, N);

    // Probe: estimate budget before committing to full run.
    {
        Val warmup = 0;
        const auto p0 = std::chrono::steady_clock::now();
        for (std::size_t i = 0; i < 1000; ++i)
            // Bitwise AND keeps index in [0, 4095] without a division in the hot path.
            warmup ^= find_one(m, keys[lookup_idx[i & 4095]]);
        const auto p1 = std::chrono::steady_clock::now();
        volatile Val ws = warmup; (void)ws;  // volatile write prevents the loop being elided as dead code
        const double probe_ns = static_cast<double>((p1 - p0).count()) / 1000.0;
        if (probe_ns * static_cast<double>(ITERATIONS) > 5e9)  // 5-second budget in nanoseconds
            return -1.0;
    }

    Val total = 0;
    const auto t0 = std::chrono::steady_clock::now();
    for (std::size_t i = 0; i < ITERATIONS; ++i)
        total ^= find_one(m, keys[lookup_idx[i & 4095]]);
    const auto t1 = std::chrono::steady_clock::now();
    volatile Val sink = total; (void)sink;  // volatile write prevents the measured loop being elided

    return static_cast<double>((t1 - t0).count()) / static_cast<double>(ITERATIONS);
}

template<typename M>
static std::vector<double> measure_lookup(
    const std::vector<Key>& keys,
    const std::array<int, 4096>& lookup_idx,
    std::size_t N, int reps)
{
    const std::size_t ITERS = iters_for_lookup(N);
    std::vector<double> results;
    results.reserve(static_cast<std::size_t>(reps));
    for (int r = 0; r < reps; ++r) {
        const double ns = run_lookup_rep<M>(keys, lookup_idx, N, ITERS);
        if (ns < 0.0) return {};  // budget exceeded, skip cell
        results.push_back(ns);
    }
    return results;
}

// ─── Modify-mix workload ──────────────────────────────────────────────────────

template<typename M>
static double run_modifymix_rep(
    const std::vector<Key>& keys,
    const std::vector<Op>& ops,
    std::size_t N)
{
    M m;
    populate(m, keys, N);

    Val total = 0;
    const auto t0 = std::chrono::steady_clock::now();
    for (const Op& o : ops) {
        if (o.kind == OpKind::FIND) {
            total ^= find_one(m, o.target);
        } else {
            erase_one(m, o.target);
            insert_one(m, o.replacement, o.replacement ^ 0xDEADBEEFULL);
        }
    }
    const auto t1 = std::chrono::steady_clock::now();
    volatile Val sink = total; (void)sink;  // volatile write prevents the measured loop being elided

    return static_cast<double>((t1 - t0).count())
           / static_cast<double>(ops.size());
}

template<typename M>
static std::vector<double> measure_modifymix(
    const std::vector<Key>& all_keys,
    std::size_t N, int modify_pct, int reps)
{
    const std::size_t ITERS = iters_for_modify(N);
    const std::vector<Key> init_keys(all_keys.begin(), all_keys.begin() + N);
    const std::vector<Op> ops = precompute_ops(N, modify_pct, ITERS, all_keys);

    // Probe first rep for budget.
    {
        M m;
        populate(m, init_keys, N);
        const std::size_t probe_n = std::min<std::size_t>(1000, ops.size());
        Val warmup = 0;
        const auto p0 = std::chrono::steady_clock::now();
        for (std::size_t i = 0; i < probe_n; ++i) {
            const Op& o = ops[i];
            if (o.kind == OpKind::FIND) {
                warmup ^= find_one(m, o.target);
            } else {
                erase_one(m, o.target);
                insert_one(m, o.replacement, o.replacement ^ 0xDEADBEEFULL);
            }
        }
        const auto p1 = std::chrono::steady_clock::now();
        volatile Val ws = warmup; (void)ws;
        const double ns_per_op = static_cast<double>((p1 - p0).count())
                                 / static_cast<double>(probe_n);
        if (ns_per_op * static_cast<double>(ITERS) > 5e9)
            return {};  // skip
    }

    std::vector<double> results;
    results.reserve(static_cast<std::size_t>(reps));
    for (int r = 0; r < reps; ++r)
        results.push_back(run_modifymix_rep<M>(init_keys, ops, N));
    return results;
}

// ─── Statistics ───────────────────────────────────────────────────────────────

struct NsStats {
    double median;
    double min;
    double max;
    double p99;
    double iqr;
    double iqr_lo;  // Q1
    double iqr_hi;  // Q3
    int    n_reps;
};

static NsStats compute_stats(std::vector<double> v) {
    NsStats s{};
    s.n_reps = static_cast<int>(v.size());
    std::sort(v.begin(), v.end());
    s.min    = v.front();
    s.max    = v.back();
    s.median = crucible::detail::pct_impl(v, 50.0);
    s.p99    = crucible::detail::pct_impl(v, 99.0);
    s.iqr_lo = crucible::detail::pct_impl(v, 25.0);
    s.iqr_hi = crucible::detail::pct_impl(v, 75.0);
    s.iqr    = s.iqr_hi - s.iqr_lo;
    return s;
}

// ─── Key generation ───────────────────────────────────────────────────────────

static std::vector<Key> gen_keys(std::size_t count) {
    std::mt19937_64 rng(42);
    std::unordered_set<Key> seen;
    seen.reserve(count);
    std::vector<Key> keys;
    keys.reserve(count);
    while (keys.size() < count) {
        Key k = rng();
        if (seen.insert(k).second)
            keys.push_back(k);
    }
    return keys;
}

// ─── Lookup index ─────────────────────────────────────────────────────────────

// 4096 = power-of-two so the hot loop can use `& 4095` instead of `% 4096`.
static std::array<int, 4096> gen_lookup_idx(std::size_t N) {
    std::mt19937_64 rng(1337);
    std::array<int, 4096> idx;
    std::generate(idx.begin(), idx.end(), [&]{ return static_cast<int>(rng() % N); });
    return idx;
}

// ─── JSON emission ─────────────────────────────────────────────────────────────

static void emit_cell_json(
    std::string_view variant,
    std::string_view workload,
    std::size_t      n,
    int              modify_pct,
    const NsStats&   s,
    std::string_view captured_at)
{
    std::printf(
        "{\n"
        "  \"variant\":\"%.*s\",\n"
        "  \"n\":%zu,\n"
        "  \"workload\":\"%.*s\",\n"
        "  \"modify_pct\":%d,\n"
        "  \"ns_per_op\":{\n"
        "    \"median\":%.4f,\n"
        "    \"min\":%.4f,\n"
        "    \"max\":%.4f,\n"
        "    \"p99\":%.4f,\n"
        "    \"iqr\":%.4f,\n"
        "    \"iqr_lo\":%.4f,\n"
        "    \"iqr_hi\":%.4f,\n"
        "    \"n_reps\":%d\n"
        "  },\n"
        "  \"compile_flags\":\"-O3 -march=native -DNDEBUG\",\n"
        "  \"captured_at\":\"%.*s\"\n"
        "}\n",
        static_cast<int>(variant.size()), variant.data(),
        n,
        static_cast<int>(workload.size()), workload.data(),
        modify_pct,
        s.median, s.min, s.max, s.p99, s.iqr, s.iqr_lo, s.iqr_hi,
        s.n_reps,
        static_cast<int>(captured_at.size()), captured_at.data());
}

// ─── Dispatch by variant string ───────────────────────────────────────────────

// std::type_identity<M> wraps a type as a value so a generic lambda can receive it
// as a deduced template parameter — the only way to pass a type to a runtime-dispatched lambda.
template <typename Fn>
static std::vector<double> with_variant(std::string_view variant, Fn&& fn)
{
    if (variant == "std_map")    return fn(std::type_identity<M_StdMap>{});
    if (variant == "sorted_vec") return fn(std::type_identity<M_SortedVec>{});
    if (variant == "boost_flat") return fn(std::type_identity<M_BoostFlat>{});
    if (variant == "std_unord")  return fn(std::type_identity<M_StdUnord>{});
    if (variant == "absl_flat")  return fn(std::type_identity<M_AbslFlat>{});
    return {};
}

// Returns per-rep ns/op samples, empty if cell is skipped.
static std::vector<double> dispatch_lookup(
    std::string_view variant,
    const std::vector<Key>& keys,
    const std::array<int, 4096>& lookup_idx,
    std::size_t N, int reps)
{
    return with_variant(variant, [&]<typename M>(std::type_identity<M>) {
        return measure_lookup<M>(keys, lookup_idx, N, reps);
    });
}

static std::vector<double> dispatch_modifymix(
    std::string_view variant,
    const std::vector<Key>& all_keys,
    std::size_t N, int modify_pct, int reps)
{
    return with_variant(variant, [&]<typename M>(std::type_identity<M>) {
        return measure_modifymix<M>(all_keys, N, modify_pct, reps);
    });
}

// ─── Main ─────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: %s <variant> <workload> --n N [--modify-pct P] [--reps R]\n"
            "       %s --machine-info\n"
            "Variants:  std_map | sorted_vec | boost_flat | std_unord | absl_flat\n"
            "Workloads: lookup | modify_mix\n",
            argv[0], argv[0]);
        return 1;
    }

    if (std::string_view(argv[1]) == "--machine-info") {
        std::printf("{%s}\n", crucible::machine_info_json().c_str());
        return 0;
    }

    if (argc < 3) {
        std::fprintf(stderr, "ERROR: missing workload argument\n"); return 1;
    }

    const std::string_view variant  = argv[1];
    const std::string_view workload = argv[2];

    const char* const VALID_VARIANTS[] = {
        "std_map", "sorted_vec", "boost_flat", "std_unord", "absl_flat"
    };
    const bool variant_ok = std::any_of(std::begin(VALID_VARIANTS), std::end(VALID_VARIANTS),
        [&](const char* v){ return variant == v; });
    if (!variant_ok) {
        std::fprintf(stderr, "ERROR: unknown variant '%s'\n", argv[1]);
        std::fprintf(stderr, "Valid: std_map | sorted_vec | boost_flat | std_unord | absl_flat\n");
        return 1;
    }
    if (workload != "lookup" && workload != "modify_mix") {
        std::fprintf(stderr, "ERROR: unknown workload '%s'\n", argv[2]);
        std::fprintf(stderr, "Valid: lookup | modify_mix\n");
        return 1;
    }

    std::size_t n          = 0;
    int         modify_pct = 0;
    int         reps       = 5;

    for (int i = 3; i < argc; ++i) {
        std::string_view arg = argv[i];
        if (arg == "--n" && i + 1 < argc) {
            try { n = std::stoull(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --n requires a positive integer\n"); return 1; }
        } else if (arg == "--modify-pct" && i + 1 < argc) {
            try { modify_pct = std::stoi(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --modify-pct requires an integer\n"); return 1; }
        } else if (arg == "--reps" && i + 1 < argc) {
            try { reps = std::stoi(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --reps requires a positive integer\n"); return 1; }
        } else {
            std::fprintf(stderr, "ERROR: unknown option '%s'\n", argv[i]); return 1;
        }
    }

    if (n == 0) {
        std::fprintf(stderr, "ERROR: --n is required\n"); return 1;
    }
    if (reps < 1) {
        std::fprintf(stderr, "ERROR: --reps must be >= 1\n"); return 1;
    }
    if (modify_pct < 0 || modify_pct > 90) {
        std::fprintf(stderr, "ERROR: --modify-pct must be in [0, 90]\n"); return 1;
    }

    char captured_at[32] = {};
    {
        time_t t = time(nullptr);
        strftime(captured_at, sizeof(captured_at), "%Y-%m-%dT%H:%M:%SZ", gmtime(&t));
    }

    std::fprintf(stderr, "variant=%.*s  workload=%.*s  n=%zu  modify_pct=%d  reps=%d\n",
        static_cast<int>(variant.size()), variant.data(),
        static_cast<int>(workload.size()), workload.data(),
        n, modify_pct, reps);

    // Workload A: lookup-only
    if (workload == "lookup") {
        const std::vector<Key> keys = gen_keys(n);
        const auto lookup_idx = gen_lookup_idx(n);
        const std::vector<double> samples = dispatch_lookup(variant, keys, lookup_idx, n, reps);

        if (samples.empty()) {
            std::fprintf(stderr, "SKIP: cell over budget\n");
            return 2;  // 2 = skipped (over budget), distinct from 1 = error so run_one.sh can tell them apart
        }

        const NsStats s = compute_stats(samples);
        emit_cell_json(variant, "lookup", n, 0, s, captured_at);
        return 0;
    }

    // Workload B: modify_mix
    {
        // 2N distinct keys: first N seed the initial map; the second N are the modify pool.
        const std::vector<Key> all_keys = gen_keys(2 * n);
        const std::vector<double> samples =
            dispatch_modifymix(variant, all_keys, n, modify_pct, reps);

        if (samples.empty()) {
            std::fprintf(stderr, "SKIP: cell over budget\n");
            return 2;
        }

        const NsStats s = compute_stats(samples);
        emit_cell_json(variant, "modify_mix", n, modify_pct, s, captured_at);
        return 0;
    }
}
