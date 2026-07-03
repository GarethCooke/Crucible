#pragma once
// Hardware performance counter wrapper using perf_event_open (Linux only).
// Counts branches, branch misses, instructions, and cycles for the user-space
// hot path only (exclude_kernel = 1). Requires kernel.perf_event_paranoid <= 1.

#ifdef __linux__

#include <cstdint>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/perf_event.h>

namespace crucible {

class PerfCounters {
public:
    struct Counts {
        uint64_t branches      = 0;
        uint64_t branch_misses = 0;
        uint64_t instructions  = 0;
        uint64_t cycles        = 0;
        uint64_t raw           = 0;      // optional raw PMU event; valid iff raw_ok
        bool     raw_ok        = false;

        double branch_misses_per_op(int64_t ops) const noexcept {
            return ops > 0 ? static_cast<double>(branch_misses) / ops : 0.0;
        }
        double ipc() const noexcept {
            return cycles > 0 ? static_cast<double>(instructions) / cycles : 0.0;
        }

        Counts& operator+=(const Counts& o) noexcept {
            branches      += o.branches;
            branch_misses += o.branch_misses;
            instructions  += o.instructions;
            cycles        += o.cycles;
            raw           += o.raw;
            raw_ok         = raw_ok || o.raw_ok;
            return *this;
        }
    };

    explicit PerfCounters(std::optional<uint64_t> raw_config = std::nullopt) {
        fd_branches_   = open_hw(PERF_COUNT_HW_BRANCH_INSTRUCTIONS);
        fd_misses_     = open_hw(PERF_COUNT_HW_BRANCH_MISSES);
        fd_instrs_     = open_hw(PERF_COUNT_HW_INSTRUCTIONS);
        fd_cycles_     = open_hw(PERF_COUNT_HW_CPU_CYCLES);

        if (fd_branches_ < 0 || fd_misses_ < 0 || fd_instrs_ < 0 || fd_cycles_ < 0) {
            for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_})
                if (fd >= 0) ::close(fd);
            throw std::runtime_error(
                "perf_event_open failed — run: sysctl kernel.perf_event_paranoid=1");
        }

        // The raw event is fail-soft: not every kernel/PMU exposes it, so a
        // failed open leaves fd_raw_ = -1 and read() reports raw_ok = false.
        if (raw_config)
            fd_raw_ = open_event(PERF_TYPE_RAW, *raw_config);
    }

    ~PerfCounters() {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_, fd_raw_})
            if (fd >= 0) ::close(fd);
    }

    // Non-copyable; movable (transfers fd ownership)
    PerfCounters(const PerfCounters&)            = delete;
    PerfCounters& operator=(const PerfCounters&) = delete;
    PerfCounters& operator=(PerfCounters&&)      = delete;

    PerfCounters(PerfCounters&& o) noexcept
        : fd_branches_(std::exchange(o.fd_branches_, -1)),
          fd_misses_  (std::exchange(o.fd_misses_,   -1)),
          fd_instrs_  (std::exchange(o.fd_instrs_,   -1)),
          fd_cycles_  (std::exchange(o.fd_cycles_,   -1)),
          fd_raw_     (std::exchange(o.fd_raw_,      -1)) {}

    void start() noexcept {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_, fd_raw_}) {
            if (fd < 0) continue;
            ioctl(fd, PERF_EVENT_IOC_RESET,  0);
            ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
        }
    }

    void stop() noexcept {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_, fd_raw_})
            if (fd >= 0)
                ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    }

    Counts read() const noexcept {
        Counts c;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-result"
        ::read(fd_branches_, &c.branches,      sizeof(uint64_t));
        ::read(fd_misses_,   &c.branch_misses, sizeof(uint64_t));
        ::read(fd_instrs_,   &c.instructions,  sizeof(uint64_t));
        ::read(fd_cycles_,   &c.cycles,        sizeof(uint64_t));
#pragma GCC diagnostic pop
        if (fd_raw_ >= 0)
            c.raw_ok = ::read(fd_raw_, &c.raw, sizeof(uint64_t)) == sizeof(uint64_t);
        return c;
    }

private:
    int fd_branches_{-1}, fd_misses_{-1}, fd_instrs_{-1}, fd_cycles_{-1}, fd_raw_{-1};

    static int open_event(uint32_t type, uint64_t config) noexcept {
        perf_event_attr attr{};
        attr.size           = sizeof(perf_event_attr);
        attr.type           = type;
        attr.config         = config;
        attr.disabled       = 1;
        attr.exclude_kernel = 1;
        attr.exclude_hv     = 1;
        return static_cast<int>(syscall(SYS_perf_event_open, &attr, 0, -1, -1, 0));
    }

    static int open_hw(uint64_t config) noexcept {
        return open_event(PERF_TYPE_HARDWARE, config);
    }
};

} // namespace crucible

#else
// Stub for non-Linux builds — counters always return zero.
#include <cstdint>
#include <optional>

namespace crucible {
class PerfCounters {
public:
    struct Counts {
        uint64_t branches = 0, branch_misses = 0, instructions = 0, cycles = 0;
        uint64_t raw = 0;
        bool raw_ok = false;   // stub never opens the raw event
        double branch_misses_per_op(int64_t) const noexcept { return 0.0; }
        double ipc() const noexcept { return 0.0; }
        Counts& operator+=(const Counts&) noexcept { return *this; }
    };
    PerfCounters(const PerfCounters&)            = delete;
    PerfCounters& operator=(const PerfCounters&) = delete;
    explicit PerfCounters(std::optional<uint64_t> = std::nullopt) {}
    void start() noexcept {}
    void stop()  noexcept {}
    Counts read() const noexcept { return {}; }
};
} // namespace crucible
#endif // __linux__
