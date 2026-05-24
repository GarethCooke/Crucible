cmake_minimum_required(VERSION 3.20)

# ─── Main benchmark binary ────────────────────────────────────────────────────

add_executable(bench_06_aos_vs_soa benchmark.cpp)

target_include_directories(bench_06_aos_vs_soa PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(bench_06_aos_vs_soa PRIVATE
    crucible_common
    pthread
)

target_compile_options(bench_06_aos_vs_soa PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)

# ─── Standalone codegen verification binary ───────────────────────────────────

add_executable(verify_06_aos_vs_soa verify.cpp)

target_compile_options(verify_06_aos_vs_soa PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
