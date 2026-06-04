#pragma once
// Thread affinity helpers shared across benchmarks that pin threads to cores.

#include <cstdio>
#include <cstdlib>
#include <pthread.h>
#include <sched.h>
#include <thread>

namespace crucible {

// Pin the calling thread to a specific core and verify via sched_getcpu().
// Must be called from within the thread to be pinned. Aborts on failure.
inline void pin_to_core(int core) {
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

} // namespace crucible
