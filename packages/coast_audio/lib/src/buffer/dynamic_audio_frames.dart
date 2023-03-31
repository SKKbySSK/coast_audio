import 'package:coast_audio/coast_audio.dart';

class DynamicAudioFrames extends AudioFrames implements SyncDisposable {
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

  bool requestFrames(
    int frames, {
    bool lazy = true,
    bool shrink = false,
  }) {
    throwIfNotAvailable();

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

    final lastBuffer = _internalBuffer;
    if (lastBuffer != null) {
      lastBuffer
        ..lock()
        ..unlock()
        ..dispose();
      _internalBuffer = null;
    }

    if (!lazy) {
      _internalBuffer = AllocatedAudioFrames(length: frames, format: format);
    }

    return true;
  }

  @override
  AudioBuffer lock() {
    throwIfNotAvailable();
    final lastBuffer = _internalBuffer ?? AllocatedAudioFrames(length: _sizeInFrames, format: format);
    _internalBuffer ??= lastBuffer;

    return lastBuffer.lock().limit(sizeInFrames);
  }

  @override
  void unlock() {
    throwIfNotAvailable();
    _internalBuffer?.unlock();
  }

  bool _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _internalBuffer?.dispose();
    _internalBuffer = null;
  }
}
