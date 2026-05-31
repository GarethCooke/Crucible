# Demo 09: ARM NEON Black-Scholes — scalar vs autovec vs hand-NEON
#
# AArch64 / Cortex-A76 (BCM2712 / Raspberry Pi 5) target.
# Four variants parallel to demo 03's {scalar_libm, scalar_poly, sse2, avx2fma}:
#   scalar_libm — all libm, anti-autovec guard (1-wide oracle)
#   scalar_poly — demo 3's exact split: libm log/sqrt + poly exp/N(x), anti-autovec guard
#   autovec     — natural libm kernel, no guard, GCC free-vectorise attempt
#   neon        — hand-written float32x4_t, branchless, inline poly log/exp/N(x)
#
# On AArch64, NEON is baseline ISA; -mcpu=cortex-a76 enables A76-specific tuning.
# -fno-tree-vectorize on scalar variants prevents the auto-widening that -O3 would
# otherwise attempt on a target where 128-bit SIMD is always available.
#
# Acceptance: cmake --build build --target 09-arm-neon

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 1: scalar_libm ──────────────────────────────────────────────────
add_library(bs09_scalar_libm OBJECT scalar_libm.cpp)
target_compile_options(bs09_scalar_libm PRIVATE
    -O3 -mcpu=cortex-a76 -fno-tree-vectorize)
target_include_directories(bs09_scalar_libm PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 2: scalar_poly ──────────────────────────────────────────────────
add_library(bs09_scalar_poly OBJECT scalar_poly.cpp)
target_compile_options(bs09_scalar_poly PRIVATE
    -O3 -mcpu=cortex-a76 -fno-tree-vectorize)
target_include_directories(bs09_scalar_poly PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 3: autovec ──────────────────────────────────────────────────────
# No -fno-tree-vectorize: GCC may attempt widening.
# Pilot confirmed: GCC cannot cross the logf@plt barrier — asm is scalar.
add_library(bs09_autovec OBJECT autovec.cpp)
target_compile_options(bs09_autovec PRIVATE
    -O3 -mcpu=cortex-a76)
target_include_directories(bs09_autovec PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 4: neon_intrinsics ──────────────────────────────────────────────
add_library(bs09_neon OBJECT neon_intrinsics.cpp)
target_compile_options(bs09_neon PRIVATE
    -O3 -mcpu=cortex-a76)
target_include_directories(bs09_neon PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Shared input generation ──────────────────────────────────────────────────
add_library(bs09_inputs OBJECT inputs.cpp)
target_include_directories(bs09_inputs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Main benchmark binary ────────────────────────────────────────────────────
add_executable(bench_09_arm_neon benchmark.cpp
    $<TARGET_OBJECTS:bs09_inputs>
    $<TARGET_OBJECTS:bs09_scalar_libm>
    $<TARGET_OBJECTS:bs09_scalar_poly>
    $<TARGET_OBJECTS:bs09_autovec>
    $<TARGET_OBJECTS:bs09_neon>)
target_link_libraries(bench_09_arm_neon PRIVATE crucible_common)
target_include_directories(bench_09_arm_neon PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Verify binary ────────────────────────────────────────────────────────────
add_executable(verify_09_arm_neon verify.cpp
    $<TARGET_OBJECTS:bs09_inputs>
    $<TARGET_OBJECTS:bs09_scalar_libm>
    $<TARGET_OBJECTS:bs09_scalar_poly>
    $<TARGET_OBJECTS:bs09_autovec>
    $<TARGET_OBJECTS:bs09_neon>)
target_link_libraries(verify_09_arm_neon PRIVATE crucible_common)
target_include_directories(verify_09_arm_neon PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Post-build steps (Linux/AArch64 only) ───────────────────────────────────
# OBJECT libraries cannot have POST_BUILD commands; attach to the executable.
# Order: asm dump first, then correctness check.
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    add_custom_command(TARGET bench_09_arm_neon POST_BUILD
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/dump_asm.sh" "${CMAKE_BINARY_DIR}"
        COMMENT "Dumping asm/*.s disassembly"
        VERBATIM)
    add_dependencies(bench_09_arm_neon verify_09_arm_neon)
    add_custom_command(TARGET bench_09_arm_neon POST_BUILD
        COMMAND $<TARGET_FILE:verify_09_arm_neon>
        COMMENT "Running correctness check (verify_09_arm_neon)..."
        VERBATIM)
endif()

add_custom_target(09-arm-neon
    DEPENDS bench_09_arm_neon verify_09_arm_neon)
