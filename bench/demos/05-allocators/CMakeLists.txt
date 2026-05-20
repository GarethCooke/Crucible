cmake_minimum_required(VERSION 3.20)

add_executable(bench_05_allocators benchmark.cpp)

target_include_directories(bench_05_allocators PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/allocators
)

target_link_libraries(bench_05_allocators PRIVATE
    crucible_common
    pthread
)

target_compile_options(bench_05_allocators PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
