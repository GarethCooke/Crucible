# Demo 02: false-sharing P&L accumulators
# -O3 matches the documented standard (-march=native set by root CMakeLists).
# The volatile qualifier on Strategy::pnl forces a memory store per fill even
# at -O3, so the false-sharing effect is not elided by the optimiser.
add_executable(bench_02_false_sharing_pnl false_sharing_pnl.cpp)
target_link_libraries(bench_02_false_sharing_pnl PRIVATE crucible_common pthread)

# CI guard: assert >=2 movsd in worker_fn after each build. If the volatile
# store is ever elided, false sharing stops manifesting and all data is invalid.
add_custom_command(
    TARGET bench_02_false_sharing_pnl POST_BUILD
    COMMAND "${CMAKE_SOURCE_DIR}/scripts/check_volatile_codegen.sh"
            "$<TARGET_FILE:bench_02_false_sharing_pnl>"
    COMMENT "CI: assert >=2 movsd in worker_fn (volatile codegen guard)"
)
