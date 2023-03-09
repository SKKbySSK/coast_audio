import 'package:coast_audio/coast_audio.dart';

class FrameRingBuffer extends SyncDisposable {
  FrameRingBuffer({
    required int frames,
    required AudioFormat format,
    Memory? memory,
  }) : _buffer = AllocatedFrameBuffer(
          frames: frames,
          format: format,
          fillZero: false,
          memory: memory,
        ) {
    _ringBuffer = RingBuffer(
      capacity: _buffer.sizeInBytes,
      pBuffer: _rawBuffer.pBuffer,
    );
  }

  final AllocatedFrameBuffer _buffer;
  late final RawFrameBuffer _rawBuffer = _buffer.lock();
  late final RingBuffer _ringBuffer;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  AudioFormat get format => _buffer.format;

  int get capacity => _buffer.sizeInFrames;

  int get length => _ringBuffer.length ~/ _buffer.format.bytesPerFrame;

  int write(RawFrameBuffer buffer) {
    return _ringBuffer.write(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int read(RawFrameBuffer buffer) {
    return _ringBuffer.read(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int peek(RawFrameBuffer buffer) {
    return _ringBuffer.peek(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
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
