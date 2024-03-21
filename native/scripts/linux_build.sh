ARCHS=(aarch64 x86_64)

for ARCH in "${ARCHS[@]}"
do
  mkdir -p build/linux
  cd build/linux

  cmake ../.. \
    -DCMAKE_SYSTEM_PROCESSOR="$ARCH" \
    -DCMAKE_INSTALL_PREFIX="../../build/linux/$ARCH" \
    -DOS=LINUX
  
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..

  mkdir -p prebuilt/linux/$ARCH
  cp "build/linux/libcoast_audio.dylib" prebuilt/linux/$ARCH/libcoast_audio.dylib

  rm -rf build/linux
done
