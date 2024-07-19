cmake_minimum_required(VERSION 3.9.0)
project(CP VERSION 0.1.0)
project(my-project LANGUAGES CXX)

set(TARGET_NAME main)


add_executable(${TARGET_NAME} main.cc)

set(HEADER_FILES ${CMAKE_SOURCE_DIR}/cxx-prettyprint/ ${CMAKE_SOURCE_DIR}/)
target_include_directories(${TARGET_NAME} PRIVATE ${HEADER_FILES})
# target_link_libraries(${TARGET_NAME} -lgmp)

target_compile_features(${TARGET_NAME} PRIVATE cxx_std_17)

set(CMAKE_BUILD_TYPE "Debug")

# Add flag -fpermissive
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpermissive")


add_custom_target(
        clangformat
        COMMAND /usr/bin/clang-format
        -i
        ../main.cc
)