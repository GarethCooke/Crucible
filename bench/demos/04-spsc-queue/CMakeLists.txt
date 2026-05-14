cmake_minimum_required(VERSION 3.20)

# Boost is header-only for lockfree::spsc_queue; pin minimum version for reproducibility.
find_package(Boost 1.74 REQUIRED)

add_executable(bench_04_spsc_queue benchmark.cpp)

target_include_directories(bench_04_spsc_queue PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Boost_INCLUDE_DIRS}
)

target_link_libraries(bench_04_spsc_queue PRIVATE
    crucible_common
    pthread
)

# Explicit per-target flags: -O3 -march=native -std=c++20 as required by the brief.
# crucible_common already sets these for Release builds; listed here for clarity.
target_compile_options(bench_04_spsc_queue PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
