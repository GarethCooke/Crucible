// False-sharing benchmark: per-thread P&L accumulators, padded vs unpadded.
//
// Compile-time sanity check (run after build):
//   objdump -d build/demos/02-false-sharing/bench_02_false_sharing_pnl \
//     | grep -A 40 "<_ZL9worker_fn" \
//     | grep "movsd"
// Expect two movsd instructions per inner-loop body (volatile load + store).
// If the store is absent the false-sharing effect will not manifest cleanly.
// The 'volatile' qualifier on Strategy::pnl is applied precisely to prevent
// the compiler from register-allocating pnl across the j-loop. If you see no
// memory write, escalation options (in order of preference) are:
//   1. Verify volatile is still applied to both struct members (likely cause)
//   2. Drop to -O1 (simpler codegen at cost of realism)
//   3. std::atomic_ref<double> with relaxed ordering (adds fence overhead)
// Flag back to the author before changing compiler flags or struct layout.

#include <barrier>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <sched.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <pthread.h>
#include <random>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>
#include <iostream>

#include <benchmark/benchmark.h>
#include "machine_info.h"

// ─── Struct definitions ──────────────────────────────────────────────────────

// Unpadded — adjacent slots share cache lines (8 bytes/slot → 8 slots/line)
struct Strategy {
    // volatile forces a load+store per j-iteration, ensuring false sharing
    // manifests when multiple threads write to adjacent slots concurrently.
    volatile double pnl;
};

// Padded — each slot owns its cache line
struct alignas(64) PaddedStrategy {
    volatile double pnl;
    char pad[64 - sizeof(double)];
};

static_assert(sizeof(PaddedStrategy) == 64,  "PaddedStrategy must be one cache line");
static_assert(alignof(PaddedStrategy) == 64, "PaddedStrategy must be cache-line aligned");
static_assert(sizeof(Strategy) == 8,         "Strategy must be one double wide");

// ─── Global strategy arrays (max 8 threads) ─────────────────────────────────

static Strategy       g_unpadded[8];
static PaddedStrategy g_padded[8];

// ─── Constants ───────────────────────────────────────────────────────────────

static constexpr size_t  N_FILLS   = 1024;   // fill stream: 8 KB, fits in L1d
static constexpr size_t  N_ITERS   = 1000;   // inner iterations per barrier epoch (≥10 ms/burst)
static constexpr uint32_t FILL_SEED = 42;    // documented in JSON notes

// ─── Fill stream ─────────────────────────────────────────────────────────────

static std::vector<double> g_fills;

static void init_fills() {
    std::mt19937 rng(FILL_SEED);
    std::uniform_real_distribution<double> dist(-1.0, 1.0);
    g_fills.resize(N_FILLS);
    for (auto& v : g_fills) v = dist(rng);
}

// ─── SMT guard ───────────────────────────────────────────────────────────────

static void check_smt_off() {
    std::ifstream f("/sys/devices/system/cpu/smt/active");
    if (!f.is_open()) return;  // kernel without SMT sysfs — skip
    int val = -1;
    f >> val;
    if (val != 0) {
        std::fprintf(stderr,
            "FATAL: SMT active (/sys/devices/system/cpu/smt/active=%d).\n"
            "SMT-sibling resource sharing contaminates false-sharing results.\n"
            "Disable before running:\n"
            "  echo off | sudo tee /sys/devices/system/cpu/smt/control\n"
            "or disable in BIOS. Aborting.\n", val);
        std::exit(1);
    }
}

// ─── CPU affinity ────────────────────────────────────────────────────────────

static void pin_thread(std::thread& t, int cpu) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu, &cpuset);
    const int rc = pthread_setaffinity_np(
        t.native_handle(), sizeof(cpu_set_t), &cpuset);
    if (rc != 0)
        throw std::runtime_error(
            "pthread_setaffinity_np failed for cpu " + std::to_string(cpu));
}

// ─── Core lists ──────────────────────────────────────────────────────────────
// Reference machine: SMT off → 8 logical CPUs (0–7), one per physical core.
// CCX0 = cores 0–3, CCX1 = cores 4–7 (verified via lscpu --extended L3 groups).
// intra-CCX runs use CCX1 by convention (the typical shielded set).
//
// cpu0 is the boot CPU: the kernel will not honour isolcpus= for it regardless
// of boot parameters. Effective isolation is cores 1–7. Cross-CCX runs at 2t
// and 4t therefore use cores 1 and 2 (CCX0) instead of 0 and 1 to avoid the
// boot-CPU noise floor. The 8t case must span all cores including 0 by design;
// cpu0 sees slightly elevated jitter but the silicon-level false-sharing signal
// dominates at 8 threads. See /methodology.
//
// SYNC: tools/parse_perf.py cores_map must match these assignments.

static std::vector<int> intra_ccx_cores(int n) {
    switch (n) {
        case 1: return {4};
        case 2: return {4, 5};
        case 4: return {4, 5, 6, 7};
        default: throw std::invalid_argument("intra-ccx: 1, 2, or 4 threads only");
    }
}

static std::vector<int> cross_ccx_cores(int n) {
    switch (n) {
        case 2: return {1, 4};           // cpu1 (CCX0, isolatable) + cpu4 (CCX1)
        case 4: return {1, 2, 4, 5};     // cpu0 skipped — boot CPU, not isolatable
        case 8: return {0, 1, 2, 3, 4, 5, 6, 7};  // must include cpu0; signal dominates noise at 8t
        default: throw std::invalid_argument("cross-ccx: 2, 4, or 8 threads only");
    }
}

// ─── Worker ──────────────────────────────────────────────────────────────────

struct WorkerCtx {
    int                slot;
    bool               padded;
    const double*      fills;
    std::barrier<>*    go_bar;
    std::barrier<>*    done_bar;
    std::atomic<bool>* stop;
};

static void worker_fn(WorkerCtx ctx) {
    if (std::getenv("CRUCIBLE_PRINT_AFFINITY") != nullptr) {
        fprintf(stderr, "[bench] slot=%d tid=%ld cpu=%d\n",
                ctx.slot, (long)syscall(SYS_gettid), sched_getcpu());
    }
    while (true) {
        ctx.go_bar->arrive_and_wait();
        if (ctx.stop->load(std::memory_order_relaxed)) break;

        const int    slot  = ctx.slot;
        const double* fills = ctx.fills;

        if (ctx.padded) {
            for (size_t i = 0; i < N_ITERS; ++i)
                for (size_t j = 0; j < N_FILLS; ++j)
                    g_padded[slot].pnl += fills[j];
        } else {
            for (size_t i = 0; i < N_ITERS; ++i)
                for (size_t j = 0; j < N_FILLS; ++j)
                    g_unpadded[slot].pnl += fills[j];
        }

        ctx.done_bar->arrive_and_wait();
    }
}

// ─── Benchmark runner ────────────────────────────────────────────────────────

static void run_benchmark(
    benchmark::State&       state,
    int                     nthreads,
    bool                    padded,
    const std::vector<int>& cores)
{
    assert(static_cast<int>(cores.size()) == nthreads);

    for (int i = 0; i < nthreads; ++i) {
        g_unpadded[i].pnl = 0.0;
        g_padded[i].pnl   = 0.0;
    }

    std::barrier<> go_bar(nthreads + 1);
    std::barrier<> done_bar(nthreads + 1);
    std::atomic<bool> stop{false};

    std::vector<std::thread> workers;
    workers.reserve(nthreads);
    for (int t = 0; t < nthreads; ++t) {
        workers.emplace_back(worker_fn,
            WorkerCtx{t, padded, g_fills.data(), &go_bar, &done_bar, &stop});
        pin_thread(workers.back(), cores[t]);
    }

    // Warmup burst (result discarded): pre-touches g_padded/g_unpadded pages on
    // every participating core, resolves first-touch NUMA allocations, and warms
    // the branch predictor. Without this, the 1t and 2t intra-CCX padded results
    // are artifactually slow relative to higher thread counts.
    go_bar.arrive_and_wait();
    done_bar.arrive_and_wait();

    for (auto _ : state) {
        state.PauseTiming();
        go_bar.arrive_and_wait();    // release workers — barrier cost excluded from timing
        state.ResumeTiming();
        done_bar.arrive_and_wait();  // wait for burst to complete (dominated by work)
    }

    stop.store(true, std::memory_order_relaxed);
    go_bar.arrive_and_wait();
    for (auto& w : workers) w.join();

    state.SetItemsProcessed(
        state.iterations()
        * static_cast<int64_t>(nthreads)
        * N_ITERS
        * N_FILLS);
}

// ─── Registration + main ─────────────────────────────────────────────────────

int main(int argc, char** argv) {
    if (argc > 1 && std::string(argv[1]) == "--machine-info") {
        std::cout << "{" << crucible::machine_info_json() << "}" << std::endl;
        return 0;
    }
    check_smt_off();
    init_fills();

    benchmark::Initialize(&argc, argv);
    if (benchmark::ReportUnrecognizedArguments(argc, argv)) return 1;

    auto register_group = [](const char* prefix,
                              std::initializer_list<int> thread_counts,
                              std::vector<int> (*core_fn)(int)) {
        for (bool padded : {false, true})
            for (int t : thread_counts) {
                auto cores = core_fn(t);
                std::string name = std::string(prefix) + "/" + std::to_string(t)
                                 + "t/" + (padded ? "padded" : "unpadded");
                benchmark::RegisterBenchmark(name.c_str(),
                    [padded, cores](benchmark::State& s) {
                        run_benchmark(s, static_cast<int>(cores.size()), padded, cores);
                    })->Iterations(50)->Repetitions(20)->Unit(benchmark::kNanosecond);
            }
    };

    register_group("IntraCCX", {1, 2, 4}, intra_ccx_cores);
    register_group("CrossCCX", {2, 4, 8}, cross_ccx_cores);

    benchmark::RunSpecifiedBenchmarks();
    benchmark::Shutdown();
    return 0;
}
