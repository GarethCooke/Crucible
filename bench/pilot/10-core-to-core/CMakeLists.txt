# Pilot bench 10: core-to-core cache-line ping-pong RTT (throwaway).
#
# Standalone CMakeLists — invoke directly, do NOT add_subdirectory from the
# bench root. This pilot is calibration scaffolding for demo 10 §1; it is not
# wired into run_one.sh and ships nothing.
#
# Machine 1 only (Ryzen 7 3800X, Zen 2, x86-64). -march=native is required:
# the harness uses rdtscp and expects the invariant TSC of this rig.
#
# Build:
#   cmake -S . -B build
#   cmake --build build
#
# Run (off-rig sanity only — numbers are meaningless without core isolation):
#   ./build/pingpong --help
#   ./build/pingpong --full-matrix --k 100 --windows 2

cmake_minimum_required(VERSION 3.16)
project(pilot_10_core_to_core CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_executable(pingpong pingpong.cpp)

# -O3 -march=native: tune to this exact rig. rdtscp / TSC calibration assume
# the Matisse invariant TSC (see brief §Task 2, "Cycles → ns").
# -Wall -Wextra: the brief requires a warning-clean build.
target_compile_options(pingpong PRIVATE -O3 -march=native -Wall -Wextra)

find_package(Threads REQUIRED)
target_link_libraries(pingpong PRIVATE Threads::Threads)
