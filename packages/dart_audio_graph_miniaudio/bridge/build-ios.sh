cd src

PLATFORMS=(OS64 SIMULATORARM64 MAC_ARM64)

for PLATFORM in "${PLATFORMS[@]}"
do
  mkdir -p build/ios
  cd build/ios

  cmake ../../.. \
    -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../../../toolchain/ios.toolchain.cmake \
    -DPLATFORM="$PLATFORM" \
    -DENABLE_BITCODE=NO \
    -DENABLE_STRICT_TRY_COMPILE=YES \
    -DCMAKE_INSTALL_PREFIX="../../.." \
    -DOS=IOS
  
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..
  rm -rf build/ios
done

# move to src/build/ios
cd ../
cd build/ios

rm -rf mabridge.xcframework
xcodebuild -create-xcframework \
  -framework "OS64/mabridge.framework" \
  -framework "SIMULATORARM64/mabridge.framework" \
  -framework "MAC_ARM64/mabridge.framework" \
  -output "mabridge.xcframework"
