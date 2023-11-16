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
