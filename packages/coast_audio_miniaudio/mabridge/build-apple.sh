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

# move to build/apple
cd ../
cd build/apple

for PLATFORM in "${PLATFORMS[@]}"
do
  mkdir -p "$PLATFORM/mabridge.framework/Modules"
  cat > "$PLATFORM/mabridge.framework/Modules/module.modulemap" <<- EOM
framework module Mabridge {
    umbrella header "mabridge.h"
    export *
    module * { export * }
}
EOM
done

rm -rf mabridge.xcframework
xcodebuild -create-xcframework \
  -framework "OS64/mabridge.framework" \
  -framework "SIMULATORARM64/mabridge.framework" \
  -framework "MAC_ARM64/mabridge.framework" \
  -output "mabridge.xcframework"

mkdir -p ../../prebuilt/apple/
cp -r mabridge.xcframework ../../prebuilt/apple
cp -r mabridge.xcframework ../../../../flutter_coast_audio_miniaudio/ios/Frameworks/
cp -r mabridge.xcframework ../../../../flutter_coast_audio_miniaudio/macos/Frameworks/
