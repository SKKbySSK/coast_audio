cmake_minimum_required(VERSION 3.25.2)
project(mabridge)
set(CMAKE_C_FLAGS "-x objective-c")
set(CMAKE_SYSTEM_NAME "iOS")

# fix: https://gitlab.kitware.com/cmake/cmake/-/issues/21636
unset(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*])

file(GLOB_RECURSE HEADER_FILES "src/*.h")
file(GLOB_RECURSE SOURCE_FILES "src/*.c")

add_library(${PROJECT_NAME} STATIC ${HEADER_FILES} ${HEADER_FILES})

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_include_directories(${PROJECT_NAME} PUBLIC ${HEADER_FILES})
target_include_directories(${PROJECT_NAME} PRIVATE "modules/miniaudio")
target_sources(${PROJECT_NAME} PRIVATE ${SOURCE_FILES}  "modules/miniaudio/miniaudio.h")

find_library(AVFOUNDATION AVFoundation)
find_library(AUDIO_TOOLBOX AudioToolbox)
target_link_libraries(${PROJECT_NAME} ${AVFOUNDATION} ${AUDIO_TOOLBOX})

set_target_properties(${PROJECT_NAME} PROPERTIES
  FRAMEWORK TRUE
  PUBLIC_HEADER "${HEADER_FILES}"
)

install (TARGETS ${PROJECT_NAME}
  FRAMEWORK DESTINATION build/ios/${PLATFORM}
)
