import 'package:dart_audio_graph/dart_audio_graph.dart';

class FrameRingBuffer extends SyncDisposable {
  FrameRingBuffer({
    required int frames,
    required AudioFormat format,
  }) : _buffer = FrameBuffer.allocate(frames: frames, format: format) {
    _ringBuffer = RingBuffer(
      capacity: _buffer.sizeInBytes,
      pBuffer: _buffer.pBuffer,
    );
  }

  final FrameBuffer _buffer;
  late final RingBuffer _ringBuffer;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  AudioFormat get format => _buffer.format;

  int get capacity => _buffer.sizeInFrames;

  int get length => _ringBuffer.length ~/ _buffer.format.bytesPerFrame;

  int write(FrameBuffer buffer) {
    return _ringBuffer.write(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int read(FrameBuffer buffer) {
    return _ringBuffer.read(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int peek(FrameBuffer buffer) {
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
    _buffer.dispose();
  }
}
