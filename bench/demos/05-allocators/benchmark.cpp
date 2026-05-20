// Allocator cross-thread Order pipeline benchmark — Demo 05
//
// Usage:
//   bench_05_allocators <variant> --mode paced
//                       [--offered-rate-hz N] [--bg-pressure-hz N]
//                       [--consumer-core C]
//   bench_05_allocators <variant> --mode pressure_sweep
//                       [--bg-from N --bg-to N --steps K]
//                       [--offered-rate-hz N] [--consumer-core C]
//   bench_05_allocators <variant> --verify-warmup
//   bench_05_allocators --machine-info
//
// Variants: cross-thread-malloc | freelist-return-queue | arena-batch-handoff
//
// Pinning: producer=core 4, consumer=core 5 (default; override with --consumer-core),
//          T_bg=core 6. All same CCX1 on Zen 2 3800X.
// TSC pacing: __rdtsc() for pace gate, rdtscp+lfence for latency stamps.

#include "order.h"
#include "risk_check.h"
#include "background_pressure.h"
#include "allocators/malloc_allocator.h"
#include "allocators/freelist_return_allocator.h"
#include "allocators/arena_batch_allocator.h"

#include "histogram.h"
#include "machine_info.h"
#include "spsc_queue.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <memory>
#include <optional>
#include <pthread.h>
#include <random>
#include <sched.h>
#include <string>
#include <string_view>
#include <thread>
#include <vector>

#include <x86intrin.h>

// ─── Constants ───────────────────────────────────────────────────────────────

static constexpr size_t   QUEUE_DEPTH     = 1024;
static constexpr size_t   ITEMS_MEASURED  = 1'000'000;
static constexpr size_t   ITEMS_WARMUP    = 100'000;
static constexpr size_t   NUM_RUNS_PACED  = 5;
static constexpr size_t   NUM_RUNS_SWEEP  = 1;
static constexpr int      PRODUCER_CORE   = 4;
static constexpr int      BG_CORE         = 6;

// Default sweep parameters: 8 log-spaced points from 100 k/s to 10 M/s plus a
// zero-pressure baseline (T_bg not spawned) = 9 total sweep points.
static constexpr uint64_t BG_FROM_DEFAULT = 100'000;
static constexpr uint64_t BG_TO_DEFAULT   = 10'000'000;
static constexpr int      SWEEP_STEPS_DEF = 8;

// ─── Mode ────────────────────────────────────────────────────────────────────

enum class Mode { Paced, PressureSweep };

struct BenchConfig {
    Mode     mode            = Mode::Paced;
    uint64_t offered_rate_hz = 1'000'000;
    uint64_t bg_pressure_hz  = 1'000'000;  // paced mode default
    uint64_t bg_from_hz      = BG_FROM_DEFAULT;
    uint64_t bg_to_hz        = BG_TO_DEFAULT;
    int      sweep_steps     = SWEEP_STEPS_DEF;
    bool     verify_warmup   = false;
    int      consumer_core   = 5;  // override with --consumer-core for cross-CCX
};

// ─── TSC helpers ─────────────────────────────────────────────────────────────

static inline uint64_t rdtscp_ordered() noexcept {
    unsigned aux;
    uint64_t t = __rdtscp(&aux);
    _mm_lfence();
    return t;
}

static inline uint64_t tsc_to_ns_u64(uint64_t cycles, double ns_per_cycle) noexcept {
    return static_cast<uint64_t>(static_cast<double>(cycles) * ns_per_cycle);
}

// Calibrate TSC against CLOCK_MONOTONIC_RAW over a 100 ms window.
// Verifies constant_tsc and nonstop_tsc; aborts on missing flags.
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
            "  constant_tsc: %s\n  nonstop_tsc:  %s\n",
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
    while (mono_ns() - t0_ns < 100'000'000ULL) {}
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
    // Verify affinity at thread start; mismatch aborts (brief requirement).
    const int actual = sched_getcpu();
    if (actual != core) {
        std::fprintf(stderr,
            "ERROR: affinity mismatch — expected core %d, running on %d\n", core, actual);
        std::exit(1);
    }
}

// ─── RNG helpers ─────────────────────────────────────────────────────────────
// Fixed seeds for reproducibility (documented in README).

static inline int64_t generate_price(std::mt19937& rng) {
    // Fixed-point price in [9900, 10100] scaled by 100 (i.e. $99.00–$101.00)
    return static_cast<int64_t>(9900 + (rng() % 201)) * 100;
}

static inline int32_t generate_qty(std::mt19937& rng) {
    return static_cast<int32_t>(1 + (rng() % 1000));
}

// ─── Run result ──────────────────────────────────────────────────────────────

struct RunResult {
    crucible::Histogram hist;
    double              wall_ns_total    = 0.0;
    size_t              top_bucket_count = 0;
    // Slot-exhaustion / arena-wait diagnostics (set to non-zero if miscalibrated).
    uint64_t            arena_wait_count = 0;
};

// ─── Warmup verification ─────────────────────────────────────────────────────

struct WarmupVerify {
    bool                enabled = false;
    crucible::Histogram early;   // items 0..9_999 of measurement
    crucible::Histogram late;    // items 100_000+ of measurement
};

// ─── Pacing helper ───────────────────────────────────────────────────────────

static inline uint64_t pacing_period_cycles(uint64_t rate_hz,
                                             double ns_per_cycle) noexcept {
    if (rate_hz == 0) return 0;
    return static_cast<uint64_t>(1.0e9 / (static_cast<double>(rate_hz) * ns_per_cycle));
}

// ─── Core benchmark loop (templated on allocator type) ────────────────────────

template <typename Alloc>
static RunResult run_one(Alloc& alloc,
                         double ns_per_cycle,
                         uint64_t offered_rate_hz,
                         uint64_t bg_pressure_hz,
                         int consumer_core,
                         size_t num_iterations,
                         WarmupVerify* wv) {

    const uint64_t period_cycles = pacing_period_cycles(offered_rate_hz, ns_per_cycle);

    RunResult result;

    for (size_t iter = 0; iter < num_iterations; ++iter) {
        SPSCQueue<Order*, QUEUE_DEPTH> queue;

        init_risk_tables();

        std::atomic<bool>   consumer_ready{false};
        std::atomic<bool>   start_signal{false};
        std::atomic<size_t> warmup_consumed{0};
        std::atomic<bool>   measurement_active{false};
        std::atomic<bool>   producer_done{false};

        // ── Consumer thread (T_c) ──
        std::thread consumer([&] {
            pin_to_core(consumer_core);
            consumer_ready.store(true, std::memory_order_release);
            while (!start_signal.load(std::memory_order_acquire)) { _mm_pause(); }

            // Warmup phase — consume without recording.
            {
                size_t warmup_done = 0;
                while (warmup_done < ITEMS_WARMUP) {
                    Order* o = nullptr;
                    if (queue.try_pop(o)) {
                        alloc.deallocate(o);
                        ++warmup_done;
                        warmup_consumed.store(warmup_done, std::memory_order_release);
                    } else {
                        _mm_pause();
                    }
                }
            }

            // Measurement phase.
            size_t measured = 0;
            while (measured < ITEMS_MEASURED) {
                Order* o = nullptr;
                if (!queue.try_pop(o)) { _mm_pause(); continue; }

                const uint64_t now_ns = tsc_to_ns_u64(rdtscp_ordered(), ns_per_cycle);
                simulated_risk_check(o, now_ns);

                const uint64_t latency_ns =
                    tsc_to_ns_u64(rdtscp_ordered() - o->ts_create_tsc, ns_per_cycle);

                if (wv && wv->enabled) {
                    if (measured < 10'000)        wv->early.record(latency_ns);
                    else if (measured >= 100'000) wv->late.record(latency_ns);
                }

                result.hist.record(latency_ns);
                ++measured;

                alloc.deallocate(o);
            }
        });

        // ── Background pressure thread (T_bg) ──
        std::atomic<bool> bg_stop{false};
        std::thread bg_thread;
        if (bg_pressure_hz > 0) {
            bg_thread = std::thread([&] {
                pin_to_core(BG_CORE);
                background_pressure_loop(bg_pressure_hz, ns_per_cycle, bg_stop);
            });
        }

        // ── Producer (T_p — main thread) ──
        pin_to_core(PRODUCER_CORE);
        while (!consumer_ready.load(std::memory_order_acquire)) { _mm_pause(); }
        start_signal.store(true, std::memory_order_release);

        std::mt19937 prod_rng(12345 + iter);  // fixed seed per iteration, reproducible

        // Warmup — produce ITEMS_WARMUP orders without pacing.
        for (size_t i = 0; i < ITEMS_WARMUP; ++i) {
            Order* o = alloc.allocate();
            o->ts_create_tsc = 0;  // warmup: not measured
            o->seq           = ~uint64_t(0);
            o->price         = generate_price(prod_rng);
            o->qty           = generate_qty(prod_rng);
            o->client_id     = static_cast<uint32_t>(i & 255);
            o->symbol_id     = static_cast<uint32_t>(i & 1023);
            o->risk_seq      = 0;
            o->side          = (prod_rng() & 1) ? Side::Buy : Side::Sell;
            while (!queue.try_push(o)) { _mm_pause(); }
        }

        // Wait for consumer to finish warmup before starting measurement.
        while (warmup_consumed.load(std::memory_order_acquire) < ITEMS_WARMUP)
            std::this_thread::yield();

        struct timespec t0{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t0);

        // Measurement — paced at offered_rate_hz.
        uint64_t next_release = rdtscp_ordered();
        for (size_t i = 0; i < ITEMS_MEASURED; ++i) {
            if (period_cycles > 0) {
                while (__rdtsc() < next_release) { _mm_pause(); }
                next_release += period_cycles;
            }

            Order* o = alloc.allocate();
            o->ts_create_tsc = rdtscp_ordered();
            o->seq           = i;
            o->price         = generate_price(prod_rng);
            o->qty           = generate_qty(prod_rng);
            o->client_id     = static_cast<uint32_t>(i & 255);
            o->symbol_id     = static_cast<uint32_t>(i & 1023);
            o->risk_seq      = 0;
            o->side          = (prod_rng() & 1) ? Side::Buy : Side::Sell;
            // arena_idx is set by allocate() for variant 3; zeroed by new/freelist.
            while (!queue.try_push(o)) { _mm_pause(); }
        }

        consumer.join();

        struct timespec t1{};
        clock_gettime(CLOCK_MONOTONIC_RAW, &t1);
        result.wall_ns_total += static_cast<double>(
            (t1.tv_sec - t0.tv_sec) * 1'000'000'000LL + (t1.tv_nsec - t0.tv_nsec));

        if (bg_pressure_hz > 0) {
            bg_stop.store(true, std::memory_order_relaxed);
            bg_thread.join();
        }

        // Check for top-bucket contamination.
        if (result.hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1] > 0) {
            std::fprintf(stderr,
                "WARN: %llu sample(s) in top bucket (likely kernel preemption)\n",
                (unsigned long long)result.hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1]);
            result.top_bucket_count +=
                result.hist.counts[crucible::HISTOGRAM_BUCKET_COUNT - 1];
        }
    }

    return result;
}

// ─── Specialisation to extract arena_wait_count ──────────────────────────────

static RunResult run_variant_arena(ArenaBatchAllocator& alloc,
                                    double ns_per_cycle,
                                    uint64_t offered_rate_hz,
                                    uint64_t bg_pressure_hz,
                                    int consumer_core,
                                    size_t num_iterations,
                                    WarmupVerify* wv) {
    RunResult r = run_one(alloc, ns_per_cycle, offered_rate_hz, bg_pressure_hz,
                          consumer_core, num_iterations, wv);
    r.arena_wait_count = alloc.wait_count;
    if (alloc.wait_count > 0) {
        std::fprintf(stderr,
            "WARN [arena]: producer waited %llu time(s) for fully_drained() — "
            "calibration may be wrong.\n",
            (unsigned long long)alloc.wait_count);
    }
    return r;
}

// ─── JSON emission ───────────────────────────────────────────────────────────

// Builds a single run JSON object. bg_pressure_hz == 0 emits null for
// background_pressure_hz (no-background baseline run).
static std::string emit_run_json(const char* variant,
                                  const char* mode_str,
                                  uint64_t offered_rate_hz,
                                  uint64_t bg_pressure_hz,
                                  uint32_t consumer_work_target_ns,
                                  size_t num_iterations,
                                  const RunResult& r,
                                  double ns_per_cycle,
                                  double calibration_drift_pct,
                                  // variant-specific knobs (pass 0/nullptr to omit)
                                  size_t freelist_initial_slots,
                                  size_t return_queue_depth,
                                  size_t freelist_drain_batch,
                                  size_t arena_count,
                                  size_t arena_capacity_orders) {
    (void)ns_per_cycle;
    const auto& h = r.hist;

    const double total_items = static_cast<double>(ITEMS_MEASURED) * num_iterations;
    const double ops_per_sec = total_items / (r.wall_ns_total * 1e-9);

    const double median = static_cast<double>(h.percentile(50.0));
    const double min_ns = static_cast<double>(h.total ? h.minval : 0);
    const double p25    = static_cast<double>(h.percentile(25.0));
    const double p75    = static_cast<double>(h.percentile(75.0));
    const double p99    = static_cast<double>(h.percentile(99.0));
    const double iqr    = p75 - p25;

    // bg_pressure_hz == 0 → JSON null (no T_bg spawned).
    char bg_field[32];
    if (bg_pressure_hz == 0)
        std::snprintf(bg_field, sizeof(bg_field), "null");
    else
        std::snprintf(bg_field, sizeof(bg_field), "%llu",
                      (unsigned long long)bg_pressure_hz);

    char hdr[1024];
    std::snprintf(hdr, sizeof(hdr),
        "{"
        "\"variant\":\"%s\","
        "\"mode\":\"%s\","
        "\"offered_rate_hz\":%llu,"
        "\"background_pressure_hz\":%s,"
        "\"background_size_classes\":[32,64,128,256,512,1024],"
        "\"consumer_work_target_ns\":%u,"
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
        (unsigned long long)offered_rate_hz,
        bg_field,
        consumer_work_target_ns,
        QUEUE_DEPTH,
        ITEMS_MEASURED,
        ITEMS_WARMUP,
        num_iterations,
        median, min_ns, p99, iqr,
        ops_per_sec,
        crucible::HISTOGRAM_BUCKET_COUNT);

    // Variant-specific knobs.
    std::string knobs;
    if (freelist_initial_slots > 0) {
        char buf[128];
        std::snprintf(buf, sizeof(buf),
            ",\"freelist_initial_slots\":%zu"
            ",\"return_queue_depth\":%zu"
            ",\"freelist_drain_batch\":%zu",
            freelist_initial_slots, return_queue_depth, freelist_drain_batch);
        knobs = buf;
    } else if (arena_count > 0) {
        char buf[128];
        std::snprintf(buf, sizeof(buf),
            ",\"arena_count\":%zu"
            ",\"arena_capacity_orders\":%zu",
            arena_count, arena_capacity_orders);
        knobs = buf;
    }

    char trailer[128];
    std::snprintf(trailer, sizeof(trailer),
        "},\"top_bucket_count\":%zu,\"calibration_drift_pct\":%.4f%s}",
        r.top_bucket_count,
        calibration_drift_pct,
        knobs.c_str());

    std::string result;
    result.reserve(1024 + crucible::HISTOGRAM_BUCKET_COUNT * 8 + 256);
    result += hdr;
    result += h.counts_json();
    result += ",\"stats\":";
    result += h.stats_json();
    result += trailer;
    return result;
}

// ─── Dispatch ────────────────────────────────────────────────────────────────

struct RunOutput {
    std::string json;
    RunResult   result;
};

static RunOutput dispatch(std::string_view variant,
                           double ns_per_cycle,
                           uint64_t offered_rate_hz,
                           uint64_t bg_pressure_hz,
                           int consumer_core,
                           const char* mode_str,
                           size_t num_iterations,
                           WarmupVerify* wv) {
    // consumer_work_target_ns: measured during calibration; see README.
    // Set to 200 as the calibrated target; update after measurement confirms it.
    constexpr uint32_t CONSUMER_WORK_NS = 200;

    RunOutput out;

    if (variant == "cross-thread-malloc") {
        MallocAllocator alloc;
        out.result = run_one(alloc, ns_per_cycle, offered_rate_hz, bg_pressure_hz,
                             consumer_core, num_iterations, wv);
        out.json = emit_run_json("cross-thread-malloc", mode_str,
            offered_rate_hz, bg_pressure_hz, CONSUMER_WORK_NS, num_iterations,
            out.result, ns_per_cycle,
            std::abs(calibrate_tsc() - ns_per_cycle) / ns_per_cycle * 100.0,
            0, 0, 0, 0, 0);

    } else if (variant == "freelist-return-queue") {
        FreelistReturnAllocator alloc;
        out.result = run_one(alloc, ns_per_cycle, offered_rate_hz, bg_pressure_hz,
                             consumer_core, num_iterations, wv);
        out.json = emit_run_json("freelist-return-queue", mode_str,
            offered_rate_hz, bg_pressure_hz, CONSUMER_WORK_NS, num_iterations,
            out.result, ns_per_cycle,
            std::abs(calibrate_tsc() - ns_per_cycle) / ns_per_cycle * 100.0,
            alloc.initial_slots, alloc.return_depth, alloc.drain_batch,
            0, 0);

    } else {
        ArenaBatchAllocator alloc;
        out.result = run_variant_arena(alloc, ns_per_cycle, offered_rate_hz,
                                        bg_pressure_hz, consumer_core,
                                        num_iterations, wv);
        out.json = emit_run_json("arena-batch-handoff", mode_str,
            offered_rate_hz, bg_pressure_hz, CONSUMER_WORK_NS, num_iterations,
            out.result, ns_per_cycle,
            std::abs(calibrate_tsc() - ns_per_cycle) / ns_per_cycle * 100.0,
            0, 0, 0,
            alloc.arena_count, alloc.arena_capacity);
    }

    return out;
}

// ─── Main ────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: %s <variant> --mode paced [--offered-rate-hz N] [--bg-pressure-hz N]\n"
            "       %s <variant> --mode pressure_sweep [--bg-from N] [--bg-to N] [--steps K]\n"
            "       %s <variant> --verify-warmup\n"
            "       %s --machine-info\n"
            "Variants: cross-thread-malloc | freelist-return-queue | arena-batch-handoff\n",
            argv[0], argv[0], argv[0], argv[0]);
        return 1;
    }

    // ── Machine info ─────────────────────────────────────────────────────────
    if (std::string_view(argv[1]) == "--machine-info") {
        const double ns_per_cycle = calibrate_tsc();
        std::printf("{%s,\"tsc_ns_per_cycle\":%.6f}\n",
            crucible::machine_info_json().c_str(), ns_per_cycle);
        return 0;
    }

    // ── Variant validation ────────────────────────────────────────────────────
    const std::string_view variant = argv[1];
    if (variant != "cross-thread-malloc" &&
        variant != "freelist-return-queue" &&
        variant != "arena-batch-handoff") {
        std::fprintf(stderr, "ERROR: unknown variant '%s'\n", argv[1]);
        std::fprintf(stderr,
            "Valid: cross-thread-malloc | freelist-return-queue | arena-batch-handoff\n");
        return 1;
    }

    // ── Parse options ─────────────────────────────────────────────────────────
    BenchConfig cfg;
    bool mode_set = false;

    for (int i = 2; i < argc; ++i) {
        std::string_view arg = argv[i];
        if (arg == "--mode" && i + 1 < argc) {
            std::string_view m = argv[++i];
            if      (m == "paced")          cfg.mode = Mode::Paced;
            else if (m == "pressure_sweep") cfg.mode = Mode::PressureSweep;
            else { std::fprintf(stderr, "ERROR: unknown mode '%s'\n", argv[i]); return 1; }
            mode_set = true;
        } else if (arg == "--offered-rate-hz" && i + 1 < argc) {
            cfg.offered_rate_hz = std::stoull(argv[++i]);
        } else if (arg == "--bg-pressure-hz" && i + 1 < argc) {
            cfg.bg_pressure_hz = std::stoull(argv[++i]);
        } else if (arg == "--bg-from" && i + 1 < argc) {
            cfg.bg_from_hz = std::stoull(argv[++i]);
        } else if (arg == "--bg-to" && i + 1 < argc) {
            cfg.bg_to_hz = std::stoull(argv[++i]);
        } else if (arg == "--steps" && i + 1 < argc) {
            cfg.sweep_steps = std::stoi(argv[++i]);
        } else if (arg == "--verify-warmup") {
            cfg.verify_warmup = true;
            if (!mode_set) cfg.mode = Mode::Paced;
        } else if (arg == "--consumer-core" && i + 1 < argc) {
            cfg.consumer_core = std::stoi(argv[++i]);
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

    if (cfg.mode == Mode::PressureSweep) {
        // 9 sweep points: zero-pressure baseline + 8 log-spaced from bg_from to bg_to.
        const int    n  = std::max(cfg.sweep_steps, 1);
        const double lo = static_cast<double>(cfg.bg_from_hz);
        const double hi = static_cast<double>(cfg.bg_to_hz);

        output = "[\n";

        // Point 0: no background pressure (T_bg not spawned).
        std::fprintf(stderr, "  pressure_sweep baseline: T_bg off\n");
        auto r0 = dispatch(variant, ns_per_cycle, cfg.offered_rate_hz, 0,
                           cfg.consumer_core, "pressure_sweep", NUM_RUNS_SWEEP, &wv);
        output += r0.json;
        output += ",\n";

        // Points 1..n: log-spaced background pressure.
        for (int s = 0; s < n; ++s) {
            const double ratio = (n > 1)
                ? std::pow(hi / lo, static_cast<double>(s) / (n - 1))
                : 1.0;
            const uint64_t bg_hz = static_cast<uint64_t>(lo * ratio);
            std::fprintf(stderr, "  pressure_sweep step %d/%d: bg=%.0f Hz\n",
                         s + 1, n, static_cast<double>(bg_hz));

            auto r = dispatch(variant, ns_per_cycle, cfg.offered_rate_hz, bg_hz,
                              cfg.consumer_core, "pressure_sweep", NUM_RUNS_SWEEP, &wv);
            output += r.json;
            if (s + 1 < n) output += ",\n";
        }
        output += "\n]";

    } else {
        // Paced mode (headline measurement or --verify-warmup).
        auto r = dispatch(variant, ns_per_cycle, cfg.offered_rate_hz,
                          cfg.bg_pressure_hz,
                          cfg.consumer_core, "paced", NUM_RUNS_PACED, &wv);
        output = "[\n" + r.json + "\n]";
    }

    std::printf("%s\n", output.c_str());

    // ── Warmup verification report ───────────────────────────────────────────
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
