cd src

mkdir -p build/ios
cd build/ios

PLATFORMS=(OS64 SIMULATORARM64)
FRAMEWORKS=("-framework build/ios/OS64/mabridge.framework" "-framework build/ios/SIMULATORARM64/mabridge.framework")

for PLATFORM in "${PLATFORMS[@]}"
do
  rm -rf .
  mkdir -p "../../../build/ios/$PLATFORM"
  cmake ../../.. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../../toolchain/ios.toolchain.cmake -DPLATFORM="$PLATFORM" -DENABLE_BITCODE=NO -DENABLE_STRICT_TRY_COMPILE=YES -DCMAKE_INSTALL_PREFIX=../../../
  cmake --build . --config Release
  cmake --install . --config Release
done

cd ../../../

xcodebuild -create-xcframework $FRAMEWORKS -output build/ios/mabridge.xcframework
