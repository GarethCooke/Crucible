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

#include "histogram.h"
#include "machine_info.h"
#include "spsc_queue.h"
#include "tick.h"

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

// ─── TSC helpers ─────────────────────────────────────────────────────────────

static inline uint64_t rdtscp_ordered() noexcept {
    unsigned aux;
    uint64_t t = __rdtscp(&aux);
    _mm_lfence();  // prevent subsequent instructions from executing before rdtscp retires
    return t;
}

// Calibrate TSC against CLOCK_MONOTONIC_RAW over a 100 ms window.
// Verifies constant_tsc and nonstop_tsc in /proc/cpuinfo before running.
static double calibrate_tsc() {
    bool has_constant = false, has_nonstop = false;
    if (FILE* f = std::fopen("/proc/cpuinfo", "r")) {
        char line[256];
        while (std::fgets(line, sizeof(line), f)) {
            if (std::strstr(line, "constant_tsc"))  has_constant = true;
            if (std::strstr(line, "nonstop_tsc"))   has_nonstop  = true;
        }
        std::fclose(f);
    }
    if (!has_constant || !has_nonstop) {
        std::fprintf(stderr,
            "ERROR: TSC stability flags missing in /proc/cpuinfo.\n"
            "  constant_tsc: %s\n  nonstop_tsc:  %s\n"
            "  rdtscp-based timing requires both flags.\n",
            has_constant ? "present" : "MISSING",
            has_nonstop  ? "present" : "MISSING");
        std::exit(1);
    }

    auto mono_ns = []() -> uint64_t {
        struct timespec ts{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
        return static_cast<uint64_t>(ts.tv_sec) * 1'000'000'000ULL
             + static_cast<uint64_t>(ts.tv_nsec);
    };

    const uint64_t t0_ns  = mono_ns();
    const uint64_t t0_cyc = rdtscp_ordered();
    while (mono_ns() - t0_ns < 100'000'000ULL) { /* busy-wait 100 ms */ }
    const uint64_t t1_cyc = rdtscp_ordered();
    const uint64_t t1_ns  = mono_ns();

    return static_cast<double>(t1_ns - t0_ns) / static_cast<double>(t1_cyc - t0_cyc);
}

// ─── Thread affinity ─────────────────────────────────────────────────────────

static void pin_to_core(int core) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(core, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpuset), &cpuset) != 0) {
        std::fprintf(stderr, "ERROR: pthread_setaffinity_np to core %d failed\n", core);
        std::exit(1);
    }
    std::this_thread::yield();
    const int actual = sched_getcpu();
    if (actual != core) {
        std::fprintf(stderr,
            "ERROR: affinity mismatch — expected core %d, running on %d\n", core, actual);
        std::exit(1);
    }
}

// ─── Run result ──────────────────────────────────────────────────────────────

struct RunResult {
    crucible::Histogram hist;
    double              wall_ns_total  = 0.0;
    size_t              top_bucket_count = 0;
};

// ─── Warmup verification ─────────────────────────────────────────────────────

struct WarmupVerify {
    bool                enabled = false;
    crucible::Histogram early;  // items 0..9_999 of measurement
    crucible::Histogram late;   // items 100_000+ of measurement
};

// ─── Pacing helper ───────────────────────────────────────────────────────────

// Compute the TSC period for a given offered rate.
// Returns 0 for saturated mode (no pacing).
static inline uint64_t pacing_period_cycles(uint64_t rate_hz, double ns_per_cycle) noexcept {
    if (rate_hz == 0) return 0;
    return static_cast<uint64_t>(1.0e9 / (static_cast<double>(rate_hz) * ns_per_cycle));
}

// ─── Binning helper ──────────────────────────────────────────────────────────

static void bin_run(const std::vector<uint64_t>& enq_ts,
                    const std::vector<uint64_t>& deq_ts,
                    double ns_per_cycle,
                    RunResult& result,
                    WarmupVerify* wv) {
    crucible::Histogram run_hist;
    for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
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
                                   WarmupVerify* wv, Policy policy) {
    const uint64_t period_cycles = pacing_period_cycles(rate_hz, ns_per_cycle);

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
            pin_to_core(CONSUMER_CORE);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) {}
            policy.consume(deq_ts, warmup_consumed);
        });

        pin_to_core(PRODUCER_CORE);
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

        bin_run(enq_ts, deq_ts, ns_per_cycle, result, wv);
    }
    return result;
}

// ─── Policy: lockfree-handrolled ─────────────────────────────────────────────

struct HandrolledPolicy {
    using Queue = SPSCQueue<MarketTick, QUEUE_DEPTH>;
    std::unique_ptr<Queue> q;

    void reset() { q = std::make_unique<Queue>(); }

    void consume(std::vector<uint64_t>& deq_ts, std::atomic<size_t>& warmup_consumed) {
        size_t warmup_done = 0;
        while (warmup_done < ITEMS_WARMUP) {
            MarketTick t;
            if (q->try_pop(t)) {
                ++warmup_done;
                warmup_consumed.store(warmup_done, std::memory_order_release);
            }
        }
        size_t measured = 0;
        while (measured < ITEMS_MEASURED) {
            MarketTick t;
            if (q->try_pop(t)) {
                deq_ts[t.seq] = rdtscp_ordered();
                ++measured;
            }
        }
    }

    void produce_warmup() {
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            MarketTick t{uint32_t(i), 1, WARMUP_SEQ};
            while (!q->try_push(t)) {}
        }
    }

    void produce_measured(std::vector<uint64_t>& enq_ts, uint64_t period_cycles) {
        uint64_t next_release = rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
            while (!q->try_push(t)) {}
        }
    }

    void signal_producer_done() {}
};

// ─── Policy: lockfree-boost ───────────────────────────────────────────────────

struct BoostPolicy {
    using Queue = boost::lockfree::spsc_queue<
        MarketTick, boost::lockfree::capacity<QUEUE_DEPTH>>;
    std::unique_ptr<Queue> q;

    void reset() { q = std::make_unique<Queue>(); }

    void consume(std::vector<uint64_t>& deq_ts, std::atomic<size_t>& warmup_consumed) {
        size_t warmup_done = 0;
        while (warmup_done < ITEMS_WARMUP) {
            MarketTick t;
            if (q->pop(t)) {
                ++warmup_done;
                warmup_consumed.store(warmup_done, std::memory_order_release);
            }
        }
        size_t measured = 0;
        while (measured < ITEMS_MEASURED) {
            MarketTick t;
            if (q->pop(t)) {
                deq_ts[t.seq] = rdtscp_ordered();
                ++measured;
            }
        }
    }

    void produce_warmup() {
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            MarketTick t{uint32_t(i), 1, WARMUP_SEQ};
            while (!q->push(t)) {}
        }
    }

    void produce_measured(std::vector<uint64_t>& enq_ts, uint64_t period_cycles) {
        uint64_t next_release = rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
            while (!q->push(t)) {}
        }
    }

    void signal_producer_done() {}
};

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
                deq_ts[t.seq] = rdtscp_ordered();
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
        uint64_t next_release = rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
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
                                          WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, HandrolledPolicy{});
}

static RunResult run_lockfree_boost(double ns_per_cycle, uint64_t rate_hz,
                                     WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, BoostPolicy{});
}

static RunResult run_mutex_condvar(double ns_per_cycle, uint64_t rate_hz,
                                    WarmupVerify* wv) {
    return run_spsc_variant(ns_per_cycle, rate_hz, wv, MutexCondvarPolicy{});
}

// ─── Dispatch ────────────────────────────────────────────────────────────────

static RunResult run_variant(std::string_view variant, double ns_per_cycle,
                              uint64_t rate_hz, WarmupVerify* wv) {
    if (variant == "lockfree-handrolled") return run_lockfree_handrolled(ns_per_cycle, rate_hz, wv);
    if (variant == "lockfree-boost")      return run_lockfree_boost(ns_per_cycle, rate_hz, wv);
    /* mutex-condvar */                   return run_mutex_condvar(ns_per_cycle, rate_hz, wv);
}

// ─── JSON emission ───────────────────────────────────────────────────────────

static std::string emit_json_string(const char* variant,
                                     const char* mode_str,
                                     uint64_t offered_rate_hz,
                                     const RunResult& r,
                                     double ns_per_cycle,
                                     double calibration_drift_pct) {
    (void)ns_per_cycle;
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
    char hdr[512];  // scalar fields only — bounded; 384 chars worst-case
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

    std::string result;
    result.reserve(512 + crucible::HISTOGRAM_BUCKET_COUNT * 8 + 256);
    result += hdr;
    result += h.counts_json();
    result += ",\"stats\":";
    result += h.stats_json();
    result += trailer;

    assert(!result.empty() && result.back() == '}');
    return result;
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
        double ns_per_cycle = calibrate_tsc();
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

        auto stress_lockfree_hr = [&] {
            SPSCQueue<MarketTick, QUEUE_DEPTH> q;
            std::vector<uint64_t> received(STRESS_ITEMS, UINT64_MAX);
            std::thread cons([&] {
                pin_to_core(CONSUMER_CORE);
                size_t got = 0;
                while (got < STRESS_ITEMS) {
                    MarketTick t;
                    if (q.try_pop(t)) received[got++] = t.seq;
                }
            });
            pin_to_core(PRODUCER_CORE);
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                MarketTick t{uint32_t(i), 1, uint64_t(i)};
                while (!q.try_push(t)) {}
            }
            cons.join();
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                if (received[i] != uint64_t(i)) {
                    std::fprintf(stderr, "STRESS FAIL [lockfree-handrolled]: pos %zu got %llu\n",
                        i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
        };

        auto stress_lockfree_boost = [&] {
            boost::lockfree::spsc_queue<MarketTick, boost::lockfree::capacity<QUEUE_DEPTH>> q;
            std::vector<uint64_t> received(STRESS_ITEMS, UINT64_MAX);
            std::thread cons([&] {
                pin_to_core(CONSUMER_CORE);
                size_t got = 0;
                while (got < STRESS_ITEMS) {
                    MarketTick t;
                    if (q.pop(t)) received[got++] = t.seq;
                }
            });
            pin_to_core(PRODUCER_CORE);
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                MarketTick t{uint32_t(i), 1, uint64_t(i)};
                while (!q.push(t)) {}
            }
            cons.join();
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                if (received[i] != uint64_t(i)) {
                    std::fprintf(stderr, "STRESS FAIL [lockfree-boost]: pos %zu got %llu\n",
                        i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
        };

        // Bounded mutex stress test — matches benchmark's back-pressure semantics
        auto stress_mutex = [&] {
            std::queue<MarketTick>  q;
            std::mutex              mtx;
            std::condition_variable cv_not_empty, cv_not_full;
            bool prod_done = false;
            std::vector<uint64_t> received(STRESS_ITEMS, UINT64_MAX);

            std::thread cons([&] {
                pin_to_core(CONSUMER_CORE);
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
            pin_to_core(PRODUCER_CORE);
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

            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                if (received[i] != uint64_t(i)) {
                    std::fprintf(stderr, "STRESS FAIL [mutex-condvar]: pos %zu got %llu\n",
                        i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
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

    const double ns_per_cycle = calibrate_tsc();
    std::fprintf(stderr, "TSC calibration: %.6f ns/cycle\n", ns_per_cycle);

    WarmupVerify wv;
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
            const double drift = 0.0;  // per-step drift omitted; calibrate once outside loop

            output += emit_json_string(argv[1], "sweep", rate, r, ns_per_cycle, drift);
            if (s + 1 < n) output += ",\n";
        }
        output += "\n]";
    } else {
        // Single paced or saturated run
        const uint64_t rate = (cfg.mode == Mode::Saturated) ? 0 : cfg.rate_hz;
        const char* mode_str = (cfg.mode == Mode::Saturated) ? "saturated" : "paced";

        const RunResult r = run_variant(variant, ns_per_cycle, rate, &wv);

        const double ns_per_cycle_post = calibrate_tsc();
        const double drift_pct = std::abs(ns_per_cycle_post - ns_per_cycle) / ns_per_cycle * 100.0;
        if (drift_pct > 0.1)
            std::fprintf(stderr, "WARN: TSC drift %.4f%% (threshold 0.1%%)\n", drift_pct);

        output = "[\n" + emit_json_string(argv[1], mode_str, rate, r, ns_per_cycle, drift_pct) + "\n]";
    }

    std::printf("%s\n", output.c_str());

    // ── Warmup verification report (stderr only, not in JSON) ────────────────
    if (wv.enabled) {
        std::fprintf(stderr,
            "\n=== Warmup verification ===\n"
            "Items 0-9,999   (early): p50=%llu ns  p99=%llu ns\n"
            "Items 100,000+  (late):  p50=%llu ns  p99=%llu ns\n",
            (unsigned long long)wv.early.percentile(50.0),
            (unsigned long long)wv.early.percentile(99.0),
            (unsigned long long)wv.late.percentile(50.0),
            (unsigned long long)wv.late.percentile(99.0));
    }

    return 0;
}
