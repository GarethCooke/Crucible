# Pilot bench 09: ARM NEON Black-Scholes (throwaway, Pi 5 / AArch64 only).
#
# Standalone CMakeLists — invoke directly, do NOT add_subdirectory from the
# bench root (the bench root adds -march=native; this pilot requires
# -mcpu=cortex-a76 and must not pick up the global -march=native flag).
#
# Build on the Pi 5 rig:
#   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
#   cmake --build build
#
# Acceptance: cmake --build build succeeds; asm/ contains price_neon.s and
# price_scalar.s; grep -E 'fmla|v[0-9]+\.4s' asm/price_neon.s returns matches.

cmake_minimum_required(VERSION 3.16)
project(pilot_09_arm_neon CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(pilot_blackscholes pilot_blackscholes.cpp)

# -mcpu=cortex-a76: target the Pi 5's BCM2712 / Cortex-A76 exactly.
# Do NOT use -march=native or -mtune=native (see brief §context).
#
# The scalar baseline is guarded against autovectorisation by
# __attribute__((optimize("no-tree-vectorize"))) on price_scalar itself
# rather than a per-TU flag, so both functions can live in one translation
# unit.  See pilot_blackscholes.cpp and brief §4 (open item 1).
target_compile_options(pilot_blackscholes PRIVATE -O3 -mcpu=cortex-a76)

target_include_directories(pilot_blackscholes PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../demos/03-simd-blackscholes)

# ─── asm dump (Linux / Pi only) ───────────────────────────────────────────────
# Post-build: disassemble the binary and extract price_scalar / price_neon into
# separate .s files under asm/ so the user can eyeball §A5 (vector fmla/v-regs
# present in NEON, absent in scalar) without re-deriving the build.
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    add_custom_command(TARGET pilot_blackscholes POST_BUILD
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/dump_asm.sh"
                "$<TARGET_FILE:pilot_blackscholes>"
                "${CMAKE_CURRENT_SOURCE_DIR}/asm"
        COMMENT "Dumping asm/price_neon.s and asm/price_scalar.s"
        VERBATIM)
endif()
