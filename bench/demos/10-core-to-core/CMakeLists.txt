cmake_minimum_required(VERSION 3.20)

# Demo 10 is a custom harness, not a Google Benchmark target — pairwise pinned-
# thread orchestration doesn't fit its model. Demo 4's custom latency pipeline is
# the precedent, and this mirrors its target shape.
add_executable(bench_10_core_to_core benchmark.cpp)

target_include_directories(bench_10_core_to_core PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# crucible_common carries bench/common on the include path — machine_info.h for
# the sacred machine block, stats.h for the house percentile helpers.
target_link_libraries(bench_10_core_to_core PRIVATE
    crucible_common
    pthread
)

# Explicit per-target flags: -O3 -march=native -std=c++20. crucible_common
# already sets the first two for Release builds; listed here for clarity, as in
# demo 4. -march=native matters more than usual: the harness uses rdtscp and
# assumes this rig's invariant TSC.
target_compile_options(bench_10_core_to_core PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
    -Wall -Wextra
)
