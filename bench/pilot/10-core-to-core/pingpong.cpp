// pingpong.cpp — core-to-core cache-line ping-pong RTT harness (demo 10 §1).
//
// Throwaway calibration scaffolding for Machine 1 (Ryzen 7 3800X, Matisse /
// Zen 2, SMT off, isolcpus=1-7). It measures the round-trip time for a cache
// line to bounce between two pinned cores, which exposes the CCX seam:
// intra-CCX pairs exchange the line through their shared L3 slice, cross-CCX
// pairs via the IO die over Infinity Fabric. It DISCOVERS the numbers; it
// decides no gate.
//
// Two transfer protocols (see brief §Task 2):
//   exchange (default) — one shared atomic; leader advances even->odd, follower
//                        odd->even; a round trip is one even->odd->even cycle.
//   twoflag            — two atomics on SEPARATE cache lines, one written per
//                        direction (A writes flag_a/spins flag_b; B spins
//                        flag_a/writes flag_b).
//   baseline           — single thread, line resident in its own L1, the SAME
//                        two atomic stores as a round trip but no cross-core
//                        transfer and no spin-wait. Isolates the fixed cost X.
//
// Round-2 additions (resolving A3 — the L3-slice-placement hypothesis):
//   * A single 2 MiB-aligned, THP-advised ARENA. The ping-pong line(s) sit at
//     arena+offset; --offset moves them. Round 1 allocated the line on the
//     stack, so each process invocation homed it to a fresh (ASLR-driven) L3
//     slice — the uncontrolled confound behind A3's bimodality.
//   * --repeat N re-runs the whole measurement at N pseudo-random offsets (one
//     per allocation) and reports the distribution of per-run medians: the
//     across-allocation error bar the slice effect demands.
//   * --offset-sweep steps the line through systematic offsets to confirm or
//     kill the slice hypothesis directly.
//
// Design invariants (unchanged from round 1):
//   * Affinity is asserted, not assumed: each worker reads back sched_getcpu()
//     and aborts if it is not on its requested core.
//   * No self-false-sharing: the ping-pong atomic(s) are each alignas(64) on
//     their own line; control/bookkeeping lives on a separate cold line; a
//     static_assert guards the gaps.
//   * acquire on the spin-load, release on the store. No seq_cst.
//   * rdtscp bracket per window of K round trips; warmup windows discarded;
//     median + IQR over the timed windows, reported in nanoseconds.
//
// x86-64 only (rdtscp + invariant TSC). Build: see CMakeLists.txt.

#ifndef _GNU_SOURCE
#define _GNU_SOURCE  // sched_getcpu / pthread_setaffinity_np / MADV_HUGEPAGE
#endif
#include <sched.h>
#include <pthread.h>
#include <time.h>
#include <unistd.h>
#include <sys/mman.h>

#include <algorithm>
#include <cctype>
#include <cerrno>
#include <cinttypes>
#include <cstdarg>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <new>
#include <random>
#include <string>
#include <thread>
#include <vector>
#include <atomic>

#if !defined(__x86_64__)
#error "pingpong is x86-64 only (Machine 1 / rdtscp). See the pilot README."
#endif
#include <x86intrin.h>

// ─── fatal error helper ──────────────────────────────────────────────────────
[[noreturn]] static void die(const char* fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    std::fprintf(stderr, "ERROR: ");
    std::vfprintf(stderr, fmt, ap);
    std::fprintf(stderr, "\n");
    va_end(ap);
    std::exit(2);
}

// ─── TSC read: lfence-bracketed rdtscp so the timestamp cannot float out of
//     the window body in either direction. ─────────────────────────────────────
static inline uint64_t tsc_now() {
    unsigned aux;
    _mm_lfence();
    uint64_t t = __rdtscp(&aux);
    _mm_lfence();
    return t;
}

static constexpr size_t CACHELINE  = 64;
static constexpr size_t ARENA_SIZE = 2 * 1024 * 1024;  // 2 MiB — one THP
static constexpr size_t PAGE_SIZE  = 4096;             // sweep-safe span w/o THP
// Fixed default so two --repeat runs draw the same offset sequence unless the
// caller overrides --seed. Golden-ratio constant, no significance beyond that.
static constexpr uint64_t DEFAULT_SEED = 0x9E3779B97F4A7C15ULL;

// ─── The hot ping-pong lines, overlaid on the arena at a chosen offset. Each
//     atomic gets its own 64-byte line; moving the struct by --offset moves all
//     three together. A placement-new per measurement resets them to zero. ─────
struct PingPongLines {
    alignas(64) std::atomic<uint64_t> seq;     // exchange / baseline: one shared line
    alignas(64) std::atomic<uint64_t> flag_a;  // twoflag A->B: own line
    alignas(64) std::atomic<uint64_t> flag_b;  // twoflag B->A: own line
};
// Guard the three hot lines against each other — demo 2's false-sharing lesson
// applied to demo 2's own descendant. offset==0 keeps seq on the arena's line.
static_assert(offsetof(PingPongLines, seq) == 0,
              "seq must sit exactly at arena+offset");
static_assert(offsetof(PingPongLines, flag_a) - offsetof(PingPongLines, seq)    >= 64,
              "seq and flag_a must not share a cache line");
static_assert(offsetof(PingPongLines, flag_b) - offsetof(PingPongLines, flag_a) >= 64,
              "flag_a and flag_b must not share a cache line");
static_assert(alignof(PingPongLines) >= 64,
              "ping-pong lines must be cache-line aligned within the arena");

// ─── Cold control block. Used only OUTSIDE the timed region, so it cannot
//     perturb the measurement; it lives on the orchestrator's stack, well away
//     from the arena. static_assert keeps `stop` off any hot line by alignment. ─
struct Control {
    alignas(64) std::atomic<uint64_t> stop{0};
    std::atomic<uint64_t> pinned{0};
    std::atomic<uint64_t> go{0};
};
static_assert(alignof(Control) >= 64,
              "control block must start on its own cache line");

enum Protocol { PROTO_EXCHANGE = 0, PROTO_TWOFLAG = 1, PROTO_BASELINE = 2 };

struct WorkerCtx {
    PingPongLines* pp;
    Control* ctrl;
    int core;
    int protocol;
    uint64_t K;
    uint64_t n_windows;                 // warmup + timed (leader/baseline only)
    std::vector<uint64_t>* win_cycles;  // leader writes one entry per window
};

// ─── Pin the calling thread to `core` and PROVE it landed there. ─────────────
// A single-CPU affinity mask forces migration, but the kernel defers it to the
// next reschedule, so we yield and re-read sched_getcpu() until it agrees.
static void pin_and_assert(int core) {
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(core, &set);
    int rc = pthread_setaffinity_np(pthread_self(), sizeof(set), &set);
    if (rc != 0)
        die("pthread_setaffinity_np(core=%d) failed: %s", core, std::strerror(rc));

    for (int tries = 0; tries < 100000; ++tries) {
        if (sched_getcpu() == core) return;
        sched_yield();
    }
    die("AFFINITY ASSERT FAILED: requested core %d but sched_getcpu()=%d — the "
        "thread never migrated. STOP and report this core.", core, sched_getcpu());
}

// Soft pin for the orchestrator. Orchestration is not timing-critical, so a
// failure warns rather than aborts. NOTE (brief §Task 5): during the timed
// region the orchestrator is blocked in pthread_join (futex sleep), NOT
// spinning — it briefly spins only while the workers pin up, before `go`.
static void pin_soft(int core) {
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(core, &set);
    if (pthread_setaffinity_np(pthread_self(), sizeof(set), &set) != 0)
        std::fprintf(stderr, "WARNING: could not pin orchestrator to core %d\n", core);
}

// ─── Leader / baseline: drives the protocol and brackets each window with
//     rdtscp. Baseline runs alone; exchange/twoflag pair with a follower. ──────
static void leader_run(WorkerCtx ctx) {
    PingPongLines* pp = ctx.pp;
    Control* c = ctx.ctrl;
    pin_and_assert(ctx.core);
    c->pinned.fetch_add(1, std::memory_order_release);
    while (c->go.load(std::memory_order_acquire) == 0) _mm_pause();

    if (ctx.protocol == PROTO_EXCHANGE) {
        uint64_t local = 0;  // seq starts even; leader owns even->odd transitions
        for (uint64_t w = 0; w < ctx.n_windows; ++w) {
            uint64_t t0 = tsc_now();
            for (uint64_t k = 0; k < ctx.K; ++k) {
                pp->seq.store(local + 1, std::memory_order_release);      // ping (odd)
                while (pp->seq.load(std::memory_order_acquire) != local + 2)
                    _mm_pause();                                          // await pong
                local += 2;
            }
            uint64_t t1 = tsc_now();
            (*ctx.win_cycles)[w] = t1 - t0;
        }
        c->stop.store(1, std::memory_order_release);
    } else if (ctx.protocol == PROTO_TWOFLAG) {
        uint64_t token = 0;
        for (uint64_t w = 0; w < ctx.n_windows; ++w) {
            uint64_t t0 = tsc_now();
            for (uint64_t k = 0; k < ctx.K; ++k) {
                ++token;
                pp->flag_a.store(token, std::memory_order_release);       // ping
                while (pp->flag_b.load(std::memory_order_acquire) != token)
                    _mm_pause();                                          // await echo
            }
            uint64_t t1 = tsc_now();
            (*ctx.win_cycles)[w] = t1 - t0;
        }
        c->stop.store(1, std::memory_order_release);
    } else {  // PROTO_BASELINE — single thread, line stays in L1, no follower.
        // Perform the SAME two atomic stores a round trip performs (the leader's
        // even->odd store and the follower's odd->even store), so X is a like-
        // for-like fixed cost. The spin-wait is skipped: with no follower it
        // would be satisfied immediately anyway (brief §Task 4). The C++ memory
        // model would technically permit coalescing the first store into the
        // second (no reader forces it); GCC/Clang don't today, but the signal
        // fence — a COMPILER-only barrier that emits no instruction, so X is
        // unaffected — guarantees both stores survive on any conforming compiler.
        uint64_t local = 0;
        for (uint64_t w = 0; w < ctx.n_windows; ++w) {
            uint64_t t0 = tsc_now();
            for (uint64_t k = 0; k < ctx.K; ++k) {
                pp->seq.store(local + 1, std::memory_order_release);      // ping store
                std::atomic_signal_fence(std::memory_order_release);      // keep both stores; no runtime cost
                pp->seq.store(local + 2, std::memory_order_release);      // pong store
                local += 2;
            }
            uint64_t t1 = tsc_now();
            (*ctx.win_cycles)[w] = t1 - t0;
        }
    }
}

// ─── Follower: mirrors the leader's line, exits when stop is set. ─────────────
static void follower_run(WorkerCtx ctx) {
    PingPongLines* pp = ctx.pp;
    Control* c = ctx.ctrl;
    pin_and_assert(ctx.core);
    c->pinned.fetch_add(1, std::memory_order_release);
    while (c->go.load(std::memory_order_acquire) == 0) _mm_pause();

    if (ctx.protocol == PROTO_EXCHANGE) {
        for (;;) {
            uint64_t cur = pp->seq.load(std::memory_order_acquire);
            if (cur & 1ULL) {
                pp->seq.store(cur + 1, std::memory_order_release);        // pong (even)
            } else if (c->stop.load(std::memory_order_acquire)) {
                return;
            } else {
                _mm_pause();
            }
        }
    } else {  // PROTO_TWOFLAG
        uint64_t last = 0;
        for (;;) {
            uint64_t a = pp->flag_a.load(std::memory_order_acquire);
            if (a != last) {
                last = a;
                pp->flag_b.store(a, std::memory_order_release);           // echo
            } else if (c->stop.load(std::memory_order_acquire)) {
                return;
            } else {
                _mm_pause();
            }
        }
    }
}

// ─── Stats over per-window RTT samples (nanoseconds). ────────────────────────
static double percentile(const std::vector<double>& sorted, double p) {
    if (sorted.empty()) return 0.0;
    if (sorted.size() == 1) return sorted[0];
    double idx = p * (sorted.size() - 1);
    size_t lo = (size_t)idx;
    size_t hi = lo + 1 < sorted.size() ? lo + 1 : lo;
    double frac = idx - (double)lo;
    return sorted[lo] + (sorted[hi] - sorted[lo]) * frac;
}

struct PairStats {
    double median_ns = 0, iqr_ns = 0, min_ns = 0, max_ns = 0;
    size_t n = 0;
};

// Turn timed windows into per-round-trip ns; discard warmup; compute stats.
static PairStats finalize_stats(const std::vector<uint64_t>& win_cycles,
                                uint64_t warmup, uint64_t total, uint64_t K,
                                double ns_per_cycle, bool verbose,
                                const char* label) {
    std::vector<double> rtt_ns;
    rtt_ns.reserve(total - warmup);
    for (uint64_t w = warmup; w < total; ++w)
        rtt_ns.push_back((double)win_cycles[w] / (double)K * ns_per_cycle);

    if (verbose) {
        std::printf("    %s: per-window RTT ns =", label);
        for (double v : rtt_ns) std::printf(" %.1f", v);
        std::printf("\n");
    }

    std::sort(rtt_ns.begin(), rtt_ns.end());
    PairStats s;
    s.n = rtt_ns.size();
    if (!rtt_ns.empty()) {
        s.median_ns = percentile(rtt_ns, 0.50);
        s.iqr_ns    = percentile(rtt_ns, 0.75) - percentile(rtt_ns, 0.25);
        s.min_ns    = rtt_ns.front();
        s.max_ns    = rtt_ns.back();
    }
    return s;
}

// ─── The controlled arena. One 2 MiB, 2 MiB-aligned, THP-advised region; the
//     ping-pong line homes to a physical L3 slice picked by --offset. ──────────
struct Arena {
    unsigned char* base = nullptr;
    size_t size = 0;
    bool hugepage = false;      // did we actually get a transparent huge page?
    long anonhuge_kb = -1;      // AnonHugePages for this mapping, from smaps
};

// Read AnonHugePages (kB) for the smaps mapping containing `addr`. -1 if the
// mapping or field is not found. Header lines are "start-end perms ..."; only
// they yield two hex integers separated by '-', so `== 2` discriminates them
// from field lines ("AnonHugePages: N kB", "Rss: N kB", ...).
static long smaps_anonhuge_kb(uintptr_t addr) {
    std::ifstream f("/proc/self/smaps");
    if (!f) return -1;
    std::string line;
    bool in_range = false;
    while (std::getline(f, line)) {
        unsigned long start = 0, end = 0;
        if (std::sscanf(line.c_str(), "%lx-%lx", &start, &end) == 2) {
            in_range = (addr >= start && addr < end);
        } else if (in_range && line.rfind("AnonHugePages:", 0) == 0) {
            long kb = -1;
            std::sscanf(line.c_str(), "AnonHugePages: %ld kB", &kb);
            return kb;
        }
    }
    return -1;
}

static Arena arena_create() {
    Arena a;
    a.size = ARENA_SIZE;

    // 2 MiB alignment is what lets the kernel back the region with one THP and
    // what makes --offset a physical-address knob (past a 4 KiB page, virtual
    // offsets only track physical offsets when the whole span is one huge page).
    void* p = nullptr;
    if (posix_memalign(&p, ARENA_SIZE, ARENA_SIZE) != 0 || p == nullptr)
        die("arena: posix_memalign(%zu, %zu) failed: %s",
            ARENA_SIZE, ARENA_SIZE, std::strerror(errno));
    a.base = static_cast<unsigned char*>(p);

    if (madvise(a.base, a.size, MADV_HUGEPAGE) != 0)
        std::fprintf(stderr, "WARNING: madvise(MADV_HUGEPAGE) failed: %s "
                     "(THP may still collapse via khugepaged)\n", std::strerror(errno));

    // Touch every page to fault it in, so the mapping is fully backed and smaps
    // reports the real AnonHugePages figure.
    std::memset(a.base, 0, a.size);

    a.anonhuge_kb = smaps_anonhuge_kb(reinterpret_cast<uintptr_t>(a.base));
    a.hugepage = (a.anonhuge_kb >= (long)(ARENA_SIZE / 1024));  // fully THP-backed
    return a;
}

// Largest 64 B-aligned offset at which a full PingPongLines still fits.
static size_t arena_max_offset(const Arena& a) {
    size_t usable = a.size - sizeof(PingPongLines);
    return (usable / CACHELINE) * CACHELINE;
}

// ─── One measurement of a core pair at a given arena offset. ─────────────────
static PairStats measure_pair(Arena& arena, size_t offset,
                              int a, int b, int protocol, uint64_t K,
                              uint64_t windows, uint64_t warmup,
                              double ns_per_cycle, bool verbose) {
    if (a == b) die("cannot ping-pong a core against itself (a=b=%d)", a);
    const uint64_t total = warmup + windows;

    // Fresh, zero-initialised hot lines at arena+offset (trivially destructible
    // atomics — no teardown needed before the next placement-new).
    PingPongLines* pp = new (arena.base + offset) PingPongLines{};
    Control ctrl;  // cold control block on the orchestrator's stack

    std::vector<uint64_t> win_cycles(total, 0);
    WorkerCtx lead{pp, &ctrl, a, protocol, K, total, &win_cycles};
    WorkerCtx foll{pp, &ctrl, b, protocol, K, 0, nullptr};

    std::thread tl(leader_run, lead);
    std::thread tf(follower_run, foll);

    // Release the workers only once BOTH have pinned + asserted, so an affinity
    // failure aborts before any timing rather than mid-window.
    while (ctrl.pinned.load(std::memory_order_acquire) != 2) _mm_pause();
    ctrl.go.store(1, std::memory_order_release);

    tl.join();
    tf.join();

    char label[64];
    std::snprintf(label, sizeof(label), "pair (%d,%d)", a, b);
    return finalize_stats(win_cycles, warmup, total, K, ns_per_cycle, verbose, label);
}

// ─── Baseline: one pinned thread, line resident in its L1, no transfer. ──────
static PairStats measure_baseline(Arena& arena, size_t offset, int core,
                                  uint64_t K, uint64_t windows, uint64_t warmup,
                                  double ns_per_cycle, bool verbose) {
    const uint64_t total = warmup + windows;
    PingPongLines* pp = new (arena.base + offset) PingPongLines{};
    Control ctrl;

    std::vector<uint64_t> win_cycles(total, 0);
    WorkerCtx lead{pp, &ctrl, core, PROTO_BASELINE, K, total, &win_cycles};

    std::thread tl(leader_run, lead);
    while (ctrl.pinned.load(std::memory_order_acquire) != 1) _mm_pause();
    ctrl.go.store(1, std::memory_order_release);
    tl.join();

    char label[64];
    std::snprintf(label, sizeof(label), "baseline core %d", core);
    return finalize_stats(win_cycles, warmup, total, K, ns_per_cycle, verbose, label);
}

// ─── Across-allocation distribution (brief §Task 2). ─────────────────────────
struct RepeatStats {
    double med_of_med = 0, iqr = 0, min = 0, max = 0;
    std::vector<double> medians;  // sorted
};

static RepeatStats summarize_medians(std::vector<double> meds) {
    RepeatStats r;
    std::sort(meds.begin(), meds.end());
    r.medians = meds;
    if (!meds.empty()) {
        r.med_of_med = percentile(meds, 0.50);
        r.iqr        = percentile(meds, 0.75) - percentile(meds, 0.25);
        r.min        = meds.front();
        r.max        = meds.back();
    }
    return r;
}

// N pseudo-random, 64 B-aligned offsets into the arena, from `seed`. Full-arena
// range regardless of THP: for RANDOM sampling of slices, whichever physical
// frame each virtual page lands in is fine — only the systematic --offset-sweep
// needs contiguous physical memory (and is THP-gated). Reproducible per seed.
static std::vector<uint64_t> gen_offsets(uint64_t seed, uint64_t n, const Arena& arena) {
    std::mt19937_64 rng(seed);
    size_t nbuckets = arena_max_offset(arena) / CACHELINE + 1;
    std::vector<uint64_t> out;
    out.reserve(n);
    for (uint64_t i = 0; i < n; ++i)
        out.push_back((uint64_t)(rng() % nbuckets) * CACHELINE);
    return out;
}

static void print_median_list(const std::vector<double>& sorted) {
    std::printf("  sorted per-offset medians (ns):");
    for (double v : sorted) std::printf(" %.2f", v);
    std::printf("\n");
}

// ─── sysfs / procfs helpers ──────────────────────────────────────────────────
static std::string read_first_line(const char* path) {
    std::ifstream f(path);
    std::string line;
    if (f) std::getline(f, line);
    return line;
}

// Parse a Linux cpulist ("1-7", "0,2-3,5") into a sorted vector of ints.
static std::vector<int> parse_cpulist(const std::string& s) {
    std::vector<int> out;
    size_t i = 0;
    while (i < s.size()) {
        size_t comma = s.find(',', i);
        std::string tok = s.substr(i, comma == std::string::npos ? std::string::npos : comma - i);
        if (!tok.empty()) {
            size_t dash = tok.find('-');
            if (dash == std::string::npos) {
                out.push_back(std::atoi(tok.c_str()));
            } else {
                int lo = std::atoi(tok.substr(0, dash).c_str());
                int hi = std::atoi(tok.substr(dash + 1).c_str());
                for (int c = lo; c <= hi; ++c) out.push_back(c);
            }
        }
        if (comma == std::string::npos) break;
        i = comma + 1;
    }
    std::sort(out.begin(), out.end());
    out.erase(std::unique(out.begin(), out.end()), out.end());
    return out;
}

static std::string run_cmd(const char* cmd) {
    std::string out;
    FILE* p = popen(cmd, "r");
    if (!p) return "unknown";
    char buf[256];
    while (fgets(buf, sizeof(buf), p)) out += buf;
    pclose(p);
    while (!out.empty() && (out.back() == '\n' || out.back() == '\r')) out.pop_back();
    return out.empty() ? "unknown" : out;
}

static bool cpuinfo_has_flag(const char* flag) {
    std::ifstream f("/proc/cpuinfo");
    std::string line;
    while (std::getline(f, line)) {
        if (line.rfind("flags", 0) == 0)
            return line.find(std::string(" ") + flag + " ") != std::string::npos
                || line.find(std::string(" ") + flag) != std::string::npos;
    }
    return false;
}

// ─── TSC -> ns calibration against CLOCK_MONOTONIC over ~100 ms. ─────────────
static double calibrate_ns_per_cycle() {
    struct timespec t0, t1;
    uint64_t c0 = tsc_now();
    clock_gettime(CLOCK_MONOTONIC, &t0);
    struct timespec req{0, 100 * 1000 * 1000};  // 100 ms
    while (nanosleep(&req, &req) != 0 && errno == EINTR) { /* resume */ }
    uint64_t c1 = tsc_now();
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double ns  = (double)(t1.tv_sec - t0.tv_sec) * 1e9 + (double)(t1.tv_nsec - t0.tv_nsec);
    double cyc = (double)(c1 - c0);
    if (cyc <= 0) die("TSC did not advance during calibration — is rdtscp working?");
    return ns / cyc;
}

// ─── CLI ─────────────────────────────────────────────────────────────────────
static void usage(const char* prog) {
    std::printf(
        "Usage: %s [options]\n"
        "  Core-to-core cache-line ping-pong RTT (Machine 1 / Zen 2).\n\n"
        "Modes (pick one; default --full-matrix over the isolated set):\n"
        "  --pair a,b          measure one core pair; prints median + IQR\n"
        "  --full-matrix       measure every isolated pair; prints an RTT matrix\n"
        "  --include-core0     alone: measure core 0's row (0 vs each isolated core);\n"
        "                      with --full-matrix: add core 0 to the matrix set\n"
        "  --baseline          with --pair a,b: fixed-cost X on each of a and b\n"
        "                      (single thread, line in L1, no transfer, no spin)\n"
        "  --offset-sweep      with --pair a,b: median RTT vs arena offset\n\n"
        "Protocol / timing:\n"
        "  --protocol exchange|twoflag   handshake protocol (default: exchange)\n"
        "  --k K               round trips per timed window (default: 1000)\n"
        "  --windows W         timed windows kept (default: 20)\n"
        "  --warmup N          warmup windows discarded (default: 5)\n\n"
        "Arena / slice control (round 2):\n"
        "  --offset BYTES      ping-pong line at arena+BYTES; 64 B-aligned (default 0)\n"
        "  --repeat N          re-run at N random offsets; report the distribution\n"
        "                      of per-run medians (default 1 = single run)\n"
        "  --seed N            PRNG seed for --repeat offsets (default fixed)\n"
        "  --offset-sweep-range BYTES   sweep span (default 4096 = one page;\n"
        "                      >4096 needs a transparent huge page)\n"
        "  --orchestrator-core C        pin the orchestrator to core C (default 0)\n\n"
        "Misc:\n"
        "  --verbose           print per-window samples / per-pair progress\n"
        "  --help              this help\n",
        prog);
}

// Strict non-negative-integer parse. std::strtoull silently negates a leading
// '-' into a near-2^64 value, which would sail past the ==0 guards and either
// hang the harness (--k) or emit empty stats (--windows) — so reject anything
// that is not all digits, and catch overflow. Fail loudly, per the brief.
static bool is_all_digits(const std::string& s) {
    if (s.empty()) return false;
    for (char c : s) if (!std::isdigit((unsigned char)c)) return false;
    return true;
}
static uint64_t parse_count(const std::string& s, const char* name, bool allow_zero) {
    if (!is_all_digits(s))
        die("%s wants a non-negative integer, got '%s'", name, s.c_str());
    errno = 0;
    uint64_t v = std::strtoull(s.c_str(), nullptr, 10);
    if (errno == ERANGE) die("%s: '%s' is out of range", name, s.c_str());
    if (!allow_zero && v == 0) die("%s must be > 0", name);
    return v;
}
static int parse_core(const std::string& s, const char* ctx) {
    if (!is_all_digits(s)) die("%s: '%s' is not a valid core id", ctx, s.c_str());
    return (int)std::strtoul(s.c_str(), nullptr, 10);
}

int main(int argc, char** argv) {
    int protocol = PROTO_EXCHANGE;
    uint64_t K = 1000, windows = 20, warmup = 5;
    uint64_t repeat = 1, seed = DEFAULT_SEED, offset = 0, sweep_range = PAGE_SIZE;
    bool full_matrix = false, include_core0 = false, verbose = false;
    bool have_pair = false, baseline = false, offset_sweep = false;
    int pa = -1, pb = -1;
    int orchestrator_core = 0;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        auto next = [&](const char* name) -> std::string {
            if (i + 1 >= argc) die("%s requires an argument", name);
            return argv[++i];
        };
        if (arg == "--help" || arg == "-h") { usage(argv[0]); return 0; }
        else if (arg == "--full-matrix")  full_matrix = true;
        else if (arg == "--include-core0") include_core0 = true;
        else if (arg == "--verbose")      verbose = true;
        else if (arg == "--baseline")     baseline = true;
        else if (arg == "--offset-sweep") offset_sweep = true;
        else if (arg == "--protocol") {
            std::string p = next("--protocol");
            if (p == "exchange") protocol = PROTO_EXCHANGE;
            else if (p == "twoflag") protocol = PROTO_TWOFLAG;
            else die("unknown protocol '%s' (want exchange|twoflag)", p.c_str());
        }
        else if (arg == "--k")       K = parse_count(next("--k"), "--k", /*allow_zero=*/false);
        else if (arg == "--windows") windows = parse_count(next("--windows"), "--windows", false);
        else if (arg == "--warmup")  warmup = parse_count(next("--warmup"), "--warmup", /*allow_zero=*/true);
        else if (arg == "--repeat")  repeat = parse_count(next("--repeat"), "--repeat", /*allow_zero=*/false);
        else if (arg == "--seed")    seed = parse_count(next("--seed"), "--seed", /*allow_zero=*/true);
        else if (arg == "--offset")  offset = parse_count(next("--offset"), "--offset", /*allow_zero=*/true);
        else if (arg == "--offset-sweep-range")
            sweep_range = parse_count(next("--offset-sweep-range"), "--offset-sweep-range", false);
        else if (arg == "--orchestrator-core")
            orchestrator_core = parse_core(next("--orchestrator-core"), "--orchestrator-core");
        else if (arg == "--pair") {
            std::string v = next("--pair");
            size_t comma = v.find(',');
            if (comma == std::string::npos) die("--pair wants a,b (e.g. --pair 4,5)");
            pa = parse_core(v.substr(0, comma), "--pair");        // rejects empty/non-numeric
            pb = parse_core(v.substr(comma + 1), "--pair");       // (would silently become core 0)
            have_pair = true;
        }
        else die("unknown option '%s' (try --help)", arg.c_str());
    }
    if (K == 0)       die("--k must be > 0");
    if (windows == 0) die("--windows must be > 0");

    // ── Argument validation (brief §Acceptance). ──
    // Largest 64 B-aligned offset that still leaves room for a full PingPongLines.
    // A COMPILE-TIME constant, so the bounds test is `offset > OFFSET_MAX` — never
    // `offset + sizeof(...)`, which would wrap in uint64 and let a near-2^64 offset
    // sail past the guard into an out-of-bounds placement-new.
    constexpr uint64_t OFFSET_MAX =
        (uint64_t)((ARENA_SIZE - sizeof(PingPongLines)) / CACHELINE * CACHELINE);
    if (offset % CACHELINE != 0)
        die("--offset must be a multiple of 64 (got %" PRIu64 ")", offset);
    if (offset > OFFSET_MAX)
        die("--offset %" PRIu64 " too large for the %zu-byte arena (max %" PRIu64 ")",
            offset, ARENA_SIZE, OFFSET_MAX);
    if (sweep_range % CACHELINE != 0)
        die("--offset-sweep-range must be a multiple of 64 (got %" PRIu64 ")", sweep_range);
    long ncpu = sysconf(_SC_NPROCESSORS_ONLN);
    if (ncpu < 1) ncpu = 1;
    if (orchestrator_core < 0 || orchestrator_core >= ncpu)
        die("--orchestrator-core %d out of range [0,%ld) — no such online core",
            orchestrator_core, ncpu);

    // The orchestrator lives off the isolated set by default (core 0).
    pin_soft(orchestrator_core);

    // ── Header: state the measurement conditions every run. ──
    std::string isolated = read_first_line("/sys/devices/system/cpu/isolated");
    std::string nohz      = read_first_line("/sys/devices/system/cpu/nohz_full");
    std::string gfx       = run_cmd("systemctl is-active graphical.target 2>/dev/null");
    bool constant_tsc = cpuinfo_has_flag("constant_tsc");
    bool nonstop_tsc  = cpuinfo_has_flag("nonstop_tsc");
    double ns_per_cycle = calibrate_ns_per_cycle();
    double eff_ghz = ns_per_cycle > 0 ? 1.0 / ns_per_cycle : 0.0;

    Arena arena = arena_create();

    const char* proto_name = (protocol == PROTO_EXCHANGE) ? "exchange" : "twoflag";
    std::printf("==== core-to-core ping-pong (demo 10 §1 pilot) ====\n");
    std::printf("isolated cores : %s   nohz_full: %s\n",
                isolated.empty() ? "(none)" : isolated.c_str(),
                nohz.empty() ? "(none)" : nohz.c_str());
    std::printf("graphical.target: %s   (GUI up => a headless-only gate is unsafe)\n", gfx.c_str());
    std::printf("TSC->ns factor : %.6f ns/cycle  (~%.3f GHz invariant TSC)\n", ns_per_cycle, eff_ghz);
    std::printf("invariant TSC  : constant_tsc=%s nonstop_tsc=%s%s\n",
                constant_tsc ? "yes" : "NO", nonstop_tsc ? "yes" : "NO",
                (constant_tsc && nonstop_tsc) ? "" : "  <-- WARNING: ns portability depends on this");
    std::printf("arena          : %.0f MiB @ %p — %s (AnonHugePages=%ld kB)\n",
                arena.size / 1048576.0, (void*)arena.base,
                arena.hugepage ? "THP obtained" : "THP NOT obtained",
                arena.anonhuge_kb);
    if (!arena.hugepage)
        std::printf("  WARNING: transparent huge page NOT obtained — 4 KiB pages. Past a\n"
                    "  page boundary virtual offsets stop tracking physical offsets, so the\n"
                    "  offset sweep is clamped to one 4 KiB page.\n");
    std::printf("protocol=%s  K=%" PRIu64 "  windows=%" PRIu64 "  warmup=%" PRIu64
                "  orchestrator-core=%d\n",
                proto_name, K, windows, warmup, orchestrator_core);
    if (repeat > 1)
        std::printf("repeat=%" PRIu64 " (across-allocation)  seed=0x%016" PRIx64
                    "  offset=random\n\n", repeat, seed);
    else
        std::printf("repeat=1  offset=%" PRIu64 "\n\n", offset);

    // Offsets reused across every cell/core when --repeat is active, so intra
    // and cross are compared at the SAME set of slice placements (paired).
    std::vector<uint64_t> rep_offsets;
    if (repeat > 1) {
        rep_offsets = gen_offsets(seed, repeat, arena);
        if (verbose) {
            std::printf("repeat offsets (bytes, seed-derived — identical across runs of the "
                        "same seed):");
            for (uint64_t o : rep_offsets) std::printf(" %" PRIu64, o);
            std::printf("\n\n");
        }
    }

    // ── Baseline mode (brief §Task 4). ──
    if (baseline) {
        if (!have_pair)
            die("--baseline needs --pair a,b (it runs the baseline on each of a and b)");
        std::printf("baseline X — single thread, line resident in L1, two atomic stores per\n"
                    "round trip, no cross-core transfer, no spin-wait:\n");
        for (int core : {pa, pb}) {
            if (repeat > 1) {
                std::vector<double> meds;
                for (uint64_t off : rep_offsets)
                    meds.push_back(measure_baseline(arena, off, core, K, windows, warmup,
                                                    ns_per_cycle, verbose).median_ns);
                RepeatStats r = summarize_medians(meds);
                std::printf("  core %d: median-of-medians %.2f ns   IQR(medians) %.2f ns"
                            "   [min %.2f, max %.2f, n=%zu]\n",
                            core, r.med_of_med, r.iqr, r.min, r.max, r.medians.size());
                print_median_list(r.medians);
            } else {
                PairStats s = measure_baseline(arena, offset, core, K, windows, warmup,
                                               ns_per_cycle, verbose);
                std::printf("  core %d: median %.2f ns   IQR %.2f ns   [min %.2f, max %.2f, n=%zu]\n",
                            core, s.median_ns, s.iqr_ns, s.min_ns, s.max_ns, s.n);
            }
        }
        std::free(arena.base);
        return 0;
    }

    // ── Offset-sweep mode (brief §Task 3). ──
    if (offset_sweep) {
        if (!have_pair)
            die("--offset-sweep needs --pair a,b (one intra pair or one cross pair)");
        // The touched footprint differs by protocol: exchange/baseline move only
        // `seq` (64 B at off), twoflag moves flag_a and flag_b (up to off+192).
        // Without THP the whole footprint must stay inside ONE 4 KiB page, else
        // the top offsets spill into a physically-unrelated frame. For exchange
        // this leaves the brief's default 0..4032 untouched; for twoflag it pulls
        // the range in to 0..3904.
        const size_t footprint = (protocol == PROTO_TWOFLAG) ? sizeof(PingPongLines) : CACHELINE;
        size_t range = sweep_range;
        if (!arena.hugepage) {
            const size_t page_safe = PAGE_SIZE - footprint + CACHELINE;  // last off + footprint <= PAGE_SIZE
            if (range > page_safe) {
                std::printf("NOTE: THP not obtained; clamping sweep to %zu B so the swept %s\n"
                            "  footprint stays within one 4 KiB page (past a page boundary, virtual\n"
                            "  offsets stop tracking physical offsets and the sweep is meaningless).\n",
                            page_safe, proto_name);
                range = page_safe;
            }
        }
        size_t cap = arena_max_offset(arena) + CACHELINE;  // one past the last legal start
        if (range > cap) range = cap;
        std::printf("offset sweep — pair (%d,%d), protocol=%s, range=%zu B, step=64:\n",
                    pa, pb, proto_name, range);
        if (protocol == PROTO_TWOFLAG)
            std::printf("  (offset is the line-pair base; flag_a sits at offset+64, flag_b at offset+128)\n");
        std::printf("  offset_B    median_ns\n");
        for (size_t off = 0; off < range; off += CACHELINE) {
            PairStats s = measure_pair(arena, off, pa, pb, protocol, K, windows, warmup,
                                       ns_per_cycle, /*verbose=*/false);
            std::printf("  %8zu  %11.2f\n", off, s.median_ns);
        }
        std::free(arena.base);
        return 0;
    }

    // ── Single pair ──
    if (have_pair) {
        if (repeat > 1) {
            std::vector<double> meds;
            for (uint64_t off : rep_offsets)
                meds.push_back(measure_pair(arena, off, pa, pb, protocol, K, windows, warmup,
                                            ns_per_cycle, verbose).median_ns);
            RepeatStats r = summarize_medians(meds);
            std::printf("pair (%d,%d) across-allocation distribution — N=%" PRIu64
                        " offsets, seed=0x%016" PRIx64 ":\n", pa, pb, repeat, seed);
            std::printf("  median-of-medians %.2f ns   IQR(medians) %.2f ns   [min %.2f, max %.2f, n=%zu]\n",
                        r.med_of_med, r.iqr, r.min, r.max, r.medians.size());
            print_median_list(r.medians);
        } else {
            PairStats s = measure_pair(arena, offset, pa, pb, protocol, K, windows, warmup,
                                       ns_per_cycle, verbose);
            std::printf("pair (%d,%d) RTT: median %.2f ns   IQR %.2f ns   [min %.2f, max %.2f, n=%zu]\n",
                        pa, pb, s.median_ns, s.iqr_ns, s.min_ns, s.max_ns, s.n);
        }
        std::free(arena.base);
        return 0;
    }

    // Determine the working core set for matrix / core-0-row modes.
    std::vector<int> iso = parse_cpulist(isolated);
    if (iso.empty()) {
        // Off-rig fallback: use whatever cores this process may run on, so the
        // sanity build still exercises the harness. Numbers are meaningless.
        cpu_set_t set;
        CPU_ZERO(&set);
        if (sched_getaffinity(0, sizeof(set), &set) == 0)
            for (int c = 0; c < CPU_SETSIZE; ++c)
                if (CPU_ISSET(c, &set) && c != 0) iso.push_back(c);
        if (iso.empty()) iso.push_back(1);  // last resort
        std::fprintf(stderr,
            "WARNING: /sys/.../isolated is empty — using affinity-allowed cores %s "
            "(OFF-RIG: numbers are meaningless).\n",
            [&]{ std::string t; for (int c: iso){ t += std::to_string(c); t += ' '; } return t; }().c_str());
    }

    // ── Core-0 row mode: --include-core0 alone (A4). ──
    if (include_core0 && !full_matrix) {
        std::printf("core 0 row — RTT of core 0 against each isolated core (%s):\n", proto_name);
        for (int c : iso) {
            if (repeat > 1) {
                std::vector<double> meds;
                for (uint64_t off : rep_offsets)
                    meds.push_back(measure_pair(arena, off, 0, c, protocol, K, windows, warmup,
                                                ns_per_cycle, verbose).median_ns);
                RepeatStats r = summarize_medians(meds);
                std::printf("  0 <-> %-2d : med-of-med %8.2f ns   IQR(medians) %7.2f ns"
                            "   [min %.2f max %.2f]\n",
                            c, r.med_of_med, r.iqr, r.min, r.max);
            } else {
                PairStats s = measure_pair(arena, offset, 0, c, protocol, K, windows, warmup,
                                           ns_per_cycle, verbose);
                std::printf("  0 <-> %-2d : median %8.2f ns   IQR %7.2f ns\n", c, s.median_ns, s.iqr_ns);
            }
        }
        std::free(arena.base);
        return 0;
    }

    // ── Full matrix (default). ──
    std::vector<int> cores = iso;
    if (include_core0) { cores.insert(cores.begin(), 0); }
    std::sort(cores.begin(), cores.end());
    cores.erase(std::unique(cores.begin(), cores.end()), cores.end());

    const size_t n = cores.size();
    std::vector<std::vector<double>> rtt(n, std::vector<double>(n, -1.0));
    std::vector<std::vector<double>> iqr(n, std::vector<double>(n, -1.0));  // repeat only
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = i + 1; j < n; ++j) {
            if (verbose) std::fprintf(stderr, "  measuring pair (%d,%d)...\n", cores[i], cores[j]);
            if (repeat > 1) {
                std::vector<double> meds;
                for (uint64_t off : rep_offsets)
                    meds.push_back(measure_pair(arena, off, cores[i], cores[j], protocol, K,
                                                windows, warmup, ns_per_cycle, verbose).median_ns);
                RepeatStats r = summarize_medians(meds);
                rtt[i][j] = rtt[j][i] = r.med_of_med;
                iqr[i][j] = iqr[j][i] = r.iqr;
            } else {
                PairStats s = measure_pair(arena, offset, cores[i], cores[j], protocol, K,
                                           windows, warmup, ns_per_cycle, verbose);
                rtt[i][j] = rtt[j][i] = s.median_ns;
            }
        }
    }

    auto print_matrix = [&](const char* title, const std::vector<std::vector<double>>& m) {
        std::printf("%s\n\n", title);
        std::printf("     ");
        for (size_t j = 0; j < n; ++j) std::printf("%8d", cores[j]);
        std::printf("\n");
        for (size_t i = 0; i < n; ++i) {
            std::printf("%4d ", cores[i]);
            for (size_t j = 0; j < n; ++j) {
                if (i == j) std::printf("%8s", "-");
                else        std::printf("%8.1f", m[i][j]);
            }
            std::printf("\n");
        }
    };

    if (repeat > 1) {
        char title[128];
        std::snprintf(title, sizeof(title),
                      "median-of-medians RTT matrix (ns), protocol=%s, N=%" PRIu64
                      " offsets/cell, seed=0x%016" PRIx64 ":", proto_name, repeat, seed);
        print_matrix(title, rtt);
        std::printf("\n");
        print_matrix("across-allocation IQR matrix (ns) — IQR of the per-offset medians:", iqr);
        std::printf("\n(the IQR matrix is the point: it is the slice-placement error bar on each cell)\n");
    } else {
        char title[64];
        std::snprintf(title, sizeof(title), "median RTT matrix (ns), protocol=%s:", proto_name);
        print_matrix(title, rtt);
        std::printf("\n(rows/cols are core ids; each cell is the median round-trip ns for that pair)\n");
    }
    std::free(arena.base);
    return 0;
}
