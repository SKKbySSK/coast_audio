cd src

PLATFORMS=(OS64 SIMULATORARM64 MAC_ARM64)

for PLATFORM in "${PLATFORMS[@]}"
do
  mkdir -p build/apple
  cd build/apple

  cmake ../../.. \
    -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../../../toolchain/ios.toolchain.cmake \
    -DPLATFORM="$PLATFORM" \
    -DENABLE_BITCODE=NO \
    -DENABLE_STRICT_TRY_COMPILE=YES \
    -DCMAKE_INSTALL_PREFIX="../../.." \
    -DOS=APPLE
  
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..
  rm -rf build/apple
done

# move to src/build/apple
cd ../
cd build/apple

rm -rf mabridge.xcframework
xcodebuild -create-xcframework \
  -framework "OS64/mabridge.framework" \
  -framework "SIMULATORARM64/mabridge.framework" \
  -framework "MAC_ARM64/mabridge.framework" \
  -output "mabridge.xcframework"

mkdir -p ../../prebuilt/apple/
cp -r "mabridge.xcframework" ../../prebuilt/apple
