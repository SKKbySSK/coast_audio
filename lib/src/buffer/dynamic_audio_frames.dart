import 'package:coast_audio/coast_audio.dart';

/// An audio buffer that can be resized dynamically.
class DynamicAudioFrames extends AudioFrames with AudioResourceMixin {
  /// Creates a [DynamicAudioFrames].
  ///
  /// [initialFrameLength] is the initial length of the buffer.
  /// If [maxFrames] is not null, the buffer will not be resized larger than [maxFrames].
  /// [format] is the audio format of the buffer.
  DynamicAudioFrames({
    int initialFrameLength = 512,
    this.maxFrames,
    required this.format,
  })  : _sizeInFrames = initialFrameLength,
        _sizeInBytes = format.bytesPerFrame * initialFrameLength;

  final int? maxFrames;
  int _sizeInBytes;
  int _sizeInFrames;
  AllocatedAudioFrames? _internalBuffer;

  @override
  final AudioFormat format;

  @override
  int get sizeInBytes => _sizeInBytes;

  @override
  int get sizeInFrames => _sizeInFrames;

  /// Request the buffer size to be [frames].
  ///
  /// If [lazy] is true, the buffer will not be allocated until [lock] is called.
  /// If [shrink] is true, the buffer will not be reallocated if the requested size is smaller than the current size.
  bool requestFrames(
    int frames, {
    bool lazy = true,
    bool shrink = false,
  }) {
    if (maxFrames != null && frames > maxFrames!) {
      return false;
    }

    if (frames == _sizeInFrames) {
      return true;
    }

    _sizeInFrames = frames;
    _sizeInBytes = frames * format.bytesPerFrame;

    // If the requested frame count is less than sizeInFrames, reuse the last buffer.
    if (!shrink && frames < _sizeInFrames) {
      return true;
    }

    if (lazy) {
      _internalBuffer = null;
    } else {
      _internalBuffer = AllocatedAudioFrames(length: frames, format: format);
    }

    return true;
  }

  @override
  AudioBuffer lock() {
    final lastBuffer = _internalBuffer ?? AllocatedAudioFrames(length: _sizeInFrames, format: format);
    _internalBuffer ??= lastBuffer;

    return lastBuffer.lock().limit(sizeInFrames);
  }

  @override
  void unlock() {
    _internalBuffer?.unlock();
  }
}
