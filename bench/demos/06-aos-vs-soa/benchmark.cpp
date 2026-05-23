// AoS vs SoA benchmark — Demo 06
//
// Usage:
//   bench_06_aos_vs_soa <variant> --n N --k K [--iterations I]
//   bench_06_aos_vs_soa --machine-info
//   bench_06_aos_vs_soa <variant> --verify-codegen
//
// Variants: aos-scalar | soa-scalar | soa-autovec
//
// Pinning: single thread, pinned to BENCH_CORE (4) via taskset in run_one.sh.
//          The binary verifies its affinity at startup via sched_getcpu().
// TSC:     calibrated against CLOCK_MONOTONIC_RAW (100 ms window).
//          constant_tsc + nonstop_tsc checked; abort on missing flags.

#include "kernels.h"
#include "machine_info.h"
#include "stats.h"

#include <algorithm>
#include <cassert>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <random>
#include <sched.h>
#include <string>
#include <string_view>
#include <vector>

#include <pthread.h>
#include <sstream>
#include <x86intrin.h>

#ifdef __linux__
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/perf_event.h>
#endif

// ─── Constants ───────────────────────────────────────────────────────────────

static constexpr int    BENCH_CORE        = 4;
static constexpr size_t DEFAULT_ITERS     = 5;
static constexpr int    WARMUP_MAX_ITERS  = 100;
static constexpr int    WARMUP_MS         = 500;

static constexpr int    STRUCT_SIZE_BYTES  = 128;
static constexpr int    STRUCT_FIELD_COUNT = 16;
static constexpr int    FIELD_TYPE_BYTES   =   8;

// ─── TSC helpers ─────────────────────────────────────────────────────────────

static inline uint64_t rdtscp_ordered() noexcept {
    unsigned aux;
    uint64_t t = __rdtscp(&aux);
    _mm_lfence();
    return t;
}

static double calibrate_tsc() {
    bool has_constant = false, has_nonstop = false, has_invariant = false;
    if (FILE* f = std::fopen("/proc/cpuinfo", "r")) {
        char line[256];
        while (std::fgets(line, sizeof(line), f)) {
            if (std::strstr(line, "constant_tsc"))  has_constant  = true;
            if (std::strstr(line, "nonstop_tsc"))   has_nonstop   = true;
            if (std::strstr(line, "invariant_tsc")) has_invariant = true;
        }
        std::fclose(f);
    }
    if (!has_constant || !has_nonstop) {
        std::fprintf(stderr,
            "ERROR: TSC stability flags missing in /proc/cpuinfo.\n"
            "  constant_tsc:  %s\n  nonstop_tsc:   %s\n  invariant_tsc: %s\n",
            has_constant  ? "present" : "MISSING",
            has_nonstop   ? "present" : "MISSING",
            has_invariant ? "present" : "absent (non-fatal)");
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

static void pin_and_verify(int core) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(core, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpuset), &cpuset) != 0) {
        std::fprintf(stderr, "ERROR: pthread_setaffinity_np to core %d failed\n", core);
        std::exit(1);
    }
    sched_yield();
    const int actual = sched_getcpu();
    if (actual != core) {
        std::fprintf(stderr,
            "ERROR: affinity mismatch — expected core %d, running on %d\n", core, actual);
        std::exit(1);
    }
}

// ─── THP helper ──────────────────────────────────────────────────────────────

static std::string thp_setting() {
#ifdef __linux__
    if (FILE* f = std::fopen("/sys/kernel/mm/transparent_hugepage/enabled", "r")) {
        char buf[128] = {};
        if (std::fgets(buf, sizeof(buf), f)) {
            std::fclose(f);
            // Output is like: "always [madvise] never" — extract active option.
            std::string s(buf);
            auto lb = s.find('[');
            auto rb = s.find(']');
            if (lb != std::string::npos && rb != std::string::npos)
                return s.substr(lb + 1, rb - lb - 1);
        } else { std::fclose(f); }
    }
#endif
    return "unknown";
}

// ─── Lightweight cache perf counters ─────────────────────────────────────────
// Captures LLC misses, instructions, cycles per measurement iteration.
// Falls back gracefully if perf_event_open is unavailable.

struct CacheCounters {
    struct Counts {
        uint64_t llc_misses  = 0;
        uint64_t instructions = 0;
        uint64_t cycles       = 0;
        bool     valid        = false;
    };

#ifdef __linux__
    int fd_llc_   = -1;
    int fd_instr_ = -1;
    int fd_cycles_= -1;

    CacheCounters() {
        auto open_event = [](uint32_t type, uint64_t config) -> int {
            perf_event_attr attr{};
            attr.size           = sizeof(perf_event_attr);
            attr.type           = type;
            attr.config         = config;
            attr.disabled       = 1;
            attr.exclude_kernel = 1;
            attr.exclude_hv     = 1;
            return static_cast<int>(
                syscall(SYS_perf_event_open, &attr, 0, -1, -1, 0));
        };
        fd_llc_    = open_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CACHE_MISSES);
        fd_instr_  = open_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_INSTRUCTIONS);
        fd_cycles_ = open_event(PERF_TYPE_HARDWARE, PERF_COUNT_HW_CPU_CYCLES);
        if (fd_llc_ < 0 || fd_instr_ < 0 || fd_cycles_ < 0) {
            // Close any that opened successfully.
            for (int fd : {fd_llc_, fd_instr_, fd_cycles_})
                if (fd >= 0) ::close(fd);
            fd_llc_ = fd_instr_ = fd_cycles_ = -1;
            std::fprintf(stderr,
                "WARN: perf_event_open failed — cache counters will be null.\n"
                "      Check kernel.perf_event_paranoid (needs <= 1).\n");
        }
    }

    ~CacheCounters() {
        for (int fd : {fd_llc_, fd_instr_, fd_cycles_})
            if (fd >= 0) ::close(fd);
    }

    bool available() const noexcept { return fd_llc_ >= 0; }

    void start() noexcept {
        if (!available()) return;
        for (int fd : {fd_llc_, fd_instr_, fd_cycles_}) {
            ioctl(fd, PERF_EVENT_IOC_RESET,  0);
            ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
        }
    }

    void stop() noexcept {
        if (!available()) return;
        for (int fd : {fd_llc_, fd_instr_, fd_cycles_})
            ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    }

    Counts read() const noexcept {
        Counts c;
        if (!available()) return c;
        c.valid = true;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-result"
        ::read(fd_llc_,    &c.llc_misses,   sizeof(uint64_t));
        ::read(fd_instr_,  &c.instructions, sizeof(uint64_t));
        ::read(fd_cycles_, &c.cycles,        sizeof(uint64_t));
#pragma GCC diagnostic pop
        return c;
    }
#else
    CacheCounters() {}
    bool available() const noexcept { return false; }
    void start() noexcept {}
    void stop()  noexcept {}
    Counts read() const noexcept { return {}; }
#endif
};

// ─── Data initialisation ─────────────────────────────────────────────────────

static void fill_aos(RecordAoS* records, size_t n, uint32_t seed) {
    std::mt19937_64 rng(seed);
    std::uniform_real_distribution<double> dist(-1.0, 1.0);
    for (size_t i = 0; i < n; ++i) {
        double* f = &records[i].f0;
        for (int j = 0; j < STRUCT_FIELD_COUNT; ++j)
            f[j] = dist(rng);
    }
}

static void fill_soa(RecordSoA& soa, size_t n, uint32_t seed) {
    std::mt19937_64 rng(seed);
    std::uniform_real_distribution<double> dist(-1.0, 1.0);
    double* cols[16] = {
        soa.f0.data,  soa.f1.data,  soa.f2.data,  soa.f3.data,
        soa.f4.data,  soa.f5.data,  soa.f6.data,  soa.f7.data,
        soa.f8.data,  soa.f9.data,  soa.f10.data, soa.f11.data,
        soa.f12.data, soa.f13.data, soa.f14.data, soa.f15.data,
    };
    // Fill in field-major order to match SoA access pattern; seed is fixed
    // for reproducibility across variant invocations.
    for (int j = 0; j < STRUCT_FIELD_COUNT; ++j)
        for (size_t i = 0; i < n; ++i)
            cols[j][i] = dist(rng);
}

// ─── Measurement ─────────────────────────────────────────────────────────────

struct RunResult {
    std::vector<double> ns_per_iter;  // per-iteration ns_per_element
    CacheCounters::Counts total_counts;
};

// Runs one kernel invocation; returns ns for that iteration.
static double run_kernel(std::string_view variant,
                         RecordAoS*       aos,
                         RecordSoA*       soa,
                         size_t           n,
                         int              k,
                         double           ns_per_cycle) {
    volatile double sink;
    const uint64_t t0 = rdtscp_ordered();
    if (variant == "aos-scalar")
        sink = scan_aos(aos, n, k);
    else if (variant == "soa-scalar")
        sink = scan_soa_scalar(*soa, n, k);
    else
        sink = scan_soa_autovec(*soa, n, k);
    const uint64_t t1 = rdtscp_ordered();
    (void)sink;
    return static_cast<double>(t1 - t0) * ns_per_cycle / static_cast<double>(n);
}

static RunResult measure(std::string_view variant,
                         RecordAoS*       aos,
                         RecordSoA*       soa,
                         size_t           n,
                         int              k,
                         size_t           iterations,
                         double           ns_per_cycle) {
    CacheCounters counters;

    // Warmup: 500 ms wall-clock or WARMUP_MAX_ITERS, whichever is shorter.
    {
        using clock = std::chrono::steady_clock;
        auto warmup_start = clock::now();
        for (int wi = 0; wi < WARMUP_MAX_ITERS; ++wi) {
            volatile double sink = 0.0;
            if (variant == "aos-scalar")
                sink = scan_aos(aos, n, k);
            else if (variant == "soa-scalar")
                sink = scan_soa_scalar(*soa, n, k);
            else
                sink = scan_soa_autovec(*soa, n, k);
            (void)sink;
            auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(
                clock::now() - warmup_start);
            if (elapsed.count() >= WARMUP_MS) break;
        }
    }

    // Measurement phase.
    RunResult result;
    result.ns_per_iter.reserve(iterations);

    counters.start();
    for (size_t iter = 0; iter < iterations; ++iter) {
        const double ns_elem = run_kernel(variant, aos, soa, n, k, ns_per_cycle);
        result.ns_per_iter.push_back(ns_elem);
    }
    counters.stop();
    result.total_counts = counters.read();

    return result;
}

// ─── JSON emission ────────────────────────────────────────────────────────────

static std::string emit_run_json(std::string_view variant,
                                  size_t           n,
                                  int              k,
                                  size_t           iterations,
                                  const RunResult& r,
                                  double           calibration_drift_pct,
                                  const std::string& captured_at,
                                  const std::string& thp) {
    const auto& v = r.ns_per_iter;

    const double med  = crucible::median(std::vector<double>(v));
    const double mn   = crucible::minimum(std::vector<double>(v));
    const double p99  = crucible::percentile(std::vector<double>(v), 99.0);
    const double iqr_ = crucible::iqr(std::vector<double>(v));

    const double ops_per_sec = 1.0e9 / med;

    // Cache counters: divide totals by (iterations × n) to get per-element rates.
    const double total_ops = static_cast<double>(iterations) * static_cast<double>(n);
    std::string llc_field, l1d_field, ipc_field;
    if (r.total_counts.valid) {
        char buf[64];
        std::snprintf(buf, sizeof(buf), "%.6f",
            static_cast<double>(r.total_counts.llc_misses) / total_ops);
        llc_field = buf;

        std::snprintf(buf, sizeof(buf), "null");
        l1d_field = buf;  // l1d.replacement not in PerfCounters stub — always null

        if (r.total_counts.cycles > 0) {
            std::snprintf(buf, sizeof(buf), "%.4f",
                static_cast<double>(r.total_counts.instructions) /
                static_cast<double>(r.total_counts.cycles));
            ipc_field = buf;
        } else {
            ipc_field = "null";
        }
    } else {
        llc_field = "null";
        l1d_field = "null";
        ipc_field = "null";
    }

    char buf[2048];
    std::snprintf(buf, sizeof(buf),
        "{"
        "\"variant\":\"%.*s\","
        "\"n\":%zu,"
        "\"k\":%d,"
        "\"struct_size_bytes\":%d,"
        "\"struct_field_count\":%d,"
        "\"field_type_bytes\":%d,"
        "\"access_pattern\":\"sequential\","
        "\"kernel\":\"sum_reduction\","
        "\"iterations\":%zu,"
        "\"items_measured\":%zu,"
        "\"items_warmup\":0,"
        "\"warmup_ms\":%d,"
        "\"ns_per_op\":{\"median\":%.4f,\"min\":%.4f,\"p99\":%.4f,\"iqr\":%.4f},"
        "\"ops_per_sec\":%.0f,"
        "\"llc_misses_per_op\":%s,"
        "\"l1d_misses_per_op\":%s,"
        "\"instructions_per_cycle\":%s,"
        "\"calibration_drift_pct\":%.4f,"
        "\"transparent_hugepage\":\"%s\","
        "\"captured_at\":\"%s\""
        "}",
        static_cast<int>(variant.size()), variant.data(),
        n, k,
        STRUCT_SIZE_BYTES, STRUCT_FIELD_COUNT, FIELD_TYPE_BYTES,
        iterations, n, WARMUP_MS,
        med, mn, p99, iqr_,
        ops_per_sec,
        llc_field.c_str(), l1d_field.c_str(), ipc_field.c_str(),
        calibration_drift_pct,
        thp.c_str(),
        captured_at.c_str());

    return buf;
}

// ─── Codegen verification ────────────────────────────────────────────────────

static int do_verify_codegen() {
    // Read the binary path via /proc/self/exe on Linux.
    char bin_path[4096] = {};
#ifdef __linux__
    ssize_t len = readlink("/proc/self/exe", bin_path, sizeof(bin_path) - 1);
    if (len < 0) {
        std::fprintf(stderr, "ERROR: readlink(/proc/self/exe) failed\n");
        return 1;
    }
    bin_path[len] = '\0';
#else
    std::fprintf(stderr, "WARN: --verify-codegen only works on Linux (needs /proc/self/exe)\n");
    return 1;
#endif

    std::fprintf(stderr, "Verifying codegen in: %s\n\n", bin_path);

    // Run objdump and capture output.
    char cmd[4096 + 64];
    std::snprintf(cmd, sizeof(cmd), "objdump -d --no-show-raw-insn '%s' 2>&1", bin_path);

    FILE* fp = popen(cmd, "r");
    if (!fp) {
        std::fprintf(stderr, "ERROR: popen(objdump) failed\n");
        return 1;
    }

    std::string disasm;
    char line[512];
    while (std::fgets(line, sizeof(line), fp))
        disasm += line;
    pclose(fp);

    // Helper: extract lines belonging to a function symbol.
    auto extract_fn = [&](const char* sym) -> std::string {
        // Look for "<sym>:" or "<sym(...)>:" in the disassembly.
        // objdump demangling may add parameter types; match on sym as substring.
        std::string marker = std::string("<") + sym;
        std::string fn_asm;
        bool in_fn = false;
        std::istringstream ss(disasm);
        std::string ln;
        while (std::getline(ss, ln)) {
            if (!in_fn) {
                if (ln.find(marker) != std::string::npos) in_fn = true;
            } else {
                // A blank line or next function header ends the block.
                if (ln.empty() || (ln.size() > 0 && ln[0] != ' ' && ln[0] != '\t'
                                   && ln.find(marker) == std::string::npos
                                   && ln.find('<') != std::string::npos)) {
                    break;
                }
                fn_asm += ln + "\n";
            }
        }
        return fn_asm;
    };

    // Check for ymm packed-double instructions.
    auto has_ymm_packed = [](const std::string& asm_) -> bool {
        // ymm packed double ops: vaddpd ymm, vmovapd ymm, vmulpd ymm, vhaddpd ymm, etc.
        return asm_.find("ymm") != std::string::npos &&
               (asm_.find("vaddpd") != std::string::npos ||
                asm_.find("vmovapd") != std::string::npos ||
                asm_.find("vmulpd") != std::string::npos ||
                asm_.find("vperm") != std::string::npos ||
                asm_.find("vhaddpd") != std::string::npos);
    };

    auto has_scalar_double_only = [](const std::string& asm_) -> bool {
        // Should see vaddsd / vmovsd (xmm scalar) but NOT vaddpd ymm / vmovapd ymm.
        return (asm_.find("vaddsd") != std::string::npos ||
                asm_.find("addsd") != std::string::npos) &&
               asm_.find("ymm") == std::string::npos;
    };

    int exit_code = 0;

    struct Check {
        const char* sym;
        const char* variant;
        bool        expect_ymm;
        const char* description;
    };

    Check checks[] = {
        { "scan_aos",         "aos-scalar",    false,
          "strided AoS access must NOT emit packed-double (ymm) ops" },
        { "scan_soa_scalar",  "soa-scalar",    false,
          "no-tree-vectorize pragma must suppress ymm packed-double ops" },
        { "scan_soa_autovec", "soa-autovec",   true,
          "auto-vectorised SoA MUST emit ymm packed-double ops" },
    };

    for (const auto& c : checks) {
        const std::string fn_asm = extract_fn(c.sym);
        if (fn_asm.empty()) {
            std::fprintf(stderr, "  [WARN] %s: symbol not found — binary may not include it\n",
                c.sym);
            continue;
        }

        bool got_ymm = has_ymm_packed(fn_asm);
        bool pass;
        if (c.expect_ymm)
            pass = got_ymm;
        else
            pass = !got_ymm;

        std::fprintf(stdout, "  [%s] %s (%s)\n        %s\n",
            pass ? "PASS" : "FAIL",
            c.sym, c.variant, c.description);

        if (!pass) {
            if (c.expect_ymm)
                std::fprintf(stdout, "        Expected ymm packed-double instructions — "
                             "check that vectorisation is enabled for this function.\n");
            else
                std::fprintf(stdout, "        Found ymm packed-double instructions — "
                             "vectorisation leaked into this variant.\n");
            // Dump first 20 lines of the function.
            int count = 0;
            std::istringstream ss(fn_asm);
            std::string ln;
            while (std::getline(ss, ln) && count < 20) {
                std::fprintf(stdout, "        | %s\n", ln.c_str());
                ++count;
            }
            exit_code = 1;
        }
    }

    std::fprintf(stdout, "\nCodegen verification %s\n", exit_code == 0 ? "PASSED" : "FAILED");
    return exit_code;
}

// ─── Main ─────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: %s <variant> --n N --k K [--iterations I]\n"
            "       %s --machine-info\n"
            "       %s <variant> --verify-codegen\n"
            "Variants: aos-scalar | soa-scalar | soa-autovec\n",
            argv[0], argv[0], argv[0]);
        return 1;
    }

    // ── Machine info ─────────────────────────────────────────────────────────
    if (std::string_view(argv[1]) == "--machine-info") {
        const double ns_per_cycle = calibrate_tsc();
        const std::string thp = thp_setting();
        std::printf("{%s,"
                    "\"tsc_ns_per_cycle\":%.6f,"
                    "\"transparent_hugepage\":\"%s\"}\n",
            crucible::machine_info_json().c_str(), ns_per_cycle, thp.c_str());
        return 0;
    }

    // ── Validate variant ─────────────────────────────────────────────────────
    const std::string_view variant = argv[1];
    if (variant != "aos-scalar" && variant != "soa-scalar" && variant != "soa-autovec") {
        std::fprintf(stderr, "ERROR: unknown variant '%s'\n", argv[1]);
        std::fprintf(stderr, "Valid: aos-scalar | soa-scalar | soa-autovec\n");
        return 1;
    }

    // ── Parse flags ──────────────────────────────────────────────────────────
    size_t n          = 0;
    int    k          = 0;
    size_t iterations = DEFAULT_ITERS;
    bool   do_verify  = false;

    for (int i = 2; i < argc; ++i) {
        std::string_view arg = argv[i];
        if (arg == "--verify-codegen") {
            do_verify = true;
        } else if (arg == "--n" && i + 1 < argc) {
            try { n = std::stoull(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --n requires a positive integer\n"); return 1; }
        } else if (arg == "--k" && i + 1 < argc) {
            try { k = std::stoi(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --k requires a positive integer\n"); return 1; }
        } else if (arg == "--iterations" && i + 1 < argc) {
            try { iterations = std::stoull(argv[++i]); }
            catch (...) { std::fprintf(stderr, "ERROR: --iterations requires a positive integer\n"); return 1; }
        } else {
            std::fprintf(stderr, "ERROR: unknown option '%s'\n", argv[i]);
            return 1;
        }
    }

    // ── Codegen verification mode ────────────────────────────────────────────
    if (do_verify) {
        return do_verify_codegen();
    }

    // ── Validate required args ───────────────────────────────────────────────
    if (n == 0 || k == 0) {
        std::fprintf(stderr, "ERROR: --n and --k are required for measurement mode\n");
        return 1;
    }
    if (k > STRUCT_FIELD_COUNT) {
        std::fprintf(stderr, "ERROR: --k %d exceeds STRUCT_FIELD_COUNT %d\n",
            k, STRUCT_FIELD_COUNT);
        return 1;
    }
    if (iterations == 0) {
        std::fprintf(stderr, "ERROR: --iterations must be >= 1\n");
        return 1;
    }

    // ── Pin to benchmark core ────────────────────────────────────────────────
    pin_and_verify(BENCH_CORE);
    std::fprintf(stderr, "Pinned to core %d\n", BENCH_CORE);

    // ── TSC calibration ──────────────────────────────────────────────────────
    const double ns_per_cycle = calibrate_tsc();
    std::fprintf(stderr, "TSC calibration: %.6f ns/cycle\n", ns_per_cycle);

    // Calibration drift check: re-calibrate once to measure drift.
    const double ns_per_cycle2 = calibrate_tsc();
    const double drift_pct =
        std::abs(ns_per_cycle2 - ns_per_cycle) / ns_per_cycle * 100.0;
    std::fprintf(stderr, "Calibration drift: %.4f%%\n", drift_pct);

    // Timestamp for captured_at.
    char captured_at[32] = {};
    {
        time_t t = time(nullptr);
        struct tm* tm_info = gmtime(&t);
        strftime(captured_at, sizeof(captured_at), "%Y-%m-%dT%H:%M:%SZ", tm_info);
    }

    const std::string thp = thp_setting();

    std::fprintf(stderr, "variant=%.*s  n=%zu  k=%d  iterations=%zu  thp=%s\n",
        static_cast<int>(variant.size()), variant.data(),
        n, k, iterations, thp.c_str());

    // ── Allocate data ────────────────────────────────────────────────────────
    // Fixed seed for reproducibility across variant invocations.
    constexpr uint32_t DATA_SEED = 0xC0FFEE42u;

    RecordAoS* aos = nullptr;
    RecordSoA* soa = nullptr;

    if (variant == "aos-scalar") {
        aos = static_cast<RecordAoS*>(std::aligned_alloc(64, n * sizeof(RecordAoS)));
        if (!aos) { std::fprintf(stderr, "ERROR: allocation failed\n"); return 1; }
        fill_aos(aos, n, DATA_SEED);
    } else {
        soa = new RecordSoA(n);
        fill_soa(*soa, n, DATA_SEED);
    }

    // ── Run measurement ──────────────────────────────────────────────────────
    RunResult result = measure(variant, aos, soa, n, k, iterations, ns_per_cycle);

    // ── Emit JSON ────────────────────────────────────────────────────────────
    std::string json = emit_run_json(
        variant, n, k, iterations, result,
        drift_pct, captured_at, thp);

    std::printf("%s\n", json.c_str());

    // ── Cleanup ──────────────────────────────────────────────────────────────
    std::free(aos);
    delete soa;

    return 0;
}
