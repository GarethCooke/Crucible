// benchmark.cpp — demo 10: core-to-core cache-line ping-pong RTT across the
// Zen 2 CCX boundary.
//
// Promoted from bench/pilot/10-core-to-core/pingpong.cpp (§1 calibration pilot,
// committed on pilot/demo-10-core-to-core for provenance). The measurement core
// is unchanged; what is new here is the production `--capture` path that emits
// the complete demo JSON, the slice-averaged cell design (§Task 4), and the
// per-pair orchestrator placement rule (§Task 3).
//
// What it measures
// ----------------
// The round-trip time for a single cache line to bounce between two pinned
// cores. Intra-CCX pairs exchange the line through their shared L3 slice;
// cross-CCX pairs go out to the IO die over Infinity Fabric. The ratio between
// those two is the CCX seam.
//
// Protocols
//   exchange (headline) — one shared alignas(64) atomic; leader advances
//                         even->odd, follower odd->even. One round trip is one
//                         even->odd->even cycle. Moves ONE line.
//   twoflag  (exhibit)  — two atomics on SEPARATE lines, one per direction.
//                         Moves two lines, so it pays the fabric crossing
//                         twice; retained as a comparison figure only.
//   baseline            — single thread, line resident in its own L1, the SAME
//                         two atomic stores as a round trip but no cross-core
//                         transfer and no spin-wait. Isolates the fixed cost X.
//
// Design invariants (from the pilot; do not relax)
//   * Affinity is asserted, not assumed: every worker AND the orchestrator read
//     back sched_getcpu() and abort if they are not on their requested core.
//   * No self-false-sharing: each ping-pong atomic is alignas(64) on its own
//     line; control/bookkeeping lives on a separate cold line; static_asserts
//     guard the gaps. (Demo 2's lesson applied to demo 2's own descendant.)
//   * acquire on the spin-load, release on the store. No seq_cst anywhere.
//   * rdtscp bracket per window of K round trips; warmup windows discarded;
//     median over the timed windows, reported in nanoseconds.
//   * The line lives at arena+offset inside a 2 MiB THP-advised arena, so
//     L3-slice placement is a controlled variable rather than an ASLR lottery.
//
// Slice modulation (§1/A6) and why cells are averaged over an ARENA POOL
// ----------------------------------------------------------------------
// Cache-line placement modulates RTT along TWO independent axes, and they are
// not the same axis:
//
//   * offset WITHIN a physical frame — cross-CCX RTT is bimodal on it (~160 vs
//     ~166 ns, a ~4% swing); intra-CCX is FLAT on it (§1/A6 swept a whole 2 MiB
//     frame and every intra offset came back 72.13 ns).
//   * WHICH physical frame the arena occupies — the high-order physical address
//     bits feed the Zen 2 L3 slice hash, and intra-CCX RTT varies on this one.
//
// The first design sampled `placements_per_cell` offsets inside ONE shared
// arena. That averages over the axis intra is flat on and is blind to the axis
// it varies on, so it reported whichever frame that single arena happened to
// land on with a false-confident error bar: two such captures of pair (1,2) came
// back 72.13 ns (IQR 0.01) and 79.93 ns (IQR 0.14) — 11% apart, error bars not
// even touching. Tight and wrong.
//
// So each cell is now measured across a POOL of `placement_arenas` independent
// arenas, allocated once at capture start and held live simultaneously (see
// pool_create: concurrent private anonymous mappings cannot share physical
// backing, which is what makes the frames distinct BY CONSTRUCTION). Placement
// `i` of every cell uses pool arena `i` at a per-cell seeded random 64 B-aligned
// offset, so the N placements span both axes at once. The SAME pool serves every
// cell, so cell-to-cell differences are core-pair effects and not frame-set
// differences. The cell value is the median of the per-placement medians and the
// error bar is the quartile spread ACROSS placements — now an honest one. That
// is what makes the two §6 captures agree.
//
// One caveat the pool does NOT close: distinct frames are not automatically
// INDEPENDENT frames. A pool allocated in one burst can be physically clustered
// in the high-order address bits that feed the slice hash, so a whole pool can
// occasionally land on one slice mode — a §7 protocol-exhibit capture came out
// 79.3 ns on pair (1,2) against the matrix's 72.1 ns, both with tight IQRs.
// That is what the §6 two-capture rule exists for, and why run_one.sh
// cross-checks the protocol exhibit's exchange cells against the matrix (5%
// band, fatal) before anything is archived: a correlated pool is a re-run
// signal, not a tolerable spread.
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
#include <ctime>
#include <fstream>
#include <new>
#include <random>
#include <string>
#include <thread>
#include <utility>
#include <vector>
#include <atomic>

#include "machine_info.h"
#include "stats.h"

#if !defined(__x86_64__)
#error "demo 10 is x86-64 only (Machine 1 / rdtscp). See README.md."
#endif
#include <x86intrin.h>

// ─── Canonical strings. Every string that reaches the JSON is a literal HERE,
//     never assembled in a script and never hand-edited into the data file
//     (demo 9's cores_physical/notes regression lesson). ─────────────────────
static const char* const DEMO_SLUG = "10-core-to-core";
static const char* const DEMO_TITLE =
    "Core-to-core latency: cache-line ping-pong RTT across the Zen 2 CCX boundary";
static const char* const PROTOCOL_EXCHANGE_NAME = "exchange";
static const char* const PROTOCOL_TWOFLAG_NAME  = "twoflag";
static const char* const MEMORY_ORDER_NAME      = "acq_rel";
static const char* const OFFSET_MODE            = "random_64B_aligned_per_arena";
static const char* const PLACEMENT_SAMPLING     = "independent_arena_pool";
static const char* const RTT_CONVENTION         = "round_trip";
static const char* const ORCHESTRATOR_PLACEMENT = "lowest-free-isolated";

// The canonical methodology string. Emitted verbatim as the JSON `notes` field.
static const char* const CAPTURE_NOTES =
    "Cache-line ping-pong round-trip time between two pinned cores. "
    "Protocol 'exchange': a single alignas(64) std::atomic<uint64_t> in a 2 MiB "
    "THP-advised arena; the leader stores even->odd and spins acquire until the "
    "follower stores odd->even. One round trip is one even->odd->even cycle, so "
    "the line crosses the interconnect twice. "
    "Timing is an lfence-bracketed rdtscp pair around a window of K round trips, "
    "converted to nanoseconds with a TSC factor calibrated against "
    "CLOCK_MONOTONIC; warmup windows are discarded. "
    "Values are REPORTED AS THE FULL ROUND TRIP and are never silently halved: "
    "a one-way figure is RTT/2 and must be named as such. "
    "Cache-line placement modulates RTT along two independent axes. Along the "
    "OFFSET WITHIN a physical frame, cross-CCX RTT is bimodal (L3 slice "
    "placement, ~4% swing) and intra-CCX is flat. Along WHICH physical frame the "
    "arena occupies -- the high-order physical address bits also feed the L3 "
    "slice hash -- intra-CCX varies too. Each cell is therefore measured across "
    "placement_arenas independent arena allocations, allocated once at capture "
    "start and held live SIMULTANEOUSLY: concurrent private anonymous mappings "
    "cannot share physical backing, so the arenas occupy distinct physical "
    "frames by construction rather than by luck. Placement i of every cell uses "
    "pool arena i at a per-cell pseudo-random 64 B-aligned offset drawn from "
    "offset_seed (offset_mode), so the placements span both axes at once, and "
    "the same pool serves every cell, so cell-to-cell differences are core-pair "
    "effects and not frame-set differences. This replaced an earlier design that "
    "drew placements_per_cell offsets inside ONE shared arena: that samples only "
    "the within-frame axis, which is the axis intra-CCX is flat on, so it "
    "reported whichever frame that arena happened to occupy with a "
    "false-confident error bar -- two such captures of the same intra-CCX pair "
    "differed by 11% with non-overlapping sub-0.2 ns IQRs. The figures here span "
    "both axes and the iqr is correspondingly honest. arenas_hugepage_obtained "
    "records how many pool arenas actually got a transparent huge page; arenas "
    "that did not are kept and measured, because a random offset in a 4 KiB-page "
    "arena still lands on a physical page whose address feeds the slice hash and "
    "is still a valid frame sample. The distribution summarised in rtt_ns is the "
    "distribution of the per-placement MEDIANS -- not of the raw timing windows. "
    "In that summary median/min/max are over the per-placement medians, "
    "iqr_lo and iqr_hi are the 25th and 75th percentiles of that same "
    "distribution in absolute nanoseconds (house convention, as in demo 07), iqr "
    "is iqr_hi minus iqr_lo, and n_reps is the number of placements. "
    "p99 is present in demos 01-08 and is intentionally omitted here: those "
    "distributions are raw per-rep latencies, where a 99th percentile is a "
    "meaningful tail, whereas cell stats here are computed over the "
    "placements_per_cell per-placement medians rather than raw windows, so a p99 "
    "would be the near-maximum of an already-averaged quantity and would invite "
    "a false tail reading. The across-placement spread is what iqr reports. "
    "baseline_ns is the fixed cost X per core: one thread, the line resident in "
    "its own L1, the same two atomic stores per iteration but no cross-core "
    "transfer and no spin-wait. X is ~0.6 ns against an intra-CCX RTT of order "
    "70-73 ns -- roughly 100x smaller, well under 1% of the figure -- so the "
    "reported RTT is essentially all transfer. "
    "pairs holds the 28 unordered core pairs; ping-pong RTT is symmetric by "
    "construction, so the chart mirrors them and the diagonal is not stored. "
    "CCX membership and l3_domain labels are read from "
    "/sys/devices/system/cpu/cpuN/cache/index3/shared_cpu_list, not inferred "
    "from core indices. Core 0 is the housekeeping core and is measured like any "
    "other: its row is clean under a headless capture. "
    "For each measured pair the orchestrator thread is pinned to the "
    "lowest-indexed isolated core outside the pair and asserts its own "
    "sched_getcpu(); during the timed region it is blocked in pthread_join, not "
    "spinning. "
    "Captured on bare metal (no hypervisor): the absolute nanoseconds stand "
    "without a virtualisation caveat. They do depend on the Infinity Fabric "
    "clock (FCLK) and are specific to this Matisse part; the intra/cross ratio "
    "is the portable claim, the absolute figures are not.";

static const char* const SLICE_SWEEP_NOTES =
    "Supporting exhibit for the per-cell error bar in 10-core-to-core.json. "
    "One intra-CCX and one cross-CCX pair, each swept across the arena at 64 B "
    "steps with everything else held fixed. Each point is the median of the "
    "timed windows at that single placement -- no across-placement averaging, "
    "which is the entire point: the cross-CCX series is bimodal on line address "
    "(L3 slice) while the intra-CCX series is flat. That modulation is what the "
    "matrix quantifies as an error bar rather than leaving as a confound. "
    "Values are full round trips, never halved. A sweep is only physically "
    "meaningful across contiguous memory, so without a transparent huge page "
    "the range is clamped to one 4 KiB page and arena_hugepage is false. "
    "This exhibit is SINGLE-FRAME BY DESIGN and is the one place in demo 10 that "
    "still is: the matrix in 10-core-to-core.json measures every cell across a "
    "pool of independent arena allocations so that it spans between-frame L3 "
    "slice placement as well, whereas showing the within-frame offset dependence "
    "requires one contiguous physical frame and nothing else. The multi-frame "
    "reasoning that applies to the matrix does not apply to these points.";

static const char* const PROTOCOL_NOTES =
    "Supporting exhibit for the protocol choice in 10-core-to-core.json. "
    "The headline uses 'exchange': one shared cache line, leader and follower "
    "alternating on it. 'twoflag' uses two atomics on SEPARATE lines, one per "
    "direction, so each round trip drags two lines across the interconnect and "
    "the cross-CCX cost comes out materially higher -- about 1.5x the exchange "
    "figure on this rig -- a larger ratio that measures a different thing. "
    "Both protocols are measured on the same intra-CCX and cross-CCX pair, at "
    "the same K and over the same pool of placement_arenas independent arena "
    "allocations held live simultaneously (distinct physical frames), the "
    "matrix's sampling design -- so exchange and twoflag are paired on frame "
    "placement WITHIN this exhibit and their comparison is clean. This exhibit "
    "is its own capture with its own pool, though, so its frames are NOT the "
    "matrix capture's frames: arenas allocated in one burst can be correlated "
    "in the high-order physical-address bits that feed the L3 slice hash, and "
    "a whole pool can land on one slice mode. The exchange cells here "
    "therefore double as a cross-capture probe rather than being assumed "
    "directly comparable -- run_one.sh fails the capture if they disagree "
    "with the matrix cells for the same pairs by more than 5%. Statistics "
    "follow the matrix convention: the "
    "distribution is the per-placement medians, iqr_lo/iqr_hi are absolute "
    "quartiles and iqr is their difference, p99 is omitted for the same reason "
    "it is omitted from the matrix (it would be the near-maximum of an averaged "
    "quantity, not a tail), and values are full round trips.";

// ─── fatal error helper ──────────────────────────────────────────────────────
// format(printf) on both varargs helpers: -Wall only checks format strings it
// recognises, and these would otherwise be invisible to it. Every %zu/PRIu64
// mismatch in the diagnostics below is a compile error because of this.
[[noreturn]] __attribute__((format(printf, 1, 2)))
static void die(const char* fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    std::fprintf(stderr, "ERROR: ");
    std::vfprintf(stderr, fmt, ap);
    std::fprintf(stderr, "\n");
    va_end(ap);
    std::exit(2);
}

// Human-readable progress. In capture modes stdout carries the JSON and nothing
// else, so every byte of chatter is routed here instead.
static FILE* g_info = stdout;
__attribute__((format(printf, 1, 2)))
static void info(const char* fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    std::vfprintf(g_info, fmt, ap);
    va_end(ap);
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
// A pool arena costs 2 MiB of resident memory and the capture holds them all at
// once, so --repeat is bounded: 256 arenas is 512 MiB, far past anything useful
// and still short of trouble. Without this, --repeat 100000 would try for 200 GB.
static constexpr uint64_t MAX_POOL_ARENAS = 256;
// Fixed default so two captures draw the same placement sequence unless the
// caller overrides --seed. Golden-ratio constant, no significance beyond that.
static constexpr uint64_t DEFAULT_SEED = 0x9E3779B97F4A7C15ULL;

// Locked capture parameters (§1: K from A3, placements from A6).
static constexpr uint64_t LOCKED_K           = 1000;
static constexpr uint64_t LOCKED_WINDOWS     = 20;
static constexpr uint64_t LOCKED_WARMUP      = 5;
static constexpr uint64_t LOCKED_PLACEMENTS  = 20;

// ─── The hot ping-pong lines, overlaid on the arena at a chosen offset. Each
//     atomic gets its own 64-byte line; moving the struct by --offset moves all
//     three together. A placement-new per measurement resets them to zero. ─────
struct PingPongLines {
    alignas(64) std::atomic<uint64_t> seq;     // exchange / baseline: one shared line
    alignas(64) std::atomic<uint64_t> flag_a;  // twoflag A->B: own line
    alignas(64) std::atomic<uint64_t> flag_b;  // twoflag B->A: own line
};
static_assert(offsetof(PingPongLines, seq) == 0,
              "seq must sit exactly at arena+offset");
static_assert(offsetof(PingPongLines, flag_a) - offsetof(PingPongLines, seq)    >= 64,
              "seq and flag_a must not share a cache line");
static_assert(offsetof(PingPongLines, flag_b) - offsetof(PingPongLines, flag_a) >= 64,
              "flag_a and flag_b must not share a cache line");
static_assert(alignof(PingPongLines) >= 64,
              "ping-pong lines must be cache-line aligned within the arena");

// ─── Cold control block. `stop` IS polled by the follower inside the timed
//     region, but only ever read there: the line settles into shared state on
//     the first poll and generates no coherence traffic until the leader's one
//     store at the end, so it cannot perturb the measurement. It lives on the
//     orchestrator's stack, well away from the arena. ─────────────────────────
struct Control {
    alignas(64) std::atomic<uint64_t> stop{0};
    std::atomic<uint64_t> pinned{0};
    std::atomic<uint64_t> go{0};
};
static_assert(alignof(Control) >= 64,
              "control block must start on its own cache line");

enum Protocol { PROTO_EXCHANGE = 0, PROTO_TWOFLAG = 1, PROTO_BASELINE = 2 };

static const char* protocol_name(int p) {
    return (p == PROTO_TWOFLAG) ? PROTOCOL_TWOFLAG_NAME : PROTOCOL_EXCHANGE_NAME;
}

struct WorkerCtx {
    PingPongLines* pp;
    Control* ctrl;
    int core;
    int protocol;
    uint64_t K;
    uint64_t n_windows;                 // warmup + timed (leader/baseline only)
    std::vector<uint64_t>* win_cycles;  // leader writes one entry per window
};

// Timing shape of one measurement, so the locked triple travels together.
struct Timing {
    uint64_t k = LOCKED_K;
    uint64_t windows = LOCKED_WINDOWS;
    uint64_t warmup = LOCKED_WARMUP;
};

// ─── Pin the calling thread to `core` and PROVE it landed there. ─────────────
// A single-CPU affinity mask forces migration, but the kernel defers it to the
// next reschedule, so we yield and re-read sched_getcpu() until it agrees.
// Used for the workers AND — since §Task 3 made core 0 a measured worker — for
// the orchestrator, which now has to move per pair.
static void pin_and_assert(int core, const char* who) {
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(core, &set);
    int rc = pthread_setaffinity_np(pthread_self(), sizeof(set), &set);
    if (rc != 0)
        die("pthread_setaffinity_np(%s, core=%d) failed: %s",
            who, core, std::strerror(rc));

    for (int tries = 0; tries < 100000; ++tries) {
        if (sched_getcpu() == core) return;
        sched_yield();
    }
    die("AFFINITY ASSERT FAILED (%s): requested core %d but sched_getcpu()=%d — "
        "the thread never migrated. STOP and report this core.",
        who, core, sched_getcpu());
}

// ─── The window scaffold, shared by every protocol: an rdtscp bracket around K
//     round trips, one entry in win_cycles per window. This being ONE function
//     is what makes "all protocols are timed identically" true by construction
//     rather than by inspection — the bracket cannot drift per protocol. The
//     body is a template parameter so it inlines at -O3 and the scaffold adds
//     no call into the timed region (verified by diffing leader_run's
//     disassembly against the pre-refactor build).
template <class RoundTrip>
static void timed_windows(const WorkerCtx& ctx, RoundTrip&& one_round_trip) {
    for (uint64_t w = 0; w < ctx.n_windows; ++w) {
        const uint64_t t0 = tsc_now();
        for (uint64_t k = 0; k < ctx.K; ++k) one_round_trip();
        const uint64_t t1 = tsc_now();
        (*ctx.win_cycles)[w] = t1 - t0;
    }
}

// ─── Leader / baseline: drives the protocol and brackets each window with
//     rdtscp. Baseline runs alone; exchange/twoflag pair with a follower. ──────
static void leader_run(WorkerCtx ctx) {
    PingPongLines* pp = ctx.pp;
    Control* c = ctx.ctrl;
    pin_and_assert(ctx.core, "leader");
    c->pinned.fetch_add(1, std::memory_order_release);
    while (c->go.load(std::memory_order_acquire) == 0) _mm_pause();

    if (ctx.protocol == PROTO_EXCHANGE) {
        uint64_t local = 0;  // seq starts even; leader owns even->odd transitions
        timed_windows(ctx, [&] {
            pp->seq.store(local + 1, std::memory_order_release);          // ping (odd)
            while (pp->seq.load(std::memory_order_acquire) != local + 2)
                _mm_pause();                                              // await pong
            local += 2;
        });
    } else if (ctx.protocol == PROTO_TWOFLAG) {
        uint64_t token = 0;
        timed_windows(ctx, [&] {
            ++token;
            pp->flag_a.store(token, std::memory_order_release);           // ping
            while (pp->flag_b.load(std::memory_order_acquire) != token)
                _mm_pause();                                              // await echo
        });
    } else {  // PROTO_BASELINE — single thread, line stays in L1, no follower.
        // Perform the SAME two atomic stores a round trip performs (the leader's
        // even->odd store and the follower's odd->even store), so X is a like-
        // for-like fixed cost. The spin-wait is skipped: with no follower it
        // would be satisfied immediately anyway. The C++ memory model would
        // technically permit coalescing the first store into the second (no
        // reader forces it); GCC/Clang don't today, but the signal fence — a
        // COMPILER-only barrier that emits no instruction, so X is unaffected —
        // guarantees both stores survive on any conforming compiler.
        uint64_t local = 0;
        timed_windows(ctx, [&] {
            pp->seq.store(local + 1, std::memory_order_release);          // ping store
            std::atomic_signal_fence(std::memory_order_release);          // keep both stores; no runtime cost
            pp->seq.store(local + 2, std::memory_order_release);          // pong store
            local += 2;
        });
    }
    if (ctx.protocol != PROTO_BASELINE)
        c->stop.store(1, std::memory_order_release);
}

// ─── The follower's spin scaffold: act on the line if there is work, otherwise
//     check stop, otherwise pause. `poll_once` returns true when it made
//     progress. Shared for the same reason as timed_windows: the stop-check /
//     pause ordering is part of the measurement contract. ──────────────────────
template <class Poll>
static void follow_until_stop(Control* c, Poll&& poll_once) {
    for (;;) {
        if (poll_once()) continue;
        if (c->stop.load(std::memory_order_acquire)) return;
        _mm_pause();
    }
}

// ─── Follower: mirrors the leader's line, exits when stop is set. ─────────────
static void follower_run(WorkerCtx ctx) {
    PingPongLines* pp = ctx.pp;
    Control* c = ctx.ctrl;
    pin_and_assert(ctx.core, "follower");
    c->pinned.fetch_add(1, std::memory_order_release);
    while (c->go.load(std::memory_order_acquire) == 0) _mm_pause();

    if (ctx.protocol == PROTO_EXCHANGE) {
        follow_until_stop(c, [&] {
            uint64_t cur = pp->seq.load(std::memory_order_acquire);
            if (!(cur & 1ULL)) return false;
            pp->seq.store(cur + 1, std::memory_order_release);            // pong (even)
            return true;
        });
    } else {  // PROTO_TWOFLAG
        uint64_t last = 0;
        follow_until_stop(c, [&] {
            uint64_t a = pp->flag_a.load(std::memory_order_acquire);
            if (a == last) return false;
            last = a;
            pp->flag_b.store(a, std::memory_order_release);               // echo
            return true;
        });
    }
}

// ─── Statistics ──────────────────────────────────────────────────────────────
// The house `stats` shape is EIGHT fields — median, min, max, p99, iqr, iqr_lo,
// iqr_hi, n_reps — as emitted by every `ns_per_op` in demo 07 and its siblings.
// Demo 10 emits seven of them, a clean subset: p99 is deliberately omitted
// because this distribution is the per-placement MEDIANS, so its 99th percentile
// is the near-max of an already-averaged quantity, not a latency tail. That
// omission is stated in CAPTURE_NOTES so a cross-read cannot mistake it for an
// oversight.
//
// iqr_lo/iqr_hi are ABSOLUTE quartiles in ns — Q1 and Q3, exactly as demo 07
// emits them, not widths around the median — and iqr is their difference, taken
// at full precision before rounding, exactly as bench/scripts/stats_utils.py
// does it (`round(p75 - p25, 4)`, not the difference of the rounded quartiles).
// A degenerate cell — all placements identical, which an entirely stable intra
// pair can produce — gives iqr == 0. That is a correct answer, not an error: the
// field is still emitted and nothing divides by it.
struct HouseStats {
    double median = 0, min = 0, max = 0, iqr = 0, iqr_lo = 0, iqr_hi = 0;
    int n_reps = 0;
};

static HouseStats house_stats(const std::vector<double>& v) {
    HouseStats s;
    if (v.empty()) return s;
    const auto mp = crucible::multi_percentile(v);
    s.median = mp.p50;
    s.min    = mp.min;
    s.max    = mp.max;
    s.iqr    = mp.p75 - mp.p25;
    s.iqr_lo = mp.p25;
    s.iqr_hi = mp.p75;
    s.n_reps = static_cast<int>(v.size());
    return s;
}

// Turn timed windows into per-round-trip ns; discard warmup; return the median.
// This is the inner statistic — one number per placement.
//
// `out_windows`, when given, also hands back the timed-window distribution. The
// capture path never wants it (a cell's distribution is the across-PLACEMENT
// medians, per §Task 4), but the single-placement diagnostics do: without it
// they would have exactly one sample to summarise and would print a spread of
// zero, where the §1 pilot printed the per-window IQR. §4 compares against the
// pilot, so the diagnostics have to report what the pilot reported.
static double window_median_ns(const std::vector<uint64_t>& win_cycles,
                               const Timing& t, double ns_per_cycle,
                               bool verbose, const char* label,
                               std::vector<double>* out_windows = nullptr) {
    std::vector<double> rtt_ns;
    rtt_ns.reserve(t.windows);
    for (uint64_t w = t.warmup; w < t.warmup + t.windows; ++w)
        rtt_ns.push_back((double)win_cycles[w] / (double)t.k * ns_per_cycle);

    if (verbose) {
        info("    %s: per-window RTT ns =", label);
        for (double v : rtt_ns) info(" %.1f", v);
        info("\n");
    }
    double med = crucible::median(rtt_ns);
    if (out_windows) *out_windows = std::move(rtt_ns);
    return med;
}

// ─── The controlled arena. One 2 MiB, 2 MiB-aligned, THP-advised region; the
//     ping-pong line homes to a physical L3 slice picked by its offset AND by
//     which physical frame the region occupies. ──────────────────────────────
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

// One arena is its OWN private anonymous mapping — mmap directly, not
// posix_memalign. Two things turn on that:
//   * a private anonymous mapping that has been written to is backed by physical
//     frames belonging to it alone; two such mappings held live at the same time
//     therefore cannot share a physical frame. That is the guarantee the pool
//     rests on, and it is a property of the mapping, not of the allocator that
//     happened to hand out the address.
//   * munmap returns the frames at teardown, so holding a pool of them costs
//     exactly what it looks like it costs.
// Over-map by one arena and trim so the result is 2 MiB-ALIGNED: alignment is
// what lets the kernel back the region with one THP, and what makes the offset a
// physical-address knob (past a 4 KiB page, virtual offsets only track physical
// offsets when the whole span is one huge page).
static Arena arena_create() {
    Arena a;
    a.size = ARENA_SIZE;

    const size_t span = ARENA_SIZE * 2;
    void* raw = mmap(nullptr, span, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (raw == MAP_FAILED)
        die("arena: mmap(%zu) failed: %s", span, std::strerror(errno));

    uintptr_t start   = reinterpret_cast<uintptr_t>(raw);
    uintptr_t aligned = (start + ARENA_SIZE - 1) & ~(uintptr_t)(ARENA_SIZE - 1);
    const size_t head = aligned - start;
    const size_t tail = span - head - ARENA_SIZE;
    if (head) munmap(raw, head);
    if (tail) munmap(reinterpret_cast<void*>(aligned + ARENA_SIZE), tail);
    a.base = reinterpret_cast<unsigned char*>(aligned);

    if (madvise(a.base, a.size, MADV_HUGEPAGE) != 0)
        std::fprintf(stderr, "WARNING: madvise(MADV_HUGEPAGE) failed: %s "
                     "(THP may still collapse via khugepaged)\n", std::strerror(errno));

    // Touch every page to fault it in. This is load-bearing for the pool, not
    // just for smaps: an unfaulted anonymous mapping is backed by the shared
    // zero page, so until it is WRITTEN the arenas do not occupy distinct
    // physical frames at all. memset commits them.
    std::memset(a.base, 0, a.size);

    a.anonhuge_kb = smaps_anonhuge_kb(reinterpret_cast<uintptr_t>(a.base));
    a.hugepage = (a.anonhuge_kb >= (long)(ARENA_SIZE / 1024));  // fully THP-backed
    return a;
}

static void arena_destroy(Arena& a) {
    if (a.base) munmap(a.base, a.size);
    a.base = nullptr;
}

// ─── The arena POOL — the fix for single-frame placement sampling. ───────────
// `n` independent arenas, allocated once and held live for the whole capture so
// that their physical frames are distinct by construction (see arena_create).
// Every cell measures placement i in arenas[i], so all cells see the same set of
// frames and cell-to-cell differences stay pure core-pair effects.
//
// Distinct is NOT independent (see the header comment): a pool allocated in one
// burst can be slice-correlated, which the §6 two-capture rule and run_one.sh's
// exhibit-vs-matrix cross-check exist to catch.
struct ArenaPool {
    std::vector<Arena> arenas;
    int hugepage_obtained = 0;  // how many of them actually got a THP
};

static ArenaPool pool_create(uint64_t n) {
    if (n < 1) die("internal: arena pool needs at least one arena");
    if (n > MAX_POOL_ARENAS)
        die("arena pool of %" PRIu64 " would reserve %" PRIu64 " MiB; the cap is "
            "%" PRIu64 " arenas. Lower --repeat.",
            n, n * (uint64_t)(ARENA_SIZE / 1048576), MAX_POOL_ARENAS);

    ArenaPool p;
    p.arenas.reserve(n);
    for (uint64_t i = 0; i < n; ++i) {
        p.arenas.push_back(arena_create());
        if (p.arenas.back().hugepage) ++p.hugepage_obtained;
    }
    return p;
}

static void pool_destroy(ArenaPool& p) {
    for (auto& a : p.arenas) arena_destroy(a);
    p.arenas.clear();
}

// Largest 64 B-aligned offset at which a full PingPongLines still fits. Every
// arena is ARENA_SIZE, so this is a compile-time property of the arena shape and
// not of any particular allocation — main's bounds check uses the same constant.
static constexpr size_t ARENA_MAX_OFFSET =
    (ARENA_SIZE - sizeof(PingPongLines)) / CACHELINE * CACHELINE;
static constexpr size_t OFFSET_BUCKETS = ARENA_MAX_OFFSET / CACHELINE + 1;

// ─── One measurement at arena+offset: a pinned leader/follower pair for
//     exchange and twoflag, or a single pinned thread for the baseline (pass
//     a == b with PROTO_BASELINE; the line stays in its L1, no transfer).
//     The orchestrator must already be pinned OFF the cores involved (see
//     orchestrator_for). ────────────────────────────────────────────────────
static double measure_placement(Arena& arena, size_t offset,
                                int a, int b, int protocol, const Timing& t,
                                double ns_per_cycle, bool verbose,
                                std::vector<double>* out_windows = nullptr) {
    const bool solo = (protocol == PROTO_BASELINE);
    if (!solo && a == b) die("cannot ping-pong a core against itself (a=b=%d)", a);
    const uint64_t total = t.warmup + t.windows;

    // Fresh, zero-initialised hot lines at arena+offset (trivially destructible
    // atomics — no teardown needed before the next placement-new).
    PingPongLines* pp = new (arena.base + offset) PingPongLines{};
    Control ctrl;  // cold control block on the orchestrator's stack

    std::vector<uint64_t> win_cycles(total, 0);
    WorkerCtx lead{pp, &ctrl, a, protocol, t.k, total, &win_cycles};

    std::thread tl(leader_run, lead);
    std::thread tf;  // default-constructed: not joinable unless a follower runs
    if (!solo) {
        WorkerCtx foll{pp, &ctrl, b, protocol, t.k, 0, nullptr};
        tf = std::thread(follower_run, foll);
    }

    // Release the workers only once ALL have pinned + asserted, so an affinity
    // failure aborts before any timing rather than mid-window.
    const uint64_t need = solo ? 1 : 2;
    while (ctrl.pinned.load(std::memory_order_acquire) != need) _mm_pause();
    ctrl.go.store(1, std::memory_order_release);

    // From here to the joins the orchestrator sleeps in futex, not spinning
    // (A8): its placement cannot perturb the workers.
    tl.join();
    if (tf.joinable()) tf.join();

    char label[64];
    if (solo) std::snprintf(label, sizeof(label), "baseline core %d", a);
    else      std::snprintf(label, sizeof(label), "pair (%d,%d)", a, b);
    return window_median_ns(win_cycles, t, ns_per_cycle, verbose, label, out_windows);
}

// N pseudo-random, 64 B-aligned offsets into an arena, from `seed`. Full-arena
// range regardless of THP: for RANDOM sampling of slices, whichever physical
// frame each virtual page lands in is fine — only the systematic sweep needs
// contiguous physical memory (and is THP-gated).
static std::vector<uint64_t> gen_offsets(uint64_t seed, uint64_t n) {
    std::mt19937_64 rng(seed);
    std::vector<uint64_t> out;
    out.reserve(n);
    for (uint64_t i = 0; i < n; ++i)
        out.push_back((uint64_t)(rng() % OFFSET_BUCKETS) * CACHELINE);
    return out;
}

// Each cell draws its own offset sequence, deterministically, from the capture
// seed plus the cell's identity. Keyed on identity rather than on a running
// counter so a cell's placements do not depend on how many cells ran before it —
// re-measuring one pair in a diagnostic mode reproduces the capture's offsets.
//
// Pairing across cells is carried by the arena POOL (placement i is arena i for
// every cell), not by the offsets: it is the frame that has to be held constant
// to keep cell-to-cell differences pure, and drawing per-cell offsets on top of
// it samples the within-frame axis more widely than one shared sequence would.
static uint64_t splitmix64(uint64_t x) {
    x += 0x9E3779B97F4A7C15ULL;
    x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9ULL;
    x = (x ^ (x >> 27)) * 0x94D049BB133111EBULL;
    return x ^ (x >> 31);
}

// (protocol, a, b) is unique per cell; baselines pass a == b == the core, which
// cannot collide with a pair cell because a pair never has a == b. The pair is
// canonicalised to a <= b first so the seed is a property of the UNORDERED pair
// — RTT is symmetric, and `--pair 4,1` must draw the same offsets the capture
// drew for its (1,4) cell, not a different sequence.
static uint64_t cell_seed(uint64_t seed, int protocol, int a, int b) {
    if (a > b) std::swap(a, b);
    const uint64_t key = ((uint64_t)(uint32_t)protocol << 40)
                       | ((uint64_t)(uint32_t)a << 20)
                       |  (uint64_t)(uint32_t)b;
    return splitmix64(seed ^ splitmix64(key));
}

// ─── sysfs / procfs helpers ──────────────────────────────────────────────────
static std::string read_first_line(const char* path) {
    std::ifstream f(path);
    std::string line;
    if (f) std::getline(f, line);
    while (!line.empty() && (line.back() == '\n' || line.back() == '\r' || line.back() == ' '))
        line.pop_back();
    return line;
}

static int parse_core(const std::string& s, const char* ctx);  // strict; defined with the CLI

// Parse a Linux cpulist ("1-7", "0,2-3,5") into a sorted, deduplicated vector.
// Strict for the same reason parse_count is: atoi would fold a typo'd token
// into core 0 silently, and `--cores 1,2,x` measuring core 0 is exactly the
// plausible-but-wrong shape this demo refuses elsewhere. `what` names the
// source in the error; the sysfs sources are well-formed by construction, so in
// practice this bites only --cores.
static std::vector<int> parse_cpulist(const std::string& s, const char* what) {
    std::vector<int> out;
    size_t i = 0;
    while (i < s.size()) {
        size_t comma = s.find(',', i);
        std::string tok = s.substr(i, comma == std::string::npos ? std::string::npos : comma - i);
        if (!tok.empty()) {
            size_t dash = tok.find('-');
            if (dash == std::string::npos) {
                out.push_back(parse_core(tok, what));
            } else {
                int lo = parse_core(tok.substr(0, dash), what);
                int hi = parse_core(tok.substr(dash + 1), what);
                if (lo > hi)
                    die("%s: descending range '%s'", what, tok.c_str());
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

// The L3 domain a core belongs to, straight from sysfs. On Zen 2, L3
// shared_cpu_list sharing IS CCX membership — which is why the matrix labels
// come from here and never from the core index.
static std::string l3_domain_of(int cpu) {
    char path[256];
    // The L3 node is index3 on every part we care about, but confirm by reading
    // `level` rather than trusting the index — a core with a different cache
    // layout would otherwise be silently mislabelled.
    for (int idx = 0; idx < 10; ++idx) {
        std::snprintf(path, sizeof(path),
                      "/sys/devices/system/cpu/cpu%d/cache/index%d/level", cpu, idx);
        std::string level = read_first_line(path);
        if (level != "3") continue;
        std::snprintf(path, sizeof(path),
                      "/sys/devices/system/cpu/cpu%d/cache/index%d/shared_cpu_list", cpu, idx);
        std::string dom = read_first_line(path);
        if (!dom.empty()) return dom;
    }
    return "";
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

// ─── JSON helpers ────────────────────────────────────────────────────────────

// UTC, Z-suffix, exactly the format demos 1/3/4 stamp. Never "+00:00".
static std::string utc_now_z() {
    std::time_t now = std::time(nullptr);
    std::tm tm{};
    gmtime_r(&now, &tm);
    char buf[32];
    std::strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &tm);
    return std::string(buf);
}

// 4 dp, trailing zeros trimmed — matches the rounding the Python assemblers
// apply (round(x, 4)) so demo 10's numbers read like every other demo's.
static std::string jnum(double v) {
    char b[64];
    std::snprintf(b, sizeof(b), "%.4f", v);
    std::string s(b);
    if (s.find('.') != std::string::npos) {
        while (!s.empty() && s.back() == '0') s.pop_back();
        if (!s.empty() && s.back() == '.') s.pop_back();
    }
    return s.empty() ? "0" : s;
}

// Field order follows the house shape (demo 07's ns_per_op) so demo 10 reads as
// a subset of it and not as a different schema. p99 is the one omission.
static void emit_house_stats(const HouseStats& s, const char* indent) {
    std::printf("%s\"median\": %s, \"min\": %s, \"max\": %s, "
                "\"iqr\": %s, \"iqr_lo\": %s, \"iqr_hi\": %s, \"n_reps\": %d",
                indent,
                jnum(s.median).c_str(), jnum(s.min).c_str(), jnum(s.max).c_str(),
                jnum(s.iqr).c_str(),
                jnum(s.iqr_lo).c_str(), jnum(s.iqr_hi).c_str(), s.n_reps);
}

// ─── Topology ────────────────────────────────────────────────────────────────
struct CoreInfo {
    int cpu = 0;
    int ccx = 0;
    std::string l3_domain;
    bool housekeeping = false;
};

// Build the per-core topology block. CCX indices are assigned by first
// appearance over the ascending core list, so CCX 0 is always the domain
// containing the lowest measured core.
static std::vector<CoreInfo> build_cores(const std::vector<int>& cores,
                                         const std::vector<int>& isolated) {
    std::vector<CoreInfo> out;
    std::vector<std::string> domains;
    bool any_missing = false;

    for (int c : cores) {
        CoreInfo ci;
        ci.cpu = c;
        ci.l3_domain = l3_domain_of(c);
        if (ci.l3_domain.empty()) any_missing = true;
        ci.housekeeping =
            std::find(isolated.begin(), isolated.end(), c) == isolated.end();
        auto it = std::find(domains.begin(), domains.end(), ci.l3_domain);
        if (it == domains.end()) {
            ci.ccx = (int)domains.size();
            domains.push_back(ci.l3_domain);
        } else {
            ci.ccx = (int)(it - domains.begin());
        }
        out.push_back(ci);
    }

    if (any_missing)
        std::fprintf(stderr,
            "WARNING: could not read an L3 shared_cpu_list for at least one core; "
            "those cores are grouped into a single unnamed CCX. The matrix is "
            "still valid but its CCX labels are not sysfs-derived.\n");
    return out;
}

static const CoreInfo& core_info(const std::vector<CoreInfo>& v, int cpu) {
    for (const auto& c : v) if (c.cpu == cpu) return c;
    die("internal: core %d not in the measured set", cpu);
}

static bool same_ccx(const std::vector<CoreInfo>& v, int a, int b) {
    return core_info(v, a).ccx == core_info(v, b).ccx;
}

// §Task 3 — the orchestrator must own a core neither worker is using, so that
// both workers own theirs for every pair including core-0 pairs. Rule:
// lowest-indexed core in the isolated set that is not in {a, b}. `b == a` means
// "exclude one core only" (the baseline case).
static int orchestrator_for(const std::vector<int>& isolated,
                            const std::vector<int>& fallback, int a, int b) {
    for (int c : isolated) if (c != a && c != b) return c;
    for (int c : fallback) if (c != a && c != b) return c;
    return -1;
}

// Every core this process is allowed to run on — the off-rig fallback pool.
static std::vector<int> affinity_cores() {
    std::vector<int> out;
    cpu_set_t set;
    CPU_ZERO(&set);
    if (sched_getaffinity(0, sizeof(set), &set) == 0)
        for (int c = 0; c < CPU_SETSIZE; ++c)
            if (CPU_ISSET(c, &set)) out.push_back(c);
    return out;
}

// ─── Measurement drivers ─────────────────────────────────────────────────────

// One cell: one placement per POOL ARENA, returning the distribution of
// per-placement medians. Placement i is arena i at that cell's i-th drawn
// offset — so the N placements walk N distinct physical frames (the axis
// intra-CCX RTT varies on) at N random within-frame offsets (the axis cross-CCX
// RTT varies on), and every cell walks the SAME N frames.
//
// Baseline cells pass a == b == the core with PROTO_BASELINE and run solo; the
// orchestrator rule then excludes just that one core.
//
// The orchestrator is pinned once for the whole cell — it does not move between
// placements.
static std::vector<double> measure_cell(ArenaPool& pool, uint64_t seed,
                                        int a, int b, int protocol, const Timing& t,
                                        double ns_per_cycle, bool verbose,
                                        const std::vector<int>& isolated,
                                        const std::vector<int>& fallback) {
    int orch = orchestrator_for(isolated, fallback, a, b);
    if (orch < 0)
        die("no free core for the orchestrator outside {%d,%d} — the machine "
            "needs at least one core outside every measured pair", a, b);
    pin_and_assert(orch, "orchestrator");

    const size_t n = pool.arenas.size();
    const std::vector<uint64_t> offsets = gen_offsets(cell_seed(seed, protocol, a, b), n);

    std::vector<double> meds;
    meds.reserve(n);
    for (size_t i = 0; i < n; ++i)
        meds.push_back(measure_placement(pool.arenas[i], offsets[i], a, b, protocol,
                                         t, ns_per_cycle, verbose));
    return meds;
}

// ─── Environment header (stderr in capture modes, stdout in text modes) ──────
struct Env {
    std::string isolated_str;
    std::string nohz;
    std::string graphical;
    bool constant_tsc = false;
    bool nonstop_tsc = false;
    double ns_per_cycle = 0;
};

static Env read_env() {
    Env e;
    e.isolated_str = read_first_line("/sys/devices/system/cpu/isolated");
    e.nohz         = read_first_line("/sys/devices/system/cpu/nohz_full");
    e.graphical    = run_cmd("systemctl is-active graphical.target 2>/dev/null");
    e.constant_tsc = cpuinfo_has_flag("constant_tsc");
    e.nonstop_tsc  = cpuinfo_has_flag("nonstop_tsc");
    e.ns_per_cycle = calibrate_ns_per_cycle();
    return e;
}

static void print_env(const Env& e, const ArenaPool& pool) {
    info("==== demo 10 — core-to-core ping-pong ====\n");
    info("isolated cores : %s   nohz_full: %s\n",
         e.isolated_str.empty() ? "(none)" : e.isolated_str.c_str(),
         e.nohz.empty() ? "(none)" : e.nohz.c_str());
    info("graphical.target: %s\n", e.graphical.c_str());
    info("TSC->ns factor : %.6f ns/cycle  (~%.3f GHz invariant TSC)\n",
         e.ns_per_cycle, e.ns_per_cycle > 0 ? 1.0 / e.ns_per_cycle : 0.0);
    info("invariant TSC  : constant_tsc=%s nonstop_tsc=%s%s\n",
         e.constant_tsc ? "yes" : "NO", e.nonstop_tsc ? "yes" : "NO",
         (e.constant_tsc && e.nonstop_tsc) ? "" : "  <-- WARNING: ns portability depends on this");
    // Every arena address is printed, not just a count: the single-frame
    // sampling bug was diagnosed by noticing that one arena address served the
    // whole matrix, and these lines are what let a future reader check that the
    // pool really is a pool. They land in the capture log.
    const size_t n = pool.arenas.size();
    info("arena pool     : %zu x %.0f MiB independent private mappings, held live "
         "simultaneously\n"
         "                 (distinct physical frames by construction) — "
         "%d/%zu THP-backed\n",
         n, ARENA_SIZE / 1048576.0, pool.hugepage_obtained, n);
    for (size_t i = 0; i < n; ++i)
        info("  arena %2zu     : %p  %s (AnonHugePages=%ld kB)\n",
             i, (void*)pool.arenas[i].base,
             pool.arenas[i].hugepage ? "THP" : "no THP", pool.arenas[i].anonhuge_kb);
    if (pool.hugepage_obtained < (int)n)
        info("  NOTE: %zu of %zu arenas are on 4 KiB pages. That is TOLERATED for the\n"
             "  matrix — a random offset in a small-page arena still lands on a physical\n"
             "  page whose address feeds the L3 slice hash, so it is still a valid frame\n"
             "  sample. Only the slice-sweep exhibit needs a huge page, and it is clamped\n"
             "  to one 4 KiB page without one.\n",
             n - (size_t)pool.hugepage_obtained, n);
}

// ─── Capture: the production path ────────────────────────────────────────────

struct PairResult {
    int a, b;
    bool same;
    HouseStats stats;
};

// §Open item 5 — a per-core baseline X above that core's own intra-CCX RTT means
// the baseline loop is broken (X should be ~0.6 ns against ~72 ns). On the rig
// that is a hard stop. Off-rig (no isolated set) the numbers are meaningless by
// construction, so it degrades to a loud warning rather than failing the
// structural sanity build the acceptance criteria call for.
static void check_baselines(const std::vector<CoreInfo>& cores,
                            const std::vector<HouseStats>& baselines,
                            const std::vector<PairResult>& pairs,
                            bool on_rig) {
    for (size_t i = 0; i < cores.size(); ++i) {
        const int cpu = cores[i].cpu;
        double best_intra = -1.0;
        for (const auto& p : pairs) {
            if (!p.same) continue;
            if (p.a != cpu && p.b != cpu) continue;
            if (best_intra < 0 || p.stats.median < best_intra) best_intra = p.stats.median;
        }
        if (best_intra < 0) continue;  // no same-CCX partner measured
        if (baselines[i].median < best_intra) continue;

        std::fprintf(stderr,
            "FATAL: baseline X for core %d is %.3f ns, which is NOT below its "
            "fastest intra-CCX RTT (%.3f ns). X is a fixed cost with the line in "
            "L1 and must be orders below any transfer — this indicates a broken "
            "baseline loop. Reported, not published.\n",
            cpu, baselines[i].median, best_intra);
        if (on_rig) std::exit(3);
        std::fprintf(stderr,
            "  (off-rig: continuing so the structural sanity build still emits "
            "JSON; the numbers are meaningless without core isolation.)\n");
        return;
    }
}

static void emit_machine_and_header(const std::string& machine_json,
                                    const std::string& captured_at,
                                    const char* demo, const char* title) {
    std::printf("{\n");
    std::printf("  \"demo\": \"%s\",\n", demo);
    std::printf("  \"title\": \"%s\",\n", title);
    // machine_info_json() returns the object BODY without braces (demo 4's
    // --machine-info wraps it the same way). Emitted verbatim: never
    // reconstructed, never hand-edited, no machine-level compiler_flags.
    std::printf("  \"machine\": {%s},\n", machine_json.c_str());
    std::printf("  \"captured_at\": \"%s\",\n", captured_at.c_str());
}

static void emit_cores_block(const std::vector<CoreInfo>& cores) {
    std::printf("    \"cores\": [\n");
    for (size_t i = 0; i < cores.size(); ++i) {
        std::printf("      {\"cpu\": %d, \"ccx\": %d, \"l3_domain\": \"%s\", "
                    "\"housekeeping\": %s}%s\n",
                    cores[i].cpu, cores[i].ccx, cores[i].l3_domain.c_str(),
                    cores[i].housekeeping ? "true" : "false",
                    i + 1 < cores.size() ? "," : "");
    }
    std::printf("    ],\n");
}

// ─── Shared parameter blocks. Each capture mode emits a subset of the same
//     fields, and each block living in ONE function is what keeps the three
//     files' schemas aligned by construction — a rename or reformat cannot
//     reach one emitter and miss another (the demo-9 regression class). ────────
static void emit_timing_params(const Timing& t) {
    std::printf("    \"memory_order\": \"%s\",\n", MEMORY_ORDER_NAME);
    std::printf("    \"k_roundtrips\": %" PRIu64 ",\n", t.k);
    std::printf("    \"windows_per_placement\": %" PRIu64 ",\n", t.windows);
    std::printf("    \"warmup_windows\": %" PRIu64 ",\n", t.warmup);
}

static void emit_pool_params(const ArenaPool& pool, uint64_t placements, uint64_t seed) {
    std::printf("    \"placements_per_cell\": %" PRIu64 ",\n", placements);
    std::printf("    \"placement_arenas\": %zu,\n", pool.arenas.size());
    std::printf("    \"placement_sampling\": \"%s\",\n", PLACEMENT_SAMPLING);
    std::printf("    \"arenas_hugepage_obtained\": %d,\n", pool.hugepage_obtained);
    std::printf("    \"offset_mode\": \"%s\",\n", OFFSET_MODE);
    std::printf("    \"offset_seed\": \"0x%016" PRIx64 "\",\n", seed);
}

static void emit_convention_params(const Env& env, const std::vector<CoreInfo>& cores) {
    std::printf("    \"tsc_ns_per_cycle\": %.6f,\n", env.ns_per_cycle);
    std::printf("    \"rtt_convention\": \"%s\",\n", RTT_CONVENTION);
    std::printf("    \"orchestrator_placement\": \"%s\",\n", ORCHESTRATOR_PLACEMENT);
    emit_cores_block(cores);
}

static void run_capture(ArenaPool& pool, const Env& env,
                        const std::vector<int>& cores_req,
                        const std::vector<int>& isolated,
                        const std::vector<int>& fallback,
                        const Timing& t, uint64_t placements, uint64_t seed,
                        bool verbose) {
    // The pool IS the placement axis, so the two cannot drift apart: one arena
    // per placement is the whole design.
    if (pool.arenas.size() != placements)
        die("internal: arena pool holds %zu arenas but the capture wants "
            "%" PRIu64 " placements per cell", pool.arenas.size(), placements);

    // Machine info FIRST, before any pinning: machine_info_json() reports the
    // process's real cpu_affinity, and the orchestrator pins to a single core
    // for every measured pair. Collected late it would record "5" instead of
    // the machine's true affinity.
    const std::string machine_json = crucible::machine_info_json();
    const std::string captured_at  = utc_now_z();

    const std::vector<CoreInfo> cores = build_cores(cores_req, isolated);

    info("capture: %zu cores, %zu unordered pairs, %" PRIu64 " placements/cell "
         "(one per pool arena), K=%" PRIu64 ", windows=%" PRIu64 ", "
         "warmup=%" PRIu64 "\n",
         cores.size(), cores.size() * (cores.size() - 1) / 2,
         placements, t.k, t.windows, t.warmup);

    // ── Per-core baseline X (§Task 4). ──
    std::vector<HouseStats> baselines;
    baselines.reserve(cores.size());
    for (const auto& ci : cores) {
        info("  baseline core %d...\n", ci.cpu);
        baselines.push_back(house_stats(measure_cell(
            pool, seed, ci.cpu, ci.cpu, PROTO_BASELINE, t, env.ns_per_cycle,
            verbose, isolated, fallback)));
    }

    // ── The 28 unordered pairs, ascending (a,b). Diagonal not measured. ──
    std::vector<PairResult> pairs;
    for (size_t i = 0; i < cores.size(); ++i) {
        for (size_t j = i + 1; j < cores.size(); ++j) {
            const int a = cores[i].cpu, b = cores[j].cpu;
            info("  pair (%d,%d)...\n", a, b);
            PairResult pr;
            pr.a = a;
            pr.b = b;
            pr.same = same_ccx(cores, a, b);
            pr.stats = house_stats(measure_cell(pool, seed, a, b, PROTO_EXCHANGE,
                                                t, env.ns_per_cycle, verbose,
                                                isolated, fallback));
            pairs.push_back(pr);
        }
    }

    check_baselines(cores, baselines, pairs, !isolated.empty());

    // ── Emit. ──
    emit_machine_and_header(machine_json, captured_at, DEMO_SLUG, DEMO_TITLE);
    std::printf("  \"latency_matrix\": {\n");
    std::printf("    \"protocol\": \"%s\",\n", PROTOCOL_EXCHANGE_NAME);
    emit_timing_params(t);
    emit_pool_params(pool, placements, seed);
    emit_convention_params(env, cores);

    std::printf("    \"baseline_ns\": [\n");
    for (size_t i = 0; i < cores.size(); ++i) {
        std::printf("      {\"cpu\": %d, ", cores[i].cpu);
        emit_house_stats(baselines[i], "");
        std::printf("}%s\n", i + 1 < cores.size() ? "," : "");
    }
    std::printf("    ],\n");

    std::printf("    \"pairs\": [\n");
    for (size_t i = 0; i < pairs.size(); ++i) {
        std::printf("      {\"a\": %d, \"b\": %d, \"same_ccx\": %s,\n",
                    pairs[i].a, pairs[i].b, pairs[i].same ? "true" : "false");
        std::printf("       \"rtt_ns\": {");
        emit_house_stats(pairs[i].stats, "");
        std::printf("}}%s\n", i + 1 < pairs.size() ? "," : "");
    }
    std::printf("    ]\n");
    std::printf("  },\n");
    std::printf("  \"notes\": \"%s\"\n", CAPTURE_NOTES);
    std::printf("}\n");
}

// ─── Exhibit pair selection (§Task 6) ────────────────────────────────────────
// Intra: the two lowest isolated cores that share a CCX. Cross: the lowest
// isolated core of each of the first two CCXs. On the reference rig this
// reproduces the pilot's A6 choice — (1,2) intra and (1,4) cross.
struct ExhibitPairs {
    int intra_a = -1, intra_b = -1;
    int cross_a = -1, cross_b = -1;
};

static ExhibitPairs pick_exhibit_pairs(const std::vector<CoreInfo>& cores,
                                       const std::vector<int>& isolated) {
    ExhibitPairs ep;
    auto usable = [&](const CoreInfo& c) {
        // Prefer isolated cores; off-rig (empty isolated set) take anything.
        return isolated.empty()
            || std::find(isolated.begin(), isolated.end(), c.cpu) != isolated.end();
    };

    for (size_t i = 0; i < cores.size() && ep.intra_a < 0; ++i) {
        if (!usable(cores[i])) continue;
        for (size_t j = i + 1; j < cores.size(); ++j) {
            if (!usable(cores[j])) continue;
            if (cores[i].ccx == cores[j].ccx) {
                ep.intra_a = cores[i].cpu;
                ep.intra_b = cores[j].cpu;
                break;
            }
        }
    }
    for (size_t i = 0; i < cores.size() && ep.cross_a < 0; ++i) {
        if (!usable(cores[i])) continue;
        for (size_t j = i + 1; j < cores.size(); ++j) {
            if (!usable(cores[j])) continue;
            if (cores[i].ccx != cores[j].ccx) {
                ep.cross_a = cores[i].cpu;
                ep.cross_b = cores[j].cpu;
                break;
            }
        }
    }
    return ep;
}

// Clamp a requested sweep span to what is physically meaningful. Past a page
// boundary virtual offsets only track physical offsets inside one huge page, so
// without THP the whole swept footprint has to stay in one 4 KiB page.
static size_t clamp_sweep_range(const Arena& arena, size_t requested, int protocol) {
    const size_t footprint = (protocol == PROTO_TWOFLAG) ? sizeof(PingPongLines) : CACHELINE;
    size_t range = requested;
    if (!arena.hugepage) {
        const size_t page_safe = PAGE_SIZE - footprint + CACHELINE;
        if (range > page_safe) {
            std::fprintf(stderr,
                "NOTE: THP not obtained; clamping sweep to %zu B so the swept "
                "footprint stays within one 4 KiB page.\n", page_safe);
            range = page_safe;
        }
    }
    const size_t cap = ARENA_MAX_OFFSET + CACHELINE;  // one past the last legal start
    if (range > cap) range = cap;
    return range;
}

// The slice sweep is the ONE capture that stays single-arena, and deliberately:
// it exists to show RTT varying with offset WITHIN one physical frame, which
// requires one contiguous THP-backed frame and nothing else. Applying the
// matrix's pool sampling here would average away the very effect it exhibits.
static void run_capture_slice_sweep(Arena& arena, const Env& env,
                                    const std::vector<int>& cores_req,
                                    const std::vector<int>& isolated,
                                    const std::vector<int>& fallback,
                                    const Timing& t, size_t sweep_range,
                                    size_t sweep_step, bool verbose) {
    const std::string machine_json = crucible::machine_info_json();
    const std::string captured_at  = utc_now_z();

    const std::vector<CoreInfo> cores = build_cores(cores_req, isolated);
    const ExhibitPairs ep = pick_exhibit_pairs(cores, isolated);
    if (ep.intra_a < 0 || ep.cross_a < 0)
        die("slice-sweep exhibit needs one intra-CCX and one cross-CCX pair; the "
            "measured core set has only %s. Check --cores / the isolated set.",
            ep.intra_a < 0 ? "cross-CCX pairs" : "intra-CCX pairs");

    const size_t range = clamp_sweep_range(arena, sweep_range, PROTO_EXCHANGE);
    info("slice sweep: intra (%d,%d), cross (%d,%d), range=%zu B, step=%zu\n",
         ep.intra_a, ep.intra_b, ep.cross_a, ep.cross_b, range, sweep_step);

    // same_ccx is derived from the topology, never asserted: pick_exhibit_pairs
    // is supposed to hand back one of each, and emitting the computed value is
    // what would catch it if that ever stopped being true.
    struct Series { int a, b; bool same; std::vector<double> med; };
    Series series[2] = {
        {ep.intra_a, ep.intra_b, same_ccx(cores, ep.intra_a, ep.intra_b), {}},
        {ep.cross_a, ep.cross_b, same_ccx(cores, ep.cross_a, ep.cross_b), {}},
    };

    for (auto& s : series) {
        int orch = orchestrator_for(isolated, fallback, s.a, s.b);
        if (orch < 0) die("no free core for the orchestrator with pair (%d,%d)", s.a, s.b);
        pin_and_assert(orch, "orchestrator");
        info("  sweeping pair (%d,%d)...\n", s.a, s.b);
        for (size_t off = 0; off < range; off += sweep_step)
            s.med.push_back(measure_placement(arena, off, s.a, s.b, PROTO_EXCHANGE,
                                              t, env.ns_per_cycle, verbose));
    }

    emit_machine_and_header(machine_json, captured_at,
                            "10-core-to-core.slice-sweep",
                            "Cache-line placement sweep: L3 slice modulation of core-to-core RTT");
    std::printf("  \"slice_sweep\": {\n");
    std::printf("    \"protocol\": \"%s\",\n", PROTOCOL_EXCHANGE_NAME);
    emit_timing_params(t);
    std::printf("    \"sweep_range_bytes\": %zu,\n", range);
    std::printf("    \"sweep_step_bytes\": %zu,\n", sweep_step);
    std::printf("    \"arena_hugepage\": %s,\n", arena.hugepage ? "true" : "false");
    emit_convention_params(env, cores);
    std::printf("    \"series\": [\n");
    for (int si = 0; si < 2; ++si) {
        const Series& s = series[si];
        std::printf("      {\"a\": %d, \"b\": %d, \"same_ccx\": %s, \"points\": [\n",
                    s.a, s.b, s.same ? "true" : "false");
        for (size_t i = 0; i < s.med.size(); ++i)
            std::printf("        {\"offset_bytes\": %zu, \"median_ns\": %s}%s\n",
                        i * sweep_step, jnum(s.med[i]).c_str(),
                        i + 1 < s.med.size() ? "," : "");
        std::printf("      ]}%s\n", si == 0 ? "," : "");
    }
    std::printf("    ]\n");
    std::printf("  },\n");
    std::printf("  \"notes\": \"%s\"\n", SLICE_SWEEP_NOTES);
    std::printf("}\n");
}

static void run_capture_protocol(ArenaPool& pool, const Env& env,
                                 const std::vector<int>& cores_req,
                                 const std::vector<int>& isolated,
                                 const std::vector<int>& fallback,
                                 const Timing& t, uint64_t placements, uint64_t seed,
                                 bool verbose) {
    // Same invariant as the matrix: the pool size is the placement count. The
    // exhibit samples frames the same WAY as the matrix but from its OWN pool
    // (own process, own frames, possibly slice-correlated — see the header
    // comment); run_one.sh cross-checks its exchange cells against the matrix,
    // which is what comparability rests on. See PROTOCOL_NOTES.
    if (pool.arenas.size() != placements)
        die("internal: arena pool holds %zu arenas but the protocol exhibit wants "
            "%" PRIu64 " placements per cell", pool.arenas.size(), placements);

    const std::string machine_json = crucible::machine_info_json();
    const std::string captured_at  = utc_now_z();

    const std::vector<CoreInfo> cores = build_cores(cores_req, isolated);
    const ExhibitPairs ep = pick_exhibit_pairs(cores, isolated);
    if (ep.intra_a < 0 || ep.cross_a < 0)
        die("protocol exhibit needs one intra-CCX and one cross-CCX pair; the "
            "measured core set has only %s. Check --cores / the isolated set.",
            ep.intra_a < 0 ? "cross-CCX pairs" : "intra-CCX pairs");

    const bool intra_same = same_ccx(cores, ep.intra_a, ep.intra_b);  // derived, not asserted
    const bool cross_same = same_ccx(cores, ep.cross_a, ep.cross_b);
    struct Cell { const char* proto_name; int proto; int a, b; bool same; HouseStats st; };
    Cell cells[4] = {
        {PROTOCOL_EXCHANGE_NAME, PROTO_EXCHANGE, ep.intra_a, ep.intra_b, intra_same, {}},
        {PROTOCOL_EXCHANGE_NAME, PROTO_EXCHANGE, ep.cross_a, ep.cross_b, cross_same, {}},
        {PROTOCOL_TWOFLAG_NAME,  PROTO_TWOFLAG,  ep.intra_a, ep.intra_b, intra_same, {}},
        {PROTOCOL_TWOFLAG_NAME,  PROTO_TWOFLAG,  ep.cross_a, ep.cross_b, cross_same, {}},
    };

    for (auto& c : cells) {
        info("  %s pair (%d,%d)...\n", c.proto_name, c.a, c.b);
        c.st = house_stats(measure_cell(pool, seed, c.a, c.b, c.proto, t,
                                        env.ns_per_cycle, verbose, isolated, fallback));
    }

    emit_machine_and_header(machine_json, captured_at,
                            "10-core-to-core.protocol",
                            "Protocol comparison: single-line exchange vs two-line flag handshake");
    std::printf("  \"protocol_comparison\": {\n");
    emit_timing_params(t);
    emit_pool_params(pool, placements, seed);
    emit_convention_params(env, cores);
    std::printf("    \"cells\": [\n");
    for (int i = 0; i < 4; ++i) {
        std::printf("      {\"protocol\": \"%s\", \"a\": %d, \"b\": %d, \"same_ccx\": %s,\n",
                    cells[i].proto_name, cells[i].a, cells[i].b,
                    cells[i].same ? "true" : "false");
        std::printf("       \"rtt_ns\": {");
        emit_house_stats(cells[i].st, "");
        std::printf("}}%s\n", i < 3 ? "," : "");
    }
    std::printf("    ]\n");
    std::printf("  },\n");
    std::printf("  \"notes\": \"%s\"\n", PROTOCOL_NOTES);
    std::printf("}\n");
}

// ─── CLI ─────────────────────────────────────────────────────────────────────
static void usage(const char* prog) {
    std::printf(
        "Usage: %s [options]\n"
        "  Core-to-core cache-line ping-pong RTT (demo 10; Machine 1 / Zen 2).\n\n"
        "Capture modes (production; the whole demo JSON goes to stdout):\n"
        "  --capture                 full matrix + per-core baseline -> demo JSON\n"
        "  --capture-slice-sweep     supporting exhibit: RTT vs cache-line placement\n"
        "  --capture-protocol        supporting exhibit: exchange vs twoflag\n"
        "  --machine-info            machine block only (same shape as demo 4)\n\n"
        "Diagnostic modes (text; retained from the pilot for re-verification):\n"
        "  --pair a,b                measure one core pair\n"
        "  --full-matrix             text RTT matrix over the measured set\n"
        "  --baseline                with --pair a,b: fixed cost X on each of a and b\n"
        "  --offset-sweep            with --pair a,b: median RTT vs arena offset\n\n"
        "Protocol / timing (defaults are the locked capture parameters; ALL THREE\n"
        "capture modes reject these and --repeat outright, so a stray flag cannot\n"
        "produce a self-consistent but non-comparable file, nor be silently ignored\n"
        "by a mode that hardcodes it — tune in a diagnostic mode instead. The same\n"
        "rule covers every flag a given mode would ignore: --offset in any capture,\n"
        "--seed in the slice sweep, the sweep span outside it, and the equivalent\n"
        "diagnostic-mode combinations):\n"
        "  --protocol exchange|twoflag   handshake protocol (default: exchange)\n"
        "  --k K                     round trips per timed window (default: %" PRIu64 ")\n"
        "  --windows W               timed windows kept (default: %" PRIu64 ")\n"
        "  --warmup N                warmup windows discarded (default: %" PRIu64 ")\n\n"
        "Arena / slice control:\n"
        "  --repeat N                placements per cell (locked in --capture: %" PRIu64 ")\n"
        "  --seed N                  PRNG seed for placement offsets (default fixed;\n"
        "                            pooled modes only — --repeat N>1 or the\n"
        "                            matrix/protocol captures)\n"
        "  --offset BYTES            single-placement offset, 64 B-aligned (default 0;\n"
        "                            --repeat 1 diagnostics only)\n"
        "  --offset-sweep-range B    sweep span (default 4096; >4096 needs a huge page)\n"
        "  --offset-sweep-step B     sweep step, 64 B-aligned (default 64 = every line;\n"
        "                            coarsen to shrink a full-2 MiB exhibit)\n\n"
        "Core set:\n"
        "  --cores LIST              measured cores as a cpulist, e.g. 0-7 (default:\n"
        "                            the isolated set plus core 0)\n"
        "  --orchestrator-core C     diagnostic modes only: pin the orchestrator to C.\n"
        "                            Capture modes always use the '%s' rule.\n\n"
        "Misc:\n"
        "  --verbose                 per-window samples / per-cell progress\n"
        "  --help                    this help\n",
        prog, LOCKED_K, LOCKED_WINDOWS, LOCKED_WARMUP, LOCKED_PLACEMENTS,
        ORCHESTRATOR_PLACEMENT);
}

// Strict non-negative-integer parse. std::strtoull silently negates a leading
// '-' into a near-2^64 value, which would sail past the ==0 guards and either
// hang the harness (--k) or emit empty stats (--windows) — so reject anything
// that is not all digits, and catch overflow. Fail loudly.
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
    Timing timing;                       // defaults are the locked K/windows/warmup
    uint64_t repeat = 1, seed = DEFAULT_SEED, offset = 0, sweep_range = PAGE_SIZE;
    uint64_t sweep_step = CACHELINE;
    // Which flags the caller named explicitly. Needed because the capture modes
    // REJECT the locked parameters (see the lock below) and every mode rejects
    // flags it would otherwise silently ignore — the values themselves are
    // indistinguishable from the defaults, only the fact of passing them is.
    bool protocol_set = false, k_set = false, windows_set = false, warmup_set = false;
    bool repeat_set = false, seed_set = false, offset_set = false;
    bool sweep_range_set = false, sweep_step_set = false;
    bool full_matrix = false, verbose = false;
    bool have_pair = false, baseline = false, offset_sweep = false;
    bool capture = false, capture_slice = false, capture_proto = false;
    bool machine_info_only = false;
    int pa = -1, pb = -1;
    int orchestrator_core = -1;
    std::string cores_arg;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        auto next = [&](const char* name) -> std::string {
            if (i + 1 >= argc) die("%s requires an argument", name);
            return argv[++i];
        };
        if (arg == "--help" || arg == "-h") { usage(argv[0]); return 0; }
        else if (arg == "--capture")              capture = true;
        else if (arg == "--capture-slice-sweep")  capture_slice = true;
        else if (arg == "--capture-protocol")     capture_proto = true;
        else if (arg == "--machine-info")         machine_info_only = true;
        else if (arg == "--full-matrix")  full_matrix = true;
        else if (arg == "--verbose")      verbose = true;
        else if (arg == "--baseline")     baseline = true;
        else if (arg == "--offset-sweep") offset_sweep = true;
        else if (arg == "--protocol") {
            std::string p = next("--protocol");
            if (p == "exchange") protocol = PROTO_EXCHANGE;
            else if (p == "twoflag") protocol = PROTO_TWOFLAG;
            else die("unknown protocol '%s' (want exchange|twoflag)", p.c_str());
            protocol_set = true;
        }
        else if (arg == "--k")       { timing.k = parse_count(next("--k"), "--k", false); k_set = true; }
        else if (arg == "--windows") { timing.windows = parse_count(next("--windows"), "--windows", false); windows_set = true; }
        else if (arg == "--warmup")  { timing.warmup = parse_count(next("--warmup"), "--warmup", true); warmup_set = true; }
        else if (arg == "--repeat") { repeat = parse_count(next("--repeat"), "--repeat", false); repeat_set = true; }
        else if (arg == "--seed")    { seed = parse_count(next("--seed"), "--seed", true); seed_set = true; }
        else if (arg == "--offset")  { offset = parse_count(next("--offset"), "--offset", true); offset_set = true; }
        else if (arg == "--offset-sweep-range") {
            sweep_range = parse_count(next("--offset-sweep-range"), "--offset-sweep-range", false);
            sweep_range_set = true;
        }
        else if (arg == "--offset-sweep-step") {
            sweep_step = parse_count(next("--offset-sweep-step"), "--offset-sweep-step", false);
            sweep_step_set = true;
        }
        else if (arg == "--orchestrator-core")
            orchestrator_core = parse_core(next("--orchestrator-core"), "--orchestrator-core");
        else if (arg == "--cores") cores_arg = next("--cores");
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

    const int n_capture_modes = (int)capture + (int)capture_slice + (int)capture_proto;
    if (n_capture_modes > 1)
        die("pick one capture mode: --capture, --capture-slice-sweep, or --capture-protocol");
    const bool any_capture = n_capture_modes == 1;

    if (any_capture && orchestrator_core >= 0)
        die("--orchestrator-core cannot be combined with a capture mode: the "
            "capture pins the orchestrator per pair by the '%s' rule and records "
            "that rule in the JSON. Use it with the diagnostic modes instead.",
            ORCHESTRATOR_PLACEMENT);

    // ── The capture parameters are LOCKED, in EVERY capture mode. ──
    // `--capture --k 7` used to emit `k_roundtrips: 7`: self-consistent, so it
    // passes every schema check in run_one.sh, and silently not comparable with
    // any other capture. This demo has already produced one plausible-but-wrong
    // headline from a stray parameter (a governor default, a phantom 1.40x that
    // validated cleanly); a second such path does not stay open.
    //
    // The two exhibit modes ship files too, and they fail in BOTH directions:
    //   * --k/--windows/--warmup land in their JSON verbatim, exactly as in
    //     --capture, so the exhibit stops being comparable with the matrix it is
    //     supposed to explain;
    //   * --protocol is a silent no-op in both (the slice sweep hardcodes
    //     exchange, the protocol exhibit measures both by construction), and so
    //     is --repeat in the slice sweep, which sweeps every line instead. A flag
    //     that appears to be honoured and does nothing is worse than one that is
    //     honoured wrongly, because nothing in the output contradicts it.
    // So the lock covers all three capture modes. Tuning belongs in the
    // diagnostic modes, which honour all five flags exactly as before.
    if (any_capture) {
        const char* mode = capture       ? "--capture"
                         : capture_slice ? "--capture-slice-sweep"
                                         : "--capture-protocol";
        const char* offender = nullptr;
        if      (protocol_set) offender = "--protocol";
        else if (k_set)        offender = "--k";
        else if (windows_set)  offender = "--windows";
        else if (warmup_set)   offender = "--warmup";
        else if (repeat_set)   offender = "--repeat";
        if (offender)
            die("%s cannot be combined with %s: the capture modes run at locked "
                "parameters (protocol=%s, k=%" PRIu64 ", windows=%" PRIu64 ", "
                "warmup=%" PRIu64 ", placements=%" PRIu64 ") so that every file "
                "they emit is comparable with every other one. Some modes ignore "
                "some of these outright, which is worse rather than better: the "
                "flag would silently do nothing. To tune them, use a diagnostic "
                "mode instead (--pair, --full-matrix, --baseline, --offset-sweep).",
                offender, mode, PROTOCOL_EXCHANGE_NAME, LOCKED_K, LOCKED_WINDOWS,
                LOCKED_WARMUP, LOCKED_PLACEMENTS);

        // The remaining flags are not locked, but SOME capture modes would
        // silently ignore them — the exact failure the lock exists to close, so
        // those combinations are rejected too, per mode.
        const char* ignored = nullptr;
        if      (offset_set)                        ignored = "--offset";
        else if (capture_slice && seed_set)         ignored = "--seed";
        else if (!capture_slice && sweep_range_set) ignored = "--offset-sweep-range";
        else if (!capture_slice && sweep_step_set)  ignored = "--offset-sweep-step";
        if (ignored)
            die("%s would be silently ignored by %s — a flag that looks honoured "
                "and does nothing is the failure mode the capture lock exists to "
                "close. --offset is a diagnostic-mode control; --seed only "
                "affects pooled placements (the sweep is systematic); the sweep "
                "span shapes only --capture-slice-sweep.", ignored, mode);
    }

    // ── Machine info only: byte-identical to demo 4's --machine-info. ──
    if (machine_info_only) {
        double ns_per_cycle = calibrate_ns_per_cycle();
        std::printf("{%s,\"tsc_ns_per_cycle\":%.6f}\n",
                    crucible::machine_info_json().c_str(), ns_per_cycle);
        return 0;
    }

    // ── The same discipline for the diagnostic modes: a flag (or mode) that
    //    would be silently ignored by the combination given is rejected, not
    //    tolerated. The capture lock's rationale applies everywhere; only the
    //    set of meaningful flags differs per mode. ──
    if (!any_capture) {
        if (baseline && offset_sweep)
            die("pick one diagnostic: --baseline or --offset-sweep");
        if (full_matrix && (have_pair || baseline || offset_sweep))
            die("--full-matrix measures every pair; it cannot be combined with "
                "--pair/--baseline/--offset-sweep");
        if (offset_set && repeat > 1)
            die("--offset picks THE single placement of --repeat 1; with "
                "--repeat %" PRIu64 " the placements are drawn from --seed and "
                "--offset would be silently unused", repeat);
        if (offset_set && offset_sweep)
            die("--offset-sweep walks the range from offset 0 — --offset would "
                "be silently unused");
        if (seed_set && repeat <= 1)
            die("--seed drives the pooled placements of --repeat N>1; with a "
                "single placement it would be silently unused (pick the "
                "placement with --offset instead)");
        if ((sweep_range_set || sweep_step_set) && !offset_sweep)
            die("--offset-sweep-range/--offset-sweep-step need --offset-sweep");
        if (repeat_set && offset_sweep)
            die("--repeat has no effect on --offset-sweep: a sweep is a "
                "WITHIN-frame measurement and stays on one arena by design");
        if (protocol_set && baseline)
            die("--baseline measures the fixed cost X with its own single-thread "
                "loop; --protocol would be silently ignored");
    }

    // ── Argument validation. ──
    // ARENA_MAX_OFFSET is the largest 64 B-aligned offset that still leaves room
    // for a full PingPongLines, and it is a COMPILE-TIME constant, so the bounds
    // test is `offset > ARENA_MAX_OFFSET` — never `offset + sizeof(...)`, which
    // would wrap in uint64 and let a near-2^64 offset sail past the guard into an
    // out-of-bounds placement-new.
    constexpr uint64_t OFFSET_MAX = (uint64_t)ARENA_MAX_OFFSET;
    if (offset % CACHELINE != 0)
        die("--offset must be a multiple of 64 (got %" PRIu64 ")", offset);
    if (offset > OFFSET_MAX)
        die("--offset %" PRIu64 " too large for the %zu-byte arena (max %" PRIu64 ")",
            offset, ARENA_SIZE, OFFSET_MAX);
    if (sweep_range % CACHELINE != 0)
        die("--offset-sweep-range must be a multiple of 64 (got %" PRIu64 ")", sweep_range);
    if (sweep_step % CACHELINE != 0)
        die("--offset-sweep-step must be a multiple of 64 (got %" PRIu64 ")", sweep_step);
    long ncpu = sysconf(_SC_NPROCESSORS_ONLN);
    if (ncpu < 1) ncpu = 1;
    if (orchestrator_core >= ncpu)
        die("--orchestrator-core %d out of range [0,%ld) — no such online core",
            orchestrator_core, ncpu);

    // Capture modes own stdout for the JSON; everything human goes to stderr.
    if (any_capture) g_info = stderr;

    // ── Core sets. ──
    // isolated: the kernel's view, which is also the orchestrator's pool.
    // fallback: every core this process may run on — used only off-rig.
    const std::vector<int> isolated = parse_cpulist(
        read_first_line("/sys/devices/system/cpu/isolated"),
        "/sys/devices/system/cpu/isolated");
    const std::vector<int> fallback = affinity_cores();

    std::vector<int> measured;
    if (!cores_arg.empty()) {
        measured = parse_cpulist(cores_arg, "--cores");
        if (measured.empty()) die("--cores '%s' parsed to an empty set", cores_arg.c_str());
    } else if (!isolated.empty()) {
        // §1/A4: core 0 is a measured worker, so the set is the isolated cores
        // plus the housekeeping core — 8 cores, 28 unordered pairs on this rig.
        measured = isolated;
        if (std::find(measured.begin(), measured.end(), 0) == measured.end())
            measured.insert(measured.begin(), 0);
    } else {
        measured = fallback;
        std::fprintf(stderr,
            "WARNING: /sys/devices/system/cpu/isolated is empty — measuring the "
            "%zu affinity-allowed cores instead. OFF-RIG: the structure is valid, "
            "the numbers are meaningless. Use --cores to fix the set.\n",
            measured.size());
    }
    for (int c : measured)
        if (c < 0 || c >= ncpu)
            die("measured core %d is out of range [0,%ld) — no such online core", c, ncpu);
    if (measured.size() < 2)
        die("need at least 2 measured cores, got %zu", measured.size());

    Env env = read_env();

    // ── The arena pool. One arena per placement, so the pool size is the
    //    placement count of whatever mode is about to run:
    //      --capture / --capture-protocol : the locked 20 placements
    //      --capture-slice-sweep          : ONE arena, by design — the sweep
    //                                       exhibits within-frame offset
    //                                       dependence and needs one frame
    //      diagnostics                    : --repeat, so `--pair a,b --repeat 20`
    //                                       reproduces what a capture cell does
    //                                       rather than the single-frame answer
    //                                       the old code gave
    //    All of them are allocated here, once, and held live until exit. ──
    const uint64_t pool_size = (capture || capture_proto) ? LOCKED_PLACEMENTS
                             : capture_slice              ? 1
                             : (repeat > 1 ? repeat : 1);
    ArenaPool pool = pool_create(pool_size);
    print_env(env, pool);

    // ── Capture modes. ──
    // All three pass the locked values explicitly rather than inheriting
    // `timing`/`repeat`. The guard above already rejects every override, so the
    // two are equal here — this makes the emitted parameters come from the source
    // constants by construction rather than by the guard having done its job.
    // The sweep span (--offset-sweep-range/-step) is NOT a locked parameter: it
    // shapes how much of the arena the exhibit covers, not the measurement, and
    // run_one.sh sets it deliberately to get the full 2 MiB huge page.
    constexpr Timing LOCKED_TIMING{LOCKED_K, LOCKED_WINDOWS, LOCKED_WARMUP};
    if (capture) {
        run_capture(pool, env, measured, isolated, fallback, LOCKED_TIMING,
                    LOCKED_PLACEMENTS, seed, verbose);
        pool_destroy(pool);
        return 0;
    }
    if (capture_slice) {
        run_capture_slice_sweep(pool.arenas[0], env, measured, isolated, fallback,
                                LOCKED_TIMING, sweep_range, sweep_step, verbose);
        pool_destroy(pool);
        return 0;
    }
    if (capture_proto) {
        run_capture_protocol(pool, env, measured, isolated, fallback,
                             LOCKED_TIMING, LOCKED_PLACEMENTS, seed, verbose);
        pool_destroy(pool);
        return 0;
    }

    // ── Diagnostic (text) modes. The orchestrator rule still applies unless the
    //    caller pins it explicitly with --orchestrator-core (that override is
    //    what reproduces the pilot's A8 placement check). ──
    const std::vector<CoreInfo> cores = build_cores(measured, isolated);

    auto pin_orchestrator = [&](int a, int b) {
        if (orchestrator_core >= 0) { pin_and_assert(orchestrator_core, "orchestrator"); return; }
        int orch = orchestrator_for(isolated, fallback, a, b);
        if (orch < 0) die("no free core for the orchestrator with pair (%d,%d)", a, b);
        pin_and_assert(orch, "orchestrator");
    };
    // What the diagnostics summarise depends on --repeat, and the two are not
    // the same distribution: at --repeat N>1 it is the N across-placement
    // medians (what a capture cell reports, sampled over the same N-arena pool);
    // at --repeat 1 there is only one placement in one arena, so it is that
    // placement's timed windows — which is exactly what the §1 pilot printed,
    // and what §4 re-verifies against.
    const char* sample_unit = repeat > 1 ? "placements" : "timed windows";

    // Per-placement medians under --verbose: when a cell's spread is the
    // question — is intra really flat across frames, or did the pool collapse to
    // one value? — the summary bracket is not enough to answer it, and this is
    // the distribution the answer lives in.
    auto report_placements = [&](const std::vector<double>& meds,
                                 const std::vector<uint64_t>& offs) {
        if (!verbose || meds.size() < 2) return;
        info("    per-placement medians (arena @ offset -> ns):\n");
        for (size_t i = 0; i < meds.size(); ++i)
            info("      [%2zu] %p + %7" PRIu64 " %s -> %8.3f\n",
                 i, (void*)pool.arenas[i].base, offs[i],
                 pool.arenas[i].hugepage ? "THP   " : "no THP", meds[i]);
    };

    // One diagnostic cell, any protocol including PROTO_BASELINE (a == b): the
    // same sampling a capture cell does at --repeat N>1, the single-placement
    // window distribution at --repeat 1.
    auto cell_for = [&](int a, int b, int proto) {
        std::vector<double> samples;
        pin_orchestrator(a, b);
        if (repeat > 1) {
            const std::vector<uint64_t> offs =
                gen_offsets(cell_seed(seed, proto, a, b), pool.arenas.size());
            for (size_t i = 0; i < pool.arenas.size(); ++i)
                samples.push_back(measure_placement(pool.arenas[i], offs[i], a, b,
                                                    proto, timing, env.ns_per_cycle,
                                                    verbose));
            report_placements(samples, offs);
        } else {
            measure_placement(pool.arenas[0], offset, a, b, proto, timing,
                              env.ns_per_cycle, verbose, &samples);
        }
        return samples;
    };

    info("protocol=%s  K=%" PRIu64 "  windows=%" PRIu64 "  warmup=%" PRIu64 "\n",
         protocol_name(protocol), timing.k, timing.windows, timing.warmup);
    if (repeat > 1)
        info("repeat=%" PRIu64 " placements over %zu pool arenas (one each)  "
             "seed=0x%016" PRIx64 "\n\n", repeat, pool.arenas.size(), seed);
    else
        info("repeat=1  single arena  offset=%" PRIu64 "\n\n", offset);

    if (baseline) {
        if (!have_pair)
            die("--baseline needs --pair a,b (it runs the baseline on each of a and b)");
        info("baseline X — single thread, line resident in L1, two atomic stores per\n"
             "round trip, no cross-core transfer, no spin-wait:\n");
        for (int core : {pa, pb}) {
            HouseStats s = house_stats(cell_for(core, core, PROTO_BASELINE));
            info("  core %d: median %.3f ns   [Q1 %.3f, Q3 %.3f, min %.3f, max %.3f, "
                 "n=%d %s]\n",
                 core, s.median, s.iqr_lo, s.iqr_hi, s.min, s.max, s.n_reps, sample_unit);
        }
        pool_destroy(pool);
        return 0;
    }

    if (offset_sweep) {
        if (!have_pair)
            die("--offset-sweep needs --pair a,b (one intra pair or one cross pair)");
        // Single arena, like the slice-sweep capture: a sweep is a WITHIN-frame
        // measurement, so it walks one arena and never the pool.
        Arena& sweep_arena = pool.arenas[0];
        const size_t range = clamp_sweep_range(sweep_arena, sweep_range, protocol);
        info("offset sweep — pair (%d,%d), protocol=%s, range=%zu B, step=%" PRIu64 ":\n",
             pa, pb, protocol_name(protocol), range, sweep_step);
        if (protocol == PROTO_TWOFLAG)
            info("  (offset is the line-pair base; flag_a at offset+64, flag_b at offset+128)\n");
        info("  offset_B    median_ns\n");
        pin_orchestrator(pa, pb);
        for (size_t off = 0; off < range; off += sweep_step)
            info("  %8zu  %11.2f\n", off,
                 measure_placement(sweep_arena, off, pa, pb, protocol, timing,
                                   env.ns_per_cycle, false));
        pool_destroy(pool);
        return 0;
    }

    if (have_pair) {
        HouseStats s = house_stats(cell_for(pa, pb, protocol));
        info("pair (%d,%d) RTT: median %.2f ns   [Q1 %.2f, Q3 %.2f, min %.2f, max %.2f, "
             "n=%d %s]\n",
             pa, pb, s.median, s.iqr_lo, s.iqr_hi, s.min, s.max, s.n_reps, sample_unit);
        pool_destroy(pool);
        return 0;
    }

    if (!full_matrix)
        die("no mode selected. Pick --capture (production) or one of the "
            "diagnostic modes: --full-matrix, --pair a,b, --baseline, "
            "--offset-sweep. See --help.");

    // ── Full matrix (text). ──
    const size_t n = cores.size();
    std::vector<std::vector<double>> rtt(n, std::vector<double>(n, -1.0));
    std::vector<std::vector<double>> spread(n, std::vector<double>(n, -1.0));
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = i + 1; j < n; ++j) {
            if (verbose) info("  measuring pair (%d,%d)...\n", cores[i].cpu, cores[j].cpu);
            HouseStats s = house_stats(cell_for(cores[i].cpu, cores[j].cpu, protocol));
            rtt[i][j] = rtt[j][i] = s.median;
            spread[i][j] = spread[j][i] = s.iqr;
        }
    }

    auto print_matrix = [&](const char* title, const std::vector<std::vector<double>>& m) {
        info("%s\n\n", title);
        info("     ");
        for (size_t j = 0; j < n; ++j) info("%8d", cores[j].cpu);
        info("\n");
        for (size_t i = 0; i < n; ++i) {
            info("%4d ", cores[i].cpu);
            for (size_t j = 0; j < n; ++j) {
                if (i == j) info("%8s", "-");
                else        info("%8.1f", m[i][j]);
            }
            info("\n");
        }
    };

    char title[160];
    std::snprintf(title, sizeof(title),
                  "median RTT matrix (ns), protocol=%s, %" PRIu64 " placement(s)/cell:",
                  protocol_name(protocol), repeat);
    print_matrix(title, rtt);
    if (repeat > 1) {
        info("\n");
        print_matrix("across-placement IQR matrix (ns) — the slice-placement error bar:", spread);
    }
    info("\n(rows/cols are core ids; each cell is the median round-trip ns for that pair)\n");
    pool_destroy(pool);
    return 0;
}
