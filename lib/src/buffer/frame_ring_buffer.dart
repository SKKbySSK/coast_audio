import 'package:coast_audio/coast_audio.dart';

class FrameRingBuffer {
  FrameRingBuffer({
    required this.capacity,
    required this.format,
    Memory? memory,
  }) : _ringBuffer = RingBuffer(
          capacity: format.bytesPerFrame * capacity,
          memory: memory,
        );

  late final RingBuffer _ringBuffer;

  final AudioFormat format;

  final int capacity;

  int get length => _ringBuffer.length ~/ format.bytesPerFrame;

  int write(AudioBuffer buffer) {
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.write(buffer.pBuffer.cast(), 0, buffer.sizeInBytes) ~/ format.bytesPerFrame;
  }

  int read(AudioBuffer buffer, {bool advance = true}) {
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.read(buffer.pBuffer.cast(), 0, buffer.sizeInBytes, advance: advance) ~/ format.bytesPerFrame;
  }

  int copyTo(FrameRingBuffer buffer, {required bool advance}) {
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.copyTo(buffer._ringBuffer, advance: advance) ~/ format.bytesPerFrame;
  }

  void clear() {
    _ringBuffer.clear();
  }
}
