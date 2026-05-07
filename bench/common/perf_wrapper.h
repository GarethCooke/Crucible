#pragma once
// Hardware performance counter wrapper using perf_event_open (Linux only).
// Counts branches, branch misses, instructions, and cycles for the user-space
// hot path only (exclude_kernel = 1). Requires kernel.perf_event_paranoid <= 1.

#ifdef __linux__

#include <cstdint>
#include <stdexcept>
#include <string>
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
            return *this;
        }
    };

    PerfCounters() {
        fd_branches_   = open_hw(PERF_COUNT_HW_BRANCH_INSTRUCTIONS);
        fd_misses_     = open_hw(PERF_COUNT_HW_BRANCH_MISSES);
        fd_instrs_     = open_hw(PERF_COUNT_HW_INSTRUCTIONS);
        fd_cycles_     = open_hw(PERF_COUNT_HW_CPU_CYCLES);

        if (fd_branches_ < 0)
            throw std::runtime_error(
                "perf_event_open failed — run: sysctl kernel.perf_event_paranoid=1");
    }

    ~PerfCounters() {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_})
            if (fd >= 0) ::close(fd);
    }

    // Non-copyable, non-movable (file descriptors)
    PerfCounters(const PerfCounters&)            = delete;
    PerfCounters& operator=(const PerfCounters&) = delete;

    void start() noexcept {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_}) {
            ioctl(fd, PERF_EVENT_IOC_RESET,  0);
            ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
        }
    }

    void stop() noexcept {
        for (int fd : {fd_branches_, fd_misses_, fd_instrs_, fd_cycles_})
            ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    }

    Counts read() const noexcept {
        Counts c;
        ::read(fd_branches_, &c.branches,      sizeof(uint64_t));
        ::read(fd_misses_,   &c.branch_misses, sizeof(uint64_t));
        ::read(fd_instrs_,   &c.instructions,  sizeof(uint64_t));
        ::read(fd_cycles_,   &c.cycles,        sizeof(uint64_t));
        return c;
    }

private:
    int fd_branches_{-1}, fd_misses_{-1}, fd_instrs_{-1}, fd_cycles_{-1};

    static int open_hw(uint64_t config) noexcept {
        perf_event_attr attr{};
        attr.size           = sizeof(perf_event_attr);
        attr.type           = PERF_TYPE_HARDWARE;
        attr.config         = config;
        attr.disabled       = 1;
        attr.exclude_kernel = 1;
        attr.exclude_hv     = 1;
        return static_cast<int>(syscall(SYS_perf_event_open, &attr, 0, -1, -1, 0));
    }
};

} // namespace crucible

#else
// Stub for non-Linux builds — counters always return zero.
namespace crucible {
class PerfCounters {
public:
    struct Counts {
        uint64_t branches = 0, branch_misses = 0, instructions = 0, cycles = 0;
        double branch_misses_per_op(int64_t) const noexcept { return 0.0; }
        double ipc() const noexcept { return 0.0; }
        Counts& operator+=(const Counts&) noexcept { return *this; }
    };
    void start() noexcept {}
    void stop()  noexcept {}
    Counts read() const noexcept { return {}; }
};
} // namespace crucible
#endif // __linux__
