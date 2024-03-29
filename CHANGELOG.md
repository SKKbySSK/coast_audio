## 1.0.0

- Bump Dart SDK version to 3.1.0.
- Fixed `FrameRingBuffer.copyTo()` returns number of bytes copied instead of number of frames copied.
- `MixerNode` now supports SampleFormat.int32 and SampleFormat.uint8.
- Add `AudioDeviceContext` and `AudioDevice` for device I/O which was previously in `coast_audio_miniaudio` package.
- Add `AudioFormatConverter` for audio format conversion.
- `coast_audio_miniaudio` and `flutter_coast_audio_miniaudio` packages are removed.
  - Theses packages are integrated into `coast_audio` package.

### Breaking Changes

- Removed `AudioGraph` and `AudioGraphBuilder`.
- Removed `CosineFunction`.
- AudioNode
  - `read` should return `AudioReadResult` instead of number of frames.
  - `SingleInOutNodeMixin` was replaced with `SingleInNodeMixin` and `SingleOutNodeMixin`.
  - Remove `EncoderNode` and `AutoFormatNodeMixin`.
  - Replace `GraphNode` with `AudioOutputBus.connect` and `AudioOutputBus.disconnect`.
  - Rename `GraphConnectionException` with `AudioBusConnectionException`.
- `AudioOutputBus.read` should return `AudioReadResult` instead of number of frames.
- Added `isEnd` argument on `AudioTask.onRead` callback.
- Removed `dispose` method from most of the classes. They will be disposed automatically when they are garbage collected.
  - `AudioFileDataSource.dispose` is renamed to `AudioFileDataSource.closeSync`.

## 0.0.5

- Fix WavAudioDecoder bugs on Linux.

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
