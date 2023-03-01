cd src

ABIS=(armeabi-v7a arm64-v8a x86 x86_64)

for ABI in "${ABIS[@]}"
do
  mkdir -p build/android
  cd build/android

  cmake ../../.. \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM=26 \
    -DCMAKE_INSTALL_PREFIX="../../../build/android/$ABI" \
    -DOS=ANDROID
  
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..
  rm -rf build/android
done

# move to src/build
cd ../build

mkdir -p ../prebuilt/
cp -r android ../prebuilt/
