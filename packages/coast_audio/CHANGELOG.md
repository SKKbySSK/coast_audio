## TODO

- Bump Dart SDK version to 3.1.0.
- Add `AudioFilterNode` which can be used to apply filters easily.
- Fixed `FrameRingBuffer.copyTo()` returns number of bytes copied instead of number of frames copied.
- `RingBuffer` and `FrameRingBuffer` will be disposed automatically when they are no longer used.
- `MixerNode` now supports multiple SampleFormat.int32 and SampleFormat.uint8.

### Breaking Changes

- Removed `AudioGraph` and `AudioGraphBuilder`.
- Removed `CosineFunction`.
- AudioNode
  - `read` should return `AudioReadResult` instead of number of frames.
  - `SingleInOutNodeMixin` was replaced with `SingleInNodeMixin` and `SingleOutNodeMixin`.
  - Remove `EncoderNode` and `AutoFormatNodeMixin`.
  - Replace `GraphNode` with `AudioOutputBus.connect` and `AudioOutputBus.disconnect`.
  - Rename `GraphConnectionException` with `AudioBusConnectionException`.
- AudioOutputBus
  - `read` should return `AudioReadResult` instead of number of frames.

## 0.0.4

- Improve RingBuffer and FrameRingBuffer performance.
- Improve FfiMemory performance.
- Add documentation.

### Breaking Changes

- Set minimum Dart language version to 3.0.0.
- Remove offset and count parameters from AudioInputDataSource.readBytes and AudioOutputDataSource.writeBytes.
- Replace seek method with position property in AudioInputDataSource and AudioOutputDataSource.
- Remove SeekOrigin.

## 0.0.3

- Tweak AudioDecoder API.
- Remove some classes.

## 0.0.2

- Rename AudioFrameBuffer to AudioFrames
- Rename RawAudioBuffer to AudioBuffer
- Rename IntervalAudioClock to AudioIntervalClock
- Add AudioGraph and AudioGraphBuilder

## 0.0.1

- Initial version.
