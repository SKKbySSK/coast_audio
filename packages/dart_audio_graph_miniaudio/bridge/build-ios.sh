cd src

PLATFORMS=(SIMULATORARM64 OS64)

mkdir -p build/ios
cd build/ios

for PLATFORM in "${PLATFORMS[@]}"
do
  mkdir -p "../../../build/ios/$PLATFORM"
  cmake ../../.. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../../toolchain/ios.toolchain.cmake -DPLATFORM="$PLATFORM" -DENABLE_BITCODE=NO -DENABLE_STRICT_TRY_COMPILE=YES -DCMAKE_INSTALL_PREFIX=../../../
  cmake --build . --config Release
  cmake --install . --config Release
  cd ../..
  rm -rf build/ios
  mkdir -p build/ios
  cd build/ios
done

cd ../../..

rm -rf build/ios/mabridge.xcframework
xcodebuild -create-xcframework -framework "build/ios/OS64/mabridge.framework" -output build/ios/mabridge.xcframework
