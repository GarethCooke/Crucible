cmake_minimum_required(VERSION 3.20)

add_executable(bench_quantum_classical_baseline benchmark.cpp)

target_compile_features(bench_quantum_classical_baseline PRIVATE cxx_std_20)

target_include_directories(bench_quantum_classical_baseline PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(bench_quantum_classical_baseline PRIVATE crucible_common)

target_compile_options(bench_quantum_classical_baseline PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
