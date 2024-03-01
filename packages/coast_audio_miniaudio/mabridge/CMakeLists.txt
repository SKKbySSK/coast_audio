cmake_minimum_required(VERSION 3.25.2)
project(mabridge)

file(GLOB_RECURSE HEADER_FILES "src/*.h")
file(GLOB_RECURSE SOURCE_FILES "src/*.c")
list(APPEND SOURCE_FILES "tools/miniaudio_split/miniaudio.c")
list(APPEND SOURCE_FILES "modules/dart_sdk/runtime/include/dart_api_dl.c")

if ("${OS}" STREQUAL "APPLE")
  set(CMAKE_C_FLAGS "-x objective-c")
  set(CMAKE_SYSTEM_NAME "iOS")

  # fix: https://gitlab.kitware.com/cmake/cmake/-/issues/21636
  unset(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*])

  add_library(${PROJECT_NAME} STATIC ${HEADER_FILES} ${SOURCE_FILES})
elseif ("${OS}" MATCHES "(ANDROID|LINUX)")
  add_library(${PROJECT_NAME} SHARED ${HEADER_FILES} ${SOURCE_FILES})
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_include_directories(${PROJECT_NAME} PUBLIC ${HEADER_FILES})
target_include_directories(${PROJECT_NAME} PRIVATE "tools/miniaudio_split")
target_include_directories(${PROJECT_NAME} PRIVATE "modules/dart_sdk/runtime/include")
target_sources(${PROJECT_NAME} PRIVATE ${SOURCE_FILES})

set_target_properties(${PROJECT_NAME} PROPERTIES
  PUBLIC_HEADER "${HEADER_FILES}"
)

if ("${OS}" STREQUAL "APPLE")
  find_library(CORE_FOUNDATION CoreFoundation)
  find_library(AVFOUNDATION AVFoundation)
  find_library(AUDIO_TOOLBOX AudioToolbox)
  target_link_libraries(${PROJECT_NAME} ${CORE_FOUNDATION} ${AVFOUNDATION} ${AUDIO_TOOLBOX})

  set_target_properties(${PROJECT_NAME} PROPERTIES
    FRAMEWORK TRUE
  )

  install (TARGETS ${PROJECT_NAME}
    FRAMEWORK DESTINATION build/apple/${PLATFORM}
  )
elseif ("${OS}" MATCHES "(ANDROID|LINUX)")
  install (TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION .
  )
endif()
