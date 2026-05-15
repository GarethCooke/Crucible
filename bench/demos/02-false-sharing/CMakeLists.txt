# Demo 02: false-sharing P&L accumulators
# -O3 matches the documented standard (-march=native set by root CMakeLists).
# The volatile qualifier on Strategy::pnl forces a memory store per fill even
# at -O3, so the false-sharing effect is not elided by the optimiser.
add_executable(bench_02_false_sharing_pnl false_sharing_pnl.cpp)
target_link_libraries(bench_02_false_sharing_pnl PRIVATE crucible_common pthread)

# CI guard: verify worker_fn still contains >= 2 movsd instructions after
# compilation. If volatile double is ever optimised away the false-sharing
# effect collapses and every result becomes meaningless. Build fails if absent.
if(UNIX)
    add_custom_command(
        TARGET bench_02_false_sharing_pnl POST_BUILD
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/check_codegen.sh
                $<TARGET_FILE:bench_02_false_sharing_pnl>
        COMMENT "Checking worker_fn volatile movsd codegen"
    )
endif()
