# mabridge
`mabridge` is a bridging library of miniaudio.

Basically, audio I/O requires low latency computations.\
If the latency is too high, output audio will be stuttering.

So, I decided to implement low latency parts in this library.

# Manual Setup

You can manually build the `mabridge` library by following steps.

## Prerequisites
- `cmake` >= 3.25.2

### iOS
- Xcode
  - Tested on Xcode 14.1

### Android
- Android NDK
  - Tested on 25.1.8937393
- direnv

## iOS/macOS
On iOS and macOS, you can use `build-apple.sh` script to build the xcframework.\
It will build iOS, iOS Simulator and macOS frameworks for Apple Silicon devices.

## Android
### NDK Setup
Add an `.envrc` file in the `mabridge` directory and write this line.
```
export ANDROID_NDK=/Users/gimo/Library/Android/sdk/ndk/25.1.8937393
```

Then, run the `direnv allow` command to load an NDK path.

### Build
`build-android.sh` will build shared libraries on all supported ABIs.
