// SPSC queue latency benchmark — Demo 04
// Usage:
//   bench_04_spsc_queue <variant> [--mode paced|saturated|sweep]
//                       [--rate-hz N] [--rate-from N] [--rate-to N] [--steps K]
//                       [--verify-warmup]
//   bench_04_spsc_queue --machine-info
//   bench_04_spsc_queue --stress-test [variant]
//
// Modes:
//   paced     (default) — producer paced at --rate-hz items/sec; queue stays near-empty.
//   saturated — producer runs flat-out; measures peak throughput.
//   sweep     — log-spaced paced runs from --rate-from to --rate-to in --steps steps.
//               Emits a JSON array; each element is one paced run.
//
// Producer pinned to core 4, consumer to core 5 (same CCX on Zen 2 3800X).
// Timestamps: rdtscp with lfence, calibrated against CLOCK_MONOTONIC_RAW.
// Histogram bins happen post-run; the hot loop only writes raw cycle counts.

#include "affinity.h"
#include "histogram.h"
#include "machine_info.h"
#include "spsc_queue.h"
#include "tick.h"
#include "tsc_utils.h"
#include "warmup_verify.h"

#include <boost/lockfree/spsc_queue.hpp>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <mutex>
#include <pthread.h>
#include <queue>
#include <sched.h>
#include <string>
#include <string_view>
#include <thread>
#include <vector>

#include <x86intrin.h>  // __rdtscp, _mm_lfence, _mm_pause

// ─── Constants ───────────────────────────────────────────────────────────────

static constexpr size_t QUEUE_DEPTH    = 1024;
static constexpr size_t ITEMS_MEASURED = 1'000'000;
static constexpr size_t ITEMS_WARMUP   = 100'000;
static constexpr size_t NUM_RUNS       = 5;
static constexpr int    PRODUCER_CORE  = 4;
static constexpr int    CONSUMER_CORE  = 5;

// Warmup items use this sentinel so the consumer can skip them without counting.
static constexpr uint64_t WARMUP_SEQ = ~uint64_t(0);

// ─── Mode ────────────────────────────────────────────────────────────────────

enum class Mode { Paced, Saturated, Sweep };

struct BenchConfig {
    Mode     mode          = Mode::Paced;
    uint64_t rate_hz       = 1'000'000;   // paced / headline rate
    uint64_t rate_from_hz  = 100'000;     // sweep start
    uint64_t rate_to_hz    = 50'000'000;  // sweep end
    int      steps         = 12;          // sweep steps
    bool     verify_warmup = false;
};

// ─── Run result ──────────────────────────────────────────────────────────────

struct RunResult {
    crucible::Histogram hist;
    double              wall_ns_total  = 0.0;
    size_t              top_bucket_count = 0;
};

// ─── Binning helper ──────────────────────────────────────────────────────────

static void bin_run(const std::vector<uint64_t>& enq_ts,
                    const std::vector<uint64_t>& deq_ts,
                    double ns_per_cycle,
                    RunResult& result,
                    crucible::WarmupVerify* wv,
                    const char* variant_name,
                    uint64_t offered_rate_hz);

// ─── Post-run stall diagnostic ────────────────────────────────────────────────
// Computes max producer/consumer inter-item gaps and the queue backlog at the
// largest consumer stall. All arithmetic is over post-run arrays; nothing here
// touches the measured hot loop. Stderr-only: no JSON schema changes.
static void emit_stall_diagnostic(const std::vector<uint64_t>& enq_ts,
                                  const std::vector<uint64_t>& deq_ts,
                                  double ns_per_cycle,
                                  const char* variant_name,
                                  uint64_t offered_rate_hz,
                                  uint64_t p99_ns,
                                  uint64_t p999_ns) {
    const size_t N = ITEMS_MEASURED;

    // Count zero deq_ts entries; for lockfree variants this contradicts the
    // stress-test zero-loss guarantee — flag loudly rather than silently skip.
    size_t zero_deq_count = 0;
    for (size_t i = 0; i < N; ++i) {
        if (deq_ts[i] == 0) ++zero_deq_count;
    }
    if (zero_deq_count > 0) {
        std::fprintf(stderr,
            "WARN stall-diag [%s]: %zu deq_ts zero entries — items dropped"
            " (contradicts stress-test zero-loss guarantee)\n",
            variant_name, zero_deq_count);
    }

    // Max enqueue gap: largest producer inter-item pause (cycles → ns).
    uint64_t max_enq_gap_cyc = 0;
    for (size_t i = 1; i < N; ++i) {
        uint64_t gap = enq_ts[i] - enq_ts[i - 1];
        if (gap > max_enq_gap_cyc) max_enq_gap_cyc = gap;
    }

    // Max dequeue gap: largest consumer inter-item pause, its item index, and
    // the surrounding timestamps needed for the backlog count.
    uint64_t max_deq_gap_cyc = 0;
    size_t   max_deq_gap_idx = 0;
    uint64_t gap_start_ts    = 0;  // deq_ts of item just before the max gap
    uint64_t gap_end_ts      = 0;  // deq_ts of item just after the max gap

    std::vector<uint64_t> deq_gaps;
    deq_gaps.reserve(N);

    uint64_t prev_deq = 0;
    bool have_prev = false;
    for (size_t i = 0; i < N; ++i) {
        if (deq_ts[i] == 0) continue;
        if (have_prev) {
            uint64_t gap = deq_ts[i] - prev_deq;
            deq_gaps.push_back(gap);
            if (gap > max_deq_gap_cyc) {
                max_deq_gap_cyc = gap;
                max_deq_gap_idx = i;
                gap_start_ts    = prev_deq;
                gap_end_ts      = deq_ts[i];
            }
        }
        prev_deq = deq_ts[i];
        have_prev = true;
    }

    // Backlog: items enqueued while the consumer was stalled (during max gap).
    // enq_ts is monotonically increasing, so this counts the pile-up.
    size_t backlog = 0;
    for (size_t j = 0; j < N; ++j) {
        if (enq_ts[j] > gap_start_ts && enq_ts[j] <= gap_end_ts) ++backlog;
    }

    const double max_enq_gap_ns = static_cast<double>(max_enq_gap_cyc) * ns_per_cycle;
    const double max_deq_gap_ns = static_cast<double>(max_deq_gap_cyc) * ns_per_cycle;

    std::fprintf(stderr,
        "DIAG %s @offered=%lluHz:"
        " p99=%llu ns  p99.9=%llu ns"
        "  max_enq_gap=%.0f ns  max_deq_gap=%.0f ns (at item %zu)  backlog=%zu items\n",
        variant_name, (unsigned long long)offered_rate_hz,
        (unsigned long long)p99_ns, (unsigned long long)p999_ns,
        max_enq_gap_ns, max_deq_gap_ns, max_deq_gap_idx, backlog);

    // Warn when max dequeue gap exceeds 50× the median — contamination signal.
    if (!deq_gaps.empty()) {
        auto mid = deq_gaps.begin() + static_cast<ptrdiff_t>(deq_gaps.size() / 2);
        std::nth_element(deq_gaps.begin(), mid, deq_gaps.end());
        const double median_deq_gap_ns = static_cast<double>(*mid) * ns_per_cycle;
        if (median_deq_gap_ns > 0.0 && max_deq_gap_ns > 50.0 * median_deq_gap_ns) {
            std::fprintf(stderr,
                "WARN %s @offered=%lluHz: max_deq_gap=%.0f ns is %.0fx median"
                " inter-dequeue (%.1f ns) — possible consumer stall\n",
                variant_name, (unsigned long long)offered_rate_hz,
                max_deq_gap_ns, max_deq_gap_ns / median_deq_gap_ns,
                median_deq_gap_ns);
        }
    }
}

static void bin_run(const std::vector<uint64_t>& enq_ts,
                    const std::vector<uint64_t>& deq_ts,
                    double ns_per_cycle,
                    RunResult& result,
                    crucible::WarmupVerify* wv,
                    const char* variant_name,
                    uint64_t offered_rate_hz) {
    crucible::Histogram run_hist;
    for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
        if (deq_ts[i] == 0) {
            std::fprintf(stderr, "WARN: mutex-condvar item %zu not consumed\n", i);
            continue;  // skip — passing zero would underflow uint64_t subtraction
        }
        const uint64_t latency_ns =
            static_cast<uint64_t>((deq_ts[i] - enq_ts[i]) * ns_per_cycle);
        run_hist.record(latency_ns);
        if (wv && wv->enabled) {
            if (i < 10'000)        wv->early.record(latency_ns);
            else if (i >= 100'000) wv->late.record(latency_ns);
        }
    }
    if (run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1] > 0) {
        std::fprintf(stderr,
            "WARN: %llu sample(s) in top bucket (likely kernel preemption)\n",
            (unsigned long long)run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1]);
        result.top_bucket_count += run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1];
    }
    result.hist.merge(run_hist);
    emit_stall_diagnostic(enq_ts, deq_ts, ns_per_cycle, variant_name, offered_rate_hz,
                          run_hist.percentile(99.0), run_hist.percentile(99.9));
}

// ─── M8: wall-clock accumulation helper ──────────────────────────────────────

static inline void accumulate_wall_time(RunResult& r,
                                        const timespec& t0,
                                        const timespec& t1) {
    r.wall_ns_total += static_cast<double>(
        (t1.tv_sec - t0.tv_sec) * 1'000'000'000LL + (t1.tv_nsec - t0.tv_nsec));
}

// ─── M9: shared run scaffold ──────────────────────────────────────────────────
// Policy interface:
//   reset()                              — reinit queue/state for a fresh run
//   consume(deq_ts, warmup_consumed)     — consumer thread body (warmup + measure)
//   produce_warmup()                     — push ITEMS_WARMUP warmup items
//   produce_measured(enq_ts, period_cyc) — push ITEMS_MEASURED items with TSC pacing
//   signal_producer_done()               — notify consumer of EOF (no-op for lock-free)

template <typename Policy>
static RunResult run_spsc_variant(double ns_per_cycle, uint64_t rate_hz,
                                   crucible::WarmupVerify* wv, Policy policy,
                                   const char* variant_name) {
    const uint64_t period_cycles = crucible::pacing_period_cycles(rate_hz, ns_per_cycle);

    RunResult result;
    std::vector<uint64_t> enq_ts(ITEMS_MEASURED);
    std::vector<uint64_t> deq_ts(ITEMS_MEASURED);

    for (size_t run = 0; run < NUM_RUNS; ++run) {
        policy.reset();
        std::fill(deq_ts.begin(), deq_ts.end(), uint64_t{0});

        std::atomic<bool>   consumer_ready{false};
        std::atomic<bool>   start_signal{false};
        std::atomic<size_t> warmup_consumed{0};

        std::thread consumer([&] {
            crucible::pin_to_core(CONSUMER_CORE);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) {}
            policy.consume(deq_ts, warmup_consumed);
        });

        crucible::pin_to_core(PRODUCER_CORE);
        while (!consumer_ready.load(std::memory_order_acquire)) {}
        start_signal.store(true, std::memory_order_release);

        policy.produce_warmup();
        while (warmup_consumed.load(std::memory_order_acquire) < ITEMS_WARMUP)
            std::this_thread::yield();

        struct timespec t0{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t0);

        policy.produce_measured(enq_ts, period_cycles);
        policy.signal_producer_done();

        consumer.join();

        struct timespec t1{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
        accumulate_wall_time(result, t0, t1);

        bin_run(enq_ts, deq_ts, ns_per_cycle, result, wv, variant_name, rate_hz);
    }
    return result;
}

// ─── Lockfree queue adapters ──────────────────────────────────────────────────

struct HandrolledAdapter {
    static constexpr const char* name = "lockfree-handrolled";
    using Queue = SPSCQueue<MarketTick, QUEUE_DEPTH>;
    static bool try_pop(Queue& q, MarketTick& t)        { return q.try_pop(t); }
    static bool try_push(Queue& q, const MarketTick& t) { return q.try_push(t); }
};

struct BoostAdapter {
    static constexpr const char* name = "lockfree-boost";
    using Queue = boost::lockfree::spsc_queue<
        MarketTick, boost::lockfree::capacity<QUEUE_DEPTH>>;
    static bool try_pop(Queue& q, MarketTick& t)        { return q.pop(t); }
    static bool try_push(Queue& q, const MarketTick& t) { return q.push(t); }
};

// ─── Policy: lockfree (handrolled or boost via adapter) ───────────────────────

template <typename Adapter>
struct LockfreePolicy {
    using Queue = typename Adapter::Queue;
    std::unique_ptr<Queue> q;

    void reset() { q = std::make_unique<Queue>(); }

    void consume(std::vector<uint64_t>& deq_ts, std::atomic<size_t>& warmup_consumed) {
        size_t warmup_done = 0;
        while (warmup_done < ITEMS_WARMUP) {
            MarketTick t;
            if (Adapter::try_pop(*q, t)) {
                ++warmup_done;
                warmup_consumed.store(warmup_done, std::memory_order_release);
            }
        }
        size_t measured = 0;
        while (measured < ITEMS_MEASURED) {
            MarketTick t;
            if (Adapter::try_pop(*q, t)) {
                deq_ts[t.seq] = crucible::rdtscp_ordered();
                ++measured;
            }
        }
    }

    void produce_warmup() {
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            MarketTick t{uint32_t(i), 1, WARMUP_SEQ};
            while (!Adapter::try_push(*q, t)) {}
        }
    }

    void produce_measured(std::vector<uint64_t>& enq_ts, uint64_t period_cycles) {
        uint64_t next_release = crucible::rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = crucible::rdtscp_ordered();
            while (!Adapter::try_push(*q, t)) {}
        }
    }

    void signal_producer_done() {}
};

using HandrolledPolicy = LockfreePolicy<HandrolledAdapter>;
using BoostPolicy      = LockfreePolicy<BoostAdapter>;

// ─── Policy: mutex-condvar (bounded) ─────────────────────────────────────────
// Uses two condition variables for symmetric back-pressure:
//   cv_not_empty — consumer waits here when queue is empty
//   cv_not_full  — producer waits here when queue is at QUEUE_DEPTH capacity

struct MutexCondvarPolicy {
    struct State {
        std::queue<MarketTick>  q;
        std::mutex              mtx;
        std::condition_variable cv_not_empty;
        std::condition_variable cv_not_full;
        bool                    producer_done_flag = false;
    };
    std::unique_ptr<State> s;

    void reset() { s = std::make_unique<State>(); }

    void consume(std::vector<uint64_t>& deq_ts, std::atomic<size_t>& warmup_consumed) {
        size_t warmup_done = 0;
        size_t processed   = 0;
        const size_t total = ITEMS_WARMUP + ITEMS_MEASURED;

        while (processed < total) {
            MarketTick t;
            {
                std::unique_lock<std::mutex> lk(s->mtx);
                s->cv_not_empty.wait(lk, [&] { return !s->q.empty() || s->producer_done_flag; });
                if (s->q.empty()) break;
                t = s->q.front();
                s->q.pop();
            }
            s->cv_not_full.notify_one();

            if (t.seq < ITEMS_MEASURED) {
                deq_ts[t.seq] = crucible::rdtscp_ordered();
            } else {
                ++warmup_done;
                warmup_consumed.store(warmup_done, std::memory_order_release);
            }
            ++processed;
        }
    }

    void produce_warmup() {
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            {
                std::unique_lock<std::mutex> lk(s->mtx);
                s->cv_not_full.wait(lk, [&] { return s->q.size() < QUEUE_DEPTH; });
                s->q.push({uint32_t(i), 1, WARMUP_SEQ});
            }
            s->cv_not_empty.notify_one();
        }
    }

    void produce_measured(std::vector<uint64_t>& enq_ts, uint64_t period_cycles) {
        uint64_t next_release = crucible::rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = crucible::rdtscp_ordered();
            {
                std::unique_lock<std::mutex> lk(s->mtx);
                s->cv_not_full.wait(lk, [&] { return s->q.size() < QUEUE_DEPTH; });
                s->q.push(t);
            }
            s->cv_not_empty.notify_one();
        }
    }

    void signal_producer_done() {
        {
            std::lock_guard<std::mutex> lk(s->mtx);
            s->producer_done_flag = true;
        }
        s->cv_not_empty.notify_all();
    }
};

// ─── Variant dispatch functions ───────────────────────────────────────────────

static RunResult run_lockfree_handrolled(double ns_per_cycle, uint64_t rate_hz,
                                          crucible::WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, HandrolledPolicy{}, "lockfree-handrolled");
}

static RunResult run_lockfree_boost(double ns_per_cycle, uint64_t rate_hz,
                                     crucible::WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, BoostPolicy{}, "lockfree-boost");
}

static RunResult run_mutex_condvar(double ns_per_cycle, uint64_t rate_hz,
                                    crucible::WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, MutexCondvarPolicy{}, "mutex-condvar");
}

// ─── Dispatch ────────────────────────────────────────────────────────────────

static RunResult run_variant(std::string_view variant, double ns_per_cycle,
                              uint64_t rate_hz, crucible::WarmupVerify* wv) {
    if (variant == "lockfree-handrolled") return run_lockfree_handrolled(ns_per_cycle, rate_hz, wv);
    if (variant == "lockfree-boost")      return run_lockfree_boost(ns_per_cycle, rate_hz, wv);
    /* mutex-condvar */                   return run_mutex_condvar(ns_per_cycle, rate_hz, wv);
}

// ─── JSON emission ───────────────────────────────────────────────────────────

static std::string emit_json_string(const char* variant,
                                     const char* mode_str,
                                     uint64_t offered_rate_hz,
                                     const RunResult& r,
                                     double calibration_drift_pct) {
    const auto& h = r.hist;
    const double total_items = static_cast<double>(ITEMS_MEASURED) * NUM_RUNS;
    const double ops_per_sec = total_items / (r.wall_ns_total * 1e-9);

    const double median = static_cast<double>(h.percentile(50.0));
    const double min_ns = static_cast<double>(h.total ? h.minval : 0);
    const double p25    = static_cast<double>(h.percentile(25.0));
    const double p75    = static_cast<double>(h.percentile(75.0));
    const double p99    = static_cast<double>(h.percentile(99.0));
    const double iqr    = p75 - p25;

    const std::string rate_field = std::to_string(offered_rate_hz);

    // Build into dynamic std::string: counts_json() alone is ~769 chars for 384 buckets,
    // which silently truncated the old hdr[1024] and produced invalid JSON.
    char hdr[512];  // scalar fields only — bounded; ~200 chars worst-case
    std::snprintf(hdr, sizeof(hdr),
        "{"
        "\"variant\":\"%s\","
        "\"mode\":\"%s\","
        "\"offered_rate_hz\":%s,"
        "\"n\":%zu,"
        "\"items_measured\":%zu,"
        "\"items_warmup\":%zu,"
        "\"iterations\":%zu,"
        "\"ns_per_op\":{\"median\":%.1f,\"min\":%.1f,\"p99\":%.1f,\"iqr\":%.1f},"
        "\"ops_per_sec\":%.0f,"
        "\"latency_ns\":{"
          "\"scheme\":\"log2_subbuckets_16\","
          "\"percentile_convention\":\"log2_bucket_midpoint\","
          "\"bucket_count\":%zu,"
          "\"min_bucket_ns\":1,"
          "\"counts\":",
        variant,
        mode_str,
        rate_field.c_str(),
        QUEUE_DEPTH,
        ITEMS_MEASURED,
        ITEMS_WARMUP,
        NUM_RUNS,
        median, min_ns, p99, iqr,
        ops_per_sec,
        crucible::HISTOGRAM_BUCKET_COUNT);

    char trailer[64];
    std::snprintf(trailer, sizeof(trailer),
        "},"
        "\"top_bucket_count\":%zu,"
        "\"calibration_drift_pct\":%.4f"
        "}",
        r.top_bucket_count,
        calibration_drift_pct);

    std::string result = crucible::assemble_histogram_json(hdr, h, trailer);
    assert(!result.empty() && result.back() == '}');
    return result;
}

// ─── Stress test helpers ──────────────────────────────────────────────────────

static bool verify_stress(const std::vector<uint64_t>& received, size_t n, const char* label) {
    for (size_t i = 0; i < n; ++i) {
        if (received[i] != uint64_t(i)) {
            std::fprintf(stderr, "STRESS FAIL [%s]: pos %zu got %llu\n",
                label, i, (unsigned long long)received[i]);
            return false;
        }
    }
    return true;
}

template <typename Adapter>
static bool run_lockfree_stress(size_t n) {
    typename Adapter::Queue q;
    std::vector<uint64_t> received(n, UINT64_MAX);

    std::thread cons([&] {
        crucible::pin_to_core(CONSUMER_CORE);
        size_t got = 0;
        while (got < n) {
            MarketTick t;
            if (Adapter::try_pop(q, t)) received[got++] = t.seq;
        }
    });
    crucible::pin_to_core(PRODUCER_CORE);
    for (size_t i = 0; i < n; ++i) {
        MarketTick t{uint32_t(i), 1, uint64_t(i)};
        while (!Adapter::try_push(q, t)) {}
    }
    cons.join();
    return verify_stress(received, n, Adapter::name);
}

// ─── Main ────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: %s <variant> [--mode paced|saturated|sweep]\n"
            "       %s --machine-info\n"
            "       %s --stress-test [variant]\n"
            "Variants: lockfree-handrolled | lockfree-boost | mutex-condvar\n",
            argv[0], argv[0], argv[0]);
        return 1;
    }

    // ── Machine info ─────────────────────────────────────────────────────────
    if (std::string_view(argv[1]) == "--machine-info") {
        double ns_per_cycle = crucible::calibrate_tsc();
        std::printf("{%s,\"tsc_ns_per_cycle\":%.6f}\n",
            crucible::machine_info_json().c_str(), ns_per_cycle);
        return 0;
    }

    // ── Stress test ──────────────────────────────────────────────────────────
    if (std::string_view(argv[1]) == "--stress-test") {
        const std::vector<std::string> targets =
            (argc >= 3)
            ? std::vector<std::string>{argv[2]}
            : std::vector<std::string>{"lockfree-handrolled", "lockfree-boost", "mutex-condvar"};

        static constexpr size_t STRESS_ITEMS = 10'000'000;
        int failures = 0;

        auto stress_lockfree_hr    = [&] { return run_lockfree_stress<HandrolledAdapter>(STRESS_ITEMS); };
        auto stress_lockfree_boost = [&] { return run_lockfree_stress<BoostAdapter>(STRESS_ITEMS); };

        // Bounded mutex stress test — matches benchmark's back-pressure semantics
        auto stress_mutex = [&] {
            std::queue<MarketTick>  q;
            std::mutex              mtx;
            std::condition_variable cv_not_empty, cv_not_full;
            bool prod_done = false;
            std::vector<uint64_t> received(STRESS_ITEMS, UINT64_MAX);

            std::thread cons([&] {
                crucible::pin_to_core(CONSUMER_CORE);
                size_t got = 0;
                while (got < STRESS_ITEMS) {
                    MarketTick t;
                    {
                        std::unique_lock<std::mutex> lk(mtx);
                        cv_not_empty.wait(lk, [&] { return !q.empty() || prod_done; });
                        if (q.empty()) break;
                        t = q.front();
                        q.pop();
                    }
                    cv_not_full.notify_one();
                    received[got++] = t.seq;
                }
            });
            crucible::pin_to_core(PRODUCER_CORE);
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                {
                    std::unique_lock<std::mutex> lk(mtx);
                    cv_not_full.wait(lk, [&] { return q.size() < QUEUE_DEPTH; });
                    q.push({uint32_t(i), 1, uint64_t(i)});
                }
                cv_not_empty.notify_one();
            }
            { std::lock_guard<std::mutex> lk(mtx); prod_done = true; }
            cv_not_empty.notify_all();
            cons.join();

            return verify_stress(received, STRESS_ITEMS, "mutex-condvar");
        };

        for (const auto& t : targets) {
            std::fprintf(stderr, "==> stress-test %s (%zu items)...\n", t.c_str(), STRESS_ITEMS);
            bool ok = false;
            if (t == "lockfree-handrolled") ok = stress_lockfree_hr();
            else if (t == "lockfree-boost") ok = stress_lockfree_boost();
            else if (t == "mutex-condvar")  ok = stress_mutex();
            else { std::fprintf(stderr, "ERROR: unknown variant '%s'\n", t.c_str()); ++failures; continue; }

            if (ok) std::printf("OK  %s: %zu items, zero losses, FIFO order verified\n", t.c_str(), STRESS_ITEMS);
            else  { std::printf("FAIL %s\n", t.c_str()); ++failures; }
        }
        return failures == 0 ? 0 : 1;
    }

    // ── Variant measurement ──────────────────────────────────────────────────

    const std::string_view variant = argv[1];
    const bool valid_variant = (variant == "lockfree-handrolled" ||
                                variant == "lockfree-boost"      ||
                                variant == "mutex-condvar");
    if (!valid_variant) {
        std::fprintf(stderr, "ERROR: unknown variant '%s'\n", argv[1]);
        std::fprintf(stderr, "Valid: lockfree-handrolled | lockfree-boost | mutex-condvar\n");
        return 1;
    }

    // Parse options
    BenchConfig cfg;
    for (int i = 2; i < argc; ++i) {
        std::string_view arg = argv[i];
        if (arg == "--mode" && i + 1 < argc) {
            std::string_view m = argv[++i];
            if      (m == "paced")     cfg.mode = Mode::Paced;
            else if (m == "saturated") cfg.mode = Mode::Saturated;
            else if (m == "sweep")     cfg.mode = Mode::Sweep;
            else { std::fprintf(stderr, "ERROR: unknown mode '%s'\n", argv[i]); return 1; }
        } else if (arg == "--rate-hz" && i + 1 < argc) {
            cfg.rate_hz = static_cast<uint64_t>(std::stoull(argv[++i]));
        } else if (arg == "--rate-from" && i + 1 < argc) {
            cfg.rate_from_hz = static_cast<uint64_t>(std::stoull(argv[++i]));
        } else if (arg == "--rate-to" && i + 1 < argc) {
            cfg.rate_to_hz = static_cast<uint64_t>(std::stoull(argv[++i]));
        } else if (arg == "--steps" && i + 1 < argc) {
            cfg.steps = std::stoi(argv[++i]);
        } else if (arg == "--verify-warmup") {
            cfg.verify_warmup = true;
        } else {
            std::fprintf(stderr, "ERROR: unknown option '%s'\n", argv[i]);
            return 1;
        }
    }

    const double ns_per_cycle = crucible::calibrate_tsc();
    std::fprintf(stderr, "TSC calibration: %.6f ns/cycle\n", ns_per_cycle);

    crucible::WarmupVerify wv;
    wv.enabled = cfg.verify_warmup;

    std::string output;

    if (cfg.mode == Mode::Sweep) {
        // Log-spaced sweep from rate_from_hz to rate_to_hz
        const int    n    = std::max(cfg.steps, 1);
        const double lo   = static_cast<double>(cfg.rate_from_hz);
        const double hi   = static_cast<double>(cfg.rate_to_hz);

        output = "[\n";
        for (int s = 0; s < n; ++s) {
            const double ratio   = (n > 1) ? std::pow(hi / lo, static_cast<double>(s) / (n - 1)) : 1.0;
            const uint64_t rate  = static_cast<uint64_t>(lo * ratio);
            std::fprintf(stderr, "  sweep step %d/%d: %.0f Hz\n", s + 1, n, static_cast<double>(rate));

            const RunResult r = run_variant(variant, ns_per_cycle, rate, &wv);
            const double ns_per_cycle_step = crucible::calibrate_tsc();
            const double drift = std::abs(ns_per_cycle_step - ns_per_cycle) / ns_per_cycle * 100.0;

            output += emit_json_string(argv[1], "sweep", rate, r, drift);
            if (s + 1 < n) output += ",\n";
        }
        output += "\n]";
    } else {
        // Single paced or saturated run
        const uint64_t rate = (cfg.mode == Mode::Saturated) ? 0 : cfg.rate_hz;
        const char* mode_str = (cfg.mode == Mode::Saturated) ? "saturated" : "paced";

        const RunResult r = run_variant(variant, ns_per_cycle, rate, &wv);

        const double ns_per_cycle_post = crucible::calibrate_tsc();
        const double drift_pct = std::abs(ns_per_cycle_post - ns_per_cycle) / ns_per_cycle * 100.0;
        if (drift_pct > 0.1)
            std::fprintf(stderr, "WARN: TSC drift %.4f%% (threshold 0.1%%)\n", drift_pct);

        output = "[\n" + emit_json_string(argv[1], mode_str, rate, r, drift_pct) + "\n]";
    }

    std::printf("%s\n", output.c_str());

    // ── Warmup verification report (stderr only, not in JSON) ────────────────
    wv.report();

    return 0;
}
