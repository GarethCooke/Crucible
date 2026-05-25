include(FetchContent)
FetchContent_Declare(
  abseil-cpp
  GIT_REPOSITORY https://github.com/abseil/abseil-cpp.git
  GIT_TAG        20240722.0
  GIT_SHALLOW    TRUE
)
set(ABSL_ENABLE_INSTALL     OFF CACHE BOOL "" FORCE)
set(ABSL_PROPAGATE_CXX_STD  ON  CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(abseil-cpp)

# Boost: header-only, matching the pattern established in demos/04-spsc-queue
find_package(Boost 1.74 REQUIRED)

add_executable(stage2_07 stage2.cpp)

target_compile_features(stage2_07 PRIVATE cxx_std_20)

target_include_directories(stage2_07 PRIVATE ${Boost_INCLUDE_DIRS})

target_link_libraries(stage2_07 PRIVATE
    absl::flat_hash_map
    absl::hash
)

target_compile_options(stage2_07 PRIVATE
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Release>:-march=native>
)
