add_executable(bench_01_branch_prediction benchmark.cpp)
target_link_libraries(bench_01_branch_prediction PRIVATE crucible_common)

# Belt-and-braces: the optimize() function attribute is supposed to handle
# this, but GCC has historically ignored it in some configurations. Adding
# the flag at TU scope ensures the hot loops stay scalar regardless.
target_compile_options(bench_01_branch_prediction PRIVATE
    -fno-tree-vectorize
)
