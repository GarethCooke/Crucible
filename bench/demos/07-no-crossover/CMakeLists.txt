cmake_minimum_required(VERSION 3.20)

# ─── Abseil via FetchContent ──────────────────────────────────────────────────

include(FetchContent)
FetchContent_Declare(
  abseil-cpp
  GIT_REPOSITORY https://github.com/abseil/abseil-cpp.git
  GIT_TAG        20240722.0
  GIT_SHALLOW    TRUE
)
set(ABSL_ENABLE_INSTALL     OFF CACHE BOOL "" FORCE)
set(ABSL_PROPAGATE_CXX_STD  ON  CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(abseil-cpp)

# ─── Boost (header-only) ─────────────────────────────────────────────────────

find_package(Boost 1.74 REQUIRED)

# ─── Main benchmark binary ────────────────────────────────────────────────────

add_executable(bench_07_no_crossover benchmark.cpp)

target_compile_features(bench_07_no_crossover PRIVATE cxx_std_20)

target_include_directories(bench_07_no_crossover PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Boost_INCLUDE_DIRS}
)

target_link_libraries(bench_07_no_crossover PRIVATE
    crucible_common
    absl::flat_hash_map
    absl::hash
)

target_compile_options(bench_07_no_crossover PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
