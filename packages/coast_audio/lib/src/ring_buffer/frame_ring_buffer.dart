import 'package:coast_audio/coast_audio.dart';

class FrameRingBuffer extends SyncDisposable {
  FrameRingBuffer({
    required int frames,
    required AudioFormat format,
    Memory? memory,
  }) : _buffer = AllocatedAudioFrames(
          length: frames,
          format: format,
          fillZero: false,
          memory: memory,
        ) {
    _ringBuffer = RingBuffer(
      capacity: _buffer.sizeInBytes,
      pBuffer: _rawBuffer.pBuffer.cast(),
    );
  }

  final AllocatedAudioFrames _buffer;
  late final AudioBuffer _rawBuffer = _buffer.lock();
  late final RingBuffer _ringBuffer;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  AudioFormat get format => _buffer.format;

  int get capacity => _buffer.sizeInFrames;

  int get length => _ringBuffer.length ~/ _buffer.format.bytesPerFrame;

  int write(AudioBuffer buffer) {
    return _ringBuffer.write(buffer.pBuffer.cast(), 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int read(AudioBuffer buffer, {bool advance = true}) {
    return _ringBuffer.read(buffer.pBuffer.cast(), 0, buffer.sizeInBytes, advance: advance) ~/ buffer.format.bytesPerFrame;
  }

  int copyTo(FrameRingBuffer buffer, {required bool advance}) {
    return _ringBuffer.copyTo(buffer._ringBuffer, advance: advance);
  }

  void clear() {
    _ringBuffer.clear();
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _buffer
      ..unlock()
      ..dispose();
  }
}
