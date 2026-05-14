// SPSC queue latency benchmark — Demo 04
// Usage: 04-spsc-queue <variant>           (lockfree-handrolled | lockfree-boost | mutex-condvar)
//        04-spsc-queue --machine-info
//        04-spsc-queue --stress-test        (runs all 3 variants, 10M items each, verifies delivery)
//        04-spsc-queue --stress-test <var>  (stress-tests one variant)
//
// Measures end-to-end enqueue→dequeue latency across 5 × 1M items.
// Producer pinned to core 4, consumer to core 5 (same CCX on Zen 2 3800X).
// Timestamps: rdtscp with lfence, calibrated against CLOCK_MONOTONIC_RAW.
// Histogram bins happen post-run; the hot loop only writes raw cycle counts.

#include "histogram.h"
#include "machine_info.h"
#include "spsc_queue.h"
#include "tick.h"

#include <boost/lockfree/spsc_queue.hpp>

#include <atomic>
#include <chrono>
#include <condition_variable>
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

#include <x86intrin.h>  // __rdtscp, _mm_lfence

// ─── Constants ───────────────────────────────────────────────────────────────

static constexpr size_t QUEUE_DEPTH    = 1024;
static constexpr size_t ITEMS_MEASURED = 1'000'000;
static constexpr size_t ITEMS_WARMUP   = 100'000;
static constexpr size_t NUM_RUNS       = 5;
static constexpr int    PRODUCER_CORE  = 4;
static constexpr int    CONSUMER_CORE  = 5;

// Warmup items use this sentinel so the consumer can skip them without counting.
static constexpr uint64_t WARMUP_SEQ = ~uint64_t(0);

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
    // Verify TSC stability flags.
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

    // Spin for 100 ms — avoids sleep() imprecision on the measurement interval.
    while (mono_ns() - t0_ns < 100'000'000ULL) { /* busy-wait */ }

    const uint64_t t1_cyc = rdtscp_ordered();
    const uint64_t t1_ns  = mono_ns();

    const double delta_ns  = static_cast<double>(t1_ns  - t0_ns);
    const double delta_cyc = static_cast<double>(t1_cyc - t0_cyc);
    return delta_ns / delta_cyc;
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
    // Yield once to let the scheduler honour the new affinity before verifying.
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
    double              wall_ns_total = 0.0;  // sum across all NUM_RUNS measurement phases
    size_t              top_bucket_count = 0;
};

// ─── Variant: lockfree-handrolled ────────────────────────────────────────────

static RunResult run_lockfree_handrolled(double ns_per_cycle) {
    using Queue = SPSCQueue<MarketTick, QUEUE_DEPTH>;

    RunResult result;

    // Per-run timestamp buffers — allocated once and reused.
    std::vector<uint64_t> enq_ts(ITEMS_MEASURED);
    std::vector<uint64_t> deq_ts(ITEMS_MEASURED);

    for (size_t run = 0; run < NUM_RUNS; ++run) {
        Queue q;

        std::atomic<bool> consumer_ready{false};
        std::atomic<bool> start_signal{false};
        std::atomic<bool> producer_done{false};
        double run_wall_ns = 0.0;

        // Consumer thread
        std::thread consumer([&] {
            pin_to_core(CONSUMER_CORE);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) {}

            // Warmup
            size_t warmup_done = 0;
            while (warmup_done < ITEMS_WARMUP) {
                MarketTick t;
                if (q.try_pop(t)) ++warmup_done;
            }

            // Measurement
            size_t measured = 0;
            while (measured < ITEMS_MEASURED) {
                MarketTick t;
                if (q.try_pop(t)) {
                    deq_ts[t.seq] = rdtscp_ordered();
                    ++measured;
                }
            }
        });

        pin_to_core(PRODUCER_CORE);
        while (!consumer_ready.load(std::memory_order_acquire)) {}
        start_signal.store(true, std::memory_order_release);

        // Warmup
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            MarketTick t{uint32_t(i), 1, WARMUP_SEQ};
            while (!q.try_push(t)) {}
        }

        // Measurement — wall clock starts here
        struct timespec t0{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t0);

        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
            while (!q.try_push(t)) {}
        }
        producer_done.store(true, std::memory_order_release);

        consumer.join();

        struct timespec t1{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
        run_wall_ns = static_cast<double>(
            (t1.tv_sec - t0.tv_sec) * 1'000'000'000LL +
            (t1.tv_nsec - t0.tv_nsec));
        result.wall_ns_total += run_wall_ns;

        // Bin latencies post-run
        crucible::Histogram run_hist;
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            const uint64_t latency_ns =
                static_cast<uint64_t>((deq_ts[i] - enq_ts[i]) * ns_per_cycle);
            run_hist.record(latency_ns);
        }
        if (run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1] > 0) {
            std::fprintf(stderr,
                "WARN [run %zu]: %llu sample(s) landed in the top bucket "
                "(likely kernel preemption or page fault)\n",
                run,
                (unsigned long long)run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1]);
            result.top_bucket_count += run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1];
        }
        result.hist.merge(run_hist);
    }

    return result;
}

// ─── Variant: lockfree-boost ─────────────────────────────────────────────────

static RunResult run_lockfree_boost(double ns_per_cycle) {
    using Queue = boost::lockfree::spsc_queue<
        MarketTick, boost::lockfree::capacity<QUEUE_DEPTH>>;

    RunResult result;
    std::vector<uint64_t> enq_ts(ITEMS_MEASURED);
    std::vector<uint64_t> deq_ts(ITEMS_MEASURED);

    for (size_t run = 0; run < NUM_RUNS; ++run) {
        Queue q;

        std::atomic<bool> consumer_ready{false};
        std::atomic<bool> start_signal{false};
        double run_wall_ns = 0.0;

        std::thread consumer([&] {
            pin_to_core(CONSUMER_CORE);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) {}

            size_t warmup_done = 0;
            while (warmup_done < ITEMS_WARMUP) {
                MarketTick t;
                if (q.pop(t)) ++warmup_done;
            }

            size_t measured = 0;
            while (measured < ITEMS_MEASURED) {
                MarketTick t;
                if (q.pop(t)) {
                    deq_ts[t.seq] = rdtscp_ordered();
                    ++measured;
                }
            }
        });

        pin_to_core(PRODUCER_CORE);
        while (!consumer_ready.load(std::memory_order_acquire)) {}
        start_signal.store(true, std::memory_order_release);

        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            MarketTick t{uint32_t(i), 1, WARMUP_SEQ};
            while (!q.push(t)) {}
        }

        struct timespec t0{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t0);

        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
            while (!q.push(t)) {}
        }

        consumer.join();

        struct timespec t1{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
        run_wall_ns = static_cast<double>(
            (t1.tv_sec - t0.tv_sec) * 1'000'000'000LL +
            (t1.tv_nsec - t0.tv_nsec));
        result.wall_ns_total += run_wall_ns;

        crucible::Histogram run_hist;
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            const uint64_t latency_ns =
                static_cast<uint64_t>((deq_ts[i] - enq_ts[i]) * ns_per_cycle);
            run_hist.record(latency_ns);
        }
        if (run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1] > 0) {
            std::fprintf(stderr,
                "WARN [run %zu]: %llu top-bucket sample(s)\n",
                run,
                (unsigned long long)run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1]);
            result.top_bucket_count += run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1];
        }
        result.hist.merge(run_hist);
    }

    return result;
}

// ─── Variant: mutex-condvar ──────────────────────────────────────────────────

static RunResult run_mutex_condvar(double ns_per_cycle) {
    RunResult result;
    std::vector<uint64_t> enq_ts(ITEMS_MEASURED);
    std::vector<uint64_t> deq_ts(ITEMS_MEASURED);

    for (size_t run = 0; run < NUM_RUNS; ++run) {
        std::queue<MarketTick> q;
        std::mutex             mtx;
        std::condition_variable cv;
        bool producer_done_flag = false;

        std::atomic<bool> consumer_ready{false};
        std::atomic<bool> start_signal{false};
        double run_wall_ns = 0.0;

        // warmup_consumed lets the producer wait for the consumer to drain warmup
        // without spinning on the lock (which would starve the condvar consumer).
        std::atomic<size_t> warmup_consumed{0};

        std::thread consumer([&] {
            pin_to_core(CONSUMER_CORE);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) {}

            // Single loop processes both warmup and measurement items in arrival order.
            // Warmup items (seq == WARMUP_SEQ) are counted but not timestamped.
            // Measurement items (seq < ITEMS_MEASURED) are timestamped.
            size_t warmup_done  = 0;
            size_t measured     = 0;
            const size_t total  = ITEMS_WARMUP + ITEMS_MEASURED;
            size_t processed    = 0;

            while (processed < total) {
                std::unique_lock<std::mutex> lk(mtx);
                cv.wait(lk, [&] { return !q.empty() || producer_done_flag; });
                if (q.empty()) break;
                auto t = q.front();
                q.pop();
                if (t.seq < ITEMS_MEASURED) {
                    // Timestamp immediately after pop, lock still held — consistent
                    // with lock-free path where we timestamp after try_pop returns.
                    deq_ts[t.seq] = rdtscp_ordered();
                    ++measured;
                } else {
                    ++warmup_done;
                    warmup_consumed.store(warmup_done, std::memory_order_release);
                }
                lk.unlock();
                ++processed;
            }
        });

        pin_to_core(PRODUCER_CORE);
        while (!consumer_ready.load(std::memory_order_acquire)) {}
        start_signal.store(true, std::memory_order_release);

        // Warmup
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            {
                std::lock_guard<std::mutex> lk(mtx);
                q.push({uint32_t(i), 1, WARMUP_SEQ});
            }
            cv.notify_one();
        }

        // Wait for warmup to drain. The consumer increments warmup_consumed via
        // an atomic — no lock contention between producer and consumer here.
        while (warmup_consumed.load(std::memory_order_acquire) < ITEMS_WARMUP) {
            std::this_thread::yield();
        }

        struct timespec t0{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t0);

        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            MarketTick t{uint32_t(i & 0xFFFF), 1, uint64_t(i)};
            enq_ts[i] = rdtscp_ordered();
            {
                std::lock_guard<std::mutex> lk(mtx);
                q.push(t);
            }
            cv.notify_one();
        }

        {
            std::lock_guard<std::mutex> lk(mtx);
            producer_done_flag = true;
        }
        cv.notify_all();

        consumer.join();

        struct timespec t1{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
        run_wall_ns = static_cast<double>(
            (t1.tv_sec - t0.tv_sec) * 1'000'000'000LL +
            (t1.tv_nsec - t0.tv_nsec));
        result.wall_ns_total += run_wall_ns;

        crucible::Histogram run_hist;
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (deq_ts[i] == 0) continue;  // item not yet consumed (shouldn't happen)
            const uint64_t latency_ns =
                static_cast<uint64_t>((deq_ts[i] - enq_ts[i]) * ns_per_cycle);
            run_hist.record(latency_ns);
        }
        if (run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1] > 0) {
            std::fprintf(stderr,
                "WARN [run %zu]: %llu top-bucket sample(s)\n",
                run,
                (unsigned long long)run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1]);
            result.top_bucket_count += run_hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1];
        }
        result.hist.merge(run_hist);
    }

    return result;
}

// ─── JSON emission ───────────────────────────────────────────────────────────

static void emit_json(const char* variant,
                      const RunResult& r,
                      double ns_per_cycle,
                      double calibration_drift_pct) {
    const auto& h = r.hist;

    // ops_per_sec: total items over total wall time of measurement phases
    const double total_items = static_cast<double>(ITEMS_MEASURED) * NUM_RUNS;
    const double ops_per_sec = total_items / (r.wall_ns_total * 1e-9);

    // ns_per_op stats derived from merged histogram (for throughput chart compat)
    const double median = static_cast<double>(h.percentile(50.0));
    const double min_ns = static_cast<double>(h.total ? h.minval : 0);
    const double p25    = static_cast<double>(h.percentile(25.0));
    const double p75    = static_cast<double>(h.percentile(75.0));
    const double p99    = static_cast<double>(h.percentile(99.0));
    const double iqr    = p75 - p25;

    std::printf(
        "{\n"
        "  \"variant\": \"%s\",\n"
        "  \"n\": %zu,\n"
        "  \"items_measured\": %zu,\n"
        "  \"items_warmup\": %zu,\n"
        "  \"iterations\": %zu,\n"
        "  \"ns_per_op\": {\"median\": %.1f, \"min\": %.1f, \"p99\": %.1f, \"iqr\": %.1f},\n"
        "  \"ops_per_sec\": %.0f,\n"
        "  \"latency_ns\": {\n"
        "    \"scheme\": \"log2_subbuckets_16\",\n"
        "    \"bucket_count\": %zu,\n"
        "    \"min_bucket_ns\": 1,\n"
        "    \"counts\": %s,\n"
        "    \"stats\": %s\n"
        "  },\n"
        "  \"top_bucket_count\": %zu,\n"
        "  \"calibration_drift_pct\": %.4f\n"
        "}\n",
        variant,
        QUEUE_DEPTH,
        ITEMS_MEASURED,
        ITEMS_WARMUP,
        NUM_RUNS,
        median, min_ns, p99, iqr,
        ops_per_sec,
        crucible::HISTOGRAM_BUCKET_COUNT,
        h.counts_json().c_str(),
        h.stats_json().c_str(),
        r.top_bucket_count,
        calibration_drift_pct);
}

// ─── Main ────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: %s <variant>  |  %s --machine-info\n"
            "Variants: lockfree-handrolled | lockfree-boost | mutex-condvar\n",
            argv[0], argv[0]);
        return 1;
    }

    if (std::string_view(argv[1]) == "--machine-info") {
        // Extend machine info JSON with TSC calibration result.
        double ns_per_cycle = calibrate_tsc();
        std::printf("{%s,\"tsc_ns_per_cycle\":%.6f}\n",
            crucible::machine_info_json().c_str(), ns_per_cycle);
        return 0;
    }

    // ── Stress test ──────────────────────────────────────────────────────────
    // Sends 10M items through each variant and verifies zero losses and
    // monotonically increasing seq delivery (FIFO property).
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
            std::atomic<bool> done{false};

            std::thread cons([&] {
                pin_to_core(CONSUMER_CORE);
                size_t got = 0;
                while (got < STRESS_ITEMS) {
                    MarketTick t;
                    if (q.try_pop(t)) received[got++] = t.seq;
                }
                done.store(true, std::memory_order_release);
            });
            pin_to_core(PRODUCER_CORE);
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                MarketTick t{uint32_t(i), 1, uint64_t(i)};
                while (!q.try_push(t)) {}
            }
            cons.join();

            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                if (received[i] != uint64_t(i)) {
                    std::fprintf(stderr, "STRESS FAIL [lockfree-handrolled]: "
                        "pos %zu expected seq %zu got %llu\n",
                        i, i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
        };

        auto stress_lockfree_boost = [&] {
            boost::lockfree::spsc_queue<MarketTick,
                boost::lockfree::capacity<QUEUE_DEPTH>> q;
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
                    std::fprintf(stderr, "STRESS FAIL [lockfree-boost]: "
                        "pos %zu expected seq %zu got %llu\n",
                        i, i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
        };

        auto stress_mutex = [&] {
            std::queue<MarketTick> q;
            std::mutex             mtx;
            std::condition_variable cv;
            bool prod_done = false;
            std::vector<uint64_t> received(STRESS_ITEMS, UINT64_MAX);

            std::thread cons([&] {
                pin_to_core(CONSUMER_CORE);
                size_t got = 0;
                while (got < STRESS_ITEMS) {
                    std::unique_lock<std::mutex> lk(mtx);
                    cv.wait(lk, [&] { return !q.empty() || prod_done; });
                    while (!q.empty() && got < STRESS_ITEMS) {
                        received[got++] = q.front().seq;
                        q.pop();
                    }
                }
            });
            pin_to_core(PRODUCER_CORE);
            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                { std::lock_guard<std::mutex> lk(mtx); q.push({uint32_t(i), 1, uint64_t(i)}); }
                cv.notify_one();
            }
            { std::lock_guard<std::mutex> lk(mtx); prod_done = true; }
            cv.notify_all();
            cons.join();

            for (size_t i = 0; i < STRESS_ITEMS; ++i) {
                if (received[i] != uint64_t(i)) {
                    std::fprintf(stderr, "STRESS FAIL [mutex-condvar]: "
                        "pos %zu expected seq %zu got %llu\n",
                        i, i, (unsigned long long)received[i]);
                    return false;
                }
            }
            return true;
        };

        for (const auto& t : targets) {
            std::fprintf(stderr, "==> stress-test %s (%zu items)...\n",
                t.c_str(), STRESS_ITEMS);
            bool ok = false;
            if (t == "lockfree-handrolled") ok = stress_lockfree_hr();
            else if (t == "lockfree-boost") ok = stress_lockfree_boost();
            else if (t == "mutex-condvar")  ok = stress_mutex();
            else { std::fprintf(stderr, "ERROR: unknown variant '%s'\n", t.c_str()); ++failures; continue; }

            if (ok) {
                std::printf("OK  %s: %zu items, zero losses, FIFO order verified\n",
                    t.c_str(), STRESS_ITEMS);
            } else {
                std::printf("FAIL %s\n", t.c_str());
                ++failures;
            }
        }
        return failures == 0 ? 0 : 1;
    }
    // ─────────────────────────────────────────────────────────────────────────

    const std::string_view variant = argv[1];
    const bool valid = (variant == "lockfree-handrolled" ||
                        variant == "lockfree-boost"      ||
                        variant == "mutex-condvar");
    if (!valid) {
        std::fprintf(stderr, "ERROR: unknown variant '%s'\n", argv[1]);
        std::fprintf(stderr, "Valid: lockfree-handrolled | lockfree-boost | mutex-condvar\n");
        return 1;
    }

    const double ns_per_cycle = calibrate_tsc();
    std::fprintf(stderr, "TSC calibration: %.6f ns/cycle\n", ns_per_cycle);

    RunResult result;
    if (variant == "lockfree-handrolled") {
        result = run_lockfree_handrolled(ns_per_cycle);
    } else if (variant == "lockfree-boost") {
        result = run_lockfree_boost(ns_per_cycle);
    } else {
        result = run_mutex_condvar(ns_per_cycle);
    }

    // Second calibration after all runs — measures drift across the measurement window.
    const double ns_per_cycle_post = calibrate_tsc();
    const double drift_pct = std::abs(ns_per_cycle_post - ns_per_cycle) / ns_per_cycle * 100.0;
    if (drift_pct > 0.1) {
        std::fprintf(stderr,
            "WARN: TSC calibration drift %.4f%% (threshold 0.1%%)\n", drift_pct);
    }

    emit_json(argv[1], result, ns_per_cycle, drift_pct);
    return 0;
}
