# Demo 02: false-sharing P&L accumulators
# Brief spec: -O2 (not the root -O3), no LTO, no -ffast-math.
# On GCC the last -O flag wins, so -O2 here overrides the root -O3.
add_executable(bench_02_false_sharing_pnl false_sharing_pnl.cpp)
target_link_libraries(bench_02_false_sharing_pnl PRIVATE crucible_common pthread)
target_compile_options(bench_02_false_sharing_pnl PRIVATE
  $<$<CONFIG:Release>:-O2>)
