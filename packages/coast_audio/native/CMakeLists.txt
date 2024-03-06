cmake_minimum_required(VERSION 3.25.2)
project(coast_audio)

if ("${OS}" STREQUAL "APPLE")
  set(CMAKE_C_FLAGS "-x objective-c")
endif()

add_library("miniaudio" STATIC "miniaudio/extras/miniaudio_split/miniaudio.c")

add_library(${PROJECT_NAME} SHARED "src/ca_device.c")
target_include_directories(${PROJECT_NAME} PRIVATE "miniaudio/extras/miniaudio_split")
target_link_libraries(${PROJECT_NAME} PUBLIC "miniaudio")

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

if ("${OS}" STREQUAL "APPLE")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO")
  set(CMAKE_XCODE_ATTRIBUTE_STRIP_INSTALLED_PRODUCT "NO")
  set(CMAKE_XCODE_ATTRIBUTE_STRIP_STYLE "non-global")
  
  find_library(CORE_FOUNDATION CoreFoundation)
  find_library(AVFOUNDATION AVFoundation)
  find_library(AUDIO_TOOLBOX AudioToolbox)
  target_link_libraries("miniaudio" PRIVATE ${CORE_FOUNDATION} ${AVFOUNDATION} ${AUDIO_TOOLBOX})

  set_target_properties(${PROJECT_NAME} PROPERTIES
    FRAMEWORK TRUE
  )

  install (TARGETS ${PROJECT_NAME}
    FRAMEWORK DESTINATION "prebuilt/apple/${PLATFORM}"
  )
elseif ("${OS}" STREQUAL "ANDROID")
  install (TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION .
  )
elseif ("${OS}" STREQUAL "LINUX")
  install (TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION .
  )
endif()
