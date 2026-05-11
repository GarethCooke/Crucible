# Demo 03: SIMD Black-Scholes — scalar vs SSE vs AVX2+FMA
#
# Each variant TU is compiled as an OBJECT library with its own ISA flags.
# The root CMakeLists adds -march=native globally; explicit -mno-avx/-mno-avx2
# flags in the scalar and SSE OBJECT libraries override that, ensuring each
# variant is restricted to its intended ISA.  GCC honours the last flag.
#
# Acceptance: cmake --build build --target 03-simd-blackscholes

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 1: scalar_libm ──────────────────────────────────────────────────
add_library(bs_scalar_libm OBJECT scalar_libm.cpp)
target_compile_options(bs_scalar_libm PRIVATE
    -O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2)
target_include_directories(bs_scalar_libm PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 2: scalar_poly ──────────────────────────────────────────────────
add_library(bs_scalar_poly OBJECT scalar_poly.cpp)
target_compile_options(bs_scalar_poly PRIVATE
    -O3 -fno-tree-vectorize -mno-avx -mno-avx2 -mno-fma -msse4.2)
target_include_directories(bs_scalar_poly PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 3: sse2_intrinsics ──────────────────────────────────────────────
add_library(bs_sse2 OBJECT sse2_intrinsics.cpp)
target_compile_options(bs_sse2 PRIVATE
    -O3 -msse4.2 -mno-avx -mno-avx2 -mno-fma)
target_include_directories(bs_sse2 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Variant 4: avx2_fma_intrinsics ──────────────────────────────────────────
add_library(bs_avx2_fma OBJECT avx2_fma_intrinsics.cpp)
target_compile_options(bs_avx2_fma PRIVATE
    -O3 -mavx -mavx2 -mfma)
target_include_directories(bs_avx2_fma PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Main benchmark binary ────────────────────────────────────────────────────
add_executable(bench_03_simd_blackscholes benchmark.cpp
    $<TARGET_OBJECTS:bs_scalar_libm>
    $<TARGET_OBJECTS:bs_scalar_poly>
    $<TARGET_OBJECTS:bs_sse2>
    $<TARGET_OBJECTS:bs_avx2_fma>)
target_link_libraries(bench_03_simd_blackscholes PRIVATE crucible_common)
target_include_directories(bench_03_simd_blackscholes PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Verify binary ────────────────────────────────────────────────────────────
add_executable(verify_03_simd_blackscholes verify.cpp
    $<TARGET_OBJECTS:bs_scalar_libm>
    $<TARGET_OBJECTS:bs_scalar_poly>
    $<TARGET_OBJECTS:bs_sse2>
    $<TARGET_OBJECTS:bs_avx2_fma>)
target_link_libraries(verify_03_simd_blackscholes PRIVATE crucible_common)
target_include_directories(verify_03_simd_blackscholes PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ─── Post-build steps on the benchmark executable (Linux only) ───────────────
# OBJECT libraries cannot have POST_BUILD commands in CMake; attach to the
# executable instead. By link time all four .o files are already on disk.
#
# Order: asm dump first, then correctness check (so a failed verify still
# leaves fresh .s files for inspection).
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # 1. Dump disassembly for all four variants into asm/*.s
    add_custom_command(TARGET bench_03_simd_blackscholes POST_BUILD
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/dump_asm.sh" "${CMAKE_BINARY_DIR}"
        COMMENT "Dumping asm/*.s disassembly"
        VERBATIM)
    # 2. Run correctness check — build fails loudly if error > 1e-4
    add_dependencies(bench_03_simd_blackscholes verify_03_simd_blackscholes)
    add_custom_command(TARGET bench_03_simd_blackscholes POST_BUILD
        COMMAND $<TARGET_FILE:verify_03_simd_blackscholes>
        COMMENT "Running correctness check (verify_03_simd_blackscholes)..."
        VERBATIM)
endif()

# ─── Convenience target matching acceptance-criteria name ─────────────────────
add_custom_target(03-simd-blackscholes
    DEPENDS bench_03_simd_blackscholes verify_03_simd_blackscholes)
