cmake_minimum_required(VERSION 3.20)
project(crucible_bench CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Release flags: full optimisation, target this machine's ISA
add_compile_options(
  $<$<CONFIG:Release>:-O3>
  $<$<CONFIG:Release>:-march=native>
  $<$<CONFIG:Release>:-fno-omit-frame-pointer>
)

# Google Benchmark via FetchContent — no install required
include(FetchContent)
FetchContent_Declare(
  googlebenchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  GIT_TAG        v1.8.5
  GIT_SHALLOW    TRUE
)
set(BENCHMARK_ENABLE_TESTING   OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL   OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googlebenchmark)

# Common interface library: shared headers + benchmark linkage
add_library(crucible_common INTERFACE)
target_include_directories(crucible_common INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/common)
target_link_libraries(crucible_common INTERFACE benchmark::benchmark)

enable_testing()

add_subdirectory(tests)
add_subdirectory(demos/01-branch-prediction)
add_subdirectory(demos/02-false-sharing)
add_subdirectory(demos/03-simd-blackscholes)
add_subdirectory(demos/04-spsc-queue)
add_subdirectory(demos/05-allocators)
add_subdirectory(demos/06-aos-vs-soa)
add_subdirectory(demos/07-no-crossover)
add_subdirectory(demos/08-sorting-shootout)

option(CRUCIBLE_BUILD_PILOTS "Build throwaway pilot benches under bench/pilots/" OFF)
if(CRUCIBLE_BUILD_PILOTS)

endif()
