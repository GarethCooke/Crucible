add_executable(test_stats test_stats.cpp)
target_include_directories(test_stats PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../common)

# On macOS the default SDK symlink may point at a version newer than the
# installed clang supports.  Target the known-good 14.2 SDK explicitly.
if(APPLE AND NOT CMAKE_OSX_SYSROOT)
    set(CMAKE_OSX_SYSROOT
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.2.sdk
        CACHE PATH "macOS SDK" FORCE)
endif()

add_test(NAME test_stats COMMAND test_stats)
