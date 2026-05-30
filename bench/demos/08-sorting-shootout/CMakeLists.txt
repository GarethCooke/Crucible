cmake_minimum_required(VERSION 3.20)

add_executable(bench_08_sorting_shootout benchmark.cpp)

target_compile_features(bench_08_sorting_shootout PRIVATE cxx_std_20)

target_include_directories(bench_08_sorting_shootout PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../common/third_party
)

target_link_libraries(bench_08_sorting_shootout PRIVATE crucible_common)

target_compile_options(bench_08_sorting_shootout PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
