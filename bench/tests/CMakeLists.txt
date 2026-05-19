add_executable(test_stats test_stats.cpp)
target_include_directories(test_stats PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../common)

if(APPLE)
    execute_process(
        COMMAND xcrun --show-sdk-path
        OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

add_test(NAME test_stats COMMAND test_stats)
