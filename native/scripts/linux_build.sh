#!/bin/bash

ARCHS=(aarch64 x86_64)

for ARCH in "${ARCHS[@]}"
do
  mkdir -p build/linux
  cd build/linux

  cmake ../.. \
    -DCMAKE_INSTALL_PREFIX="../../build/linux/$ARCH" \
    -DCMAKE_TOOLCHAIN_FILE="../../linux.$ARCH.toolchain.cmake" \
    -DOS=LINUX \
    -DSHARED=YES
  
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..

  mkdir -p prebuilt/linux/$ARCH
  cp "build/linux/libcoast_audio.so" prebuilt/linux/$ARCH/libcoast_audio.so

  rm -rf build/linux
done
