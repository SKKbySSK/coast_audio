import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph/src/ring_buffer.dart';

class FrameRingBuffer {
  FrameRingBuffer({
    required int frames,
    required AudioFormat format,
  }) : buffer = FrameBuffer.allocate(frames: frames, format: format) {
    ringBuffer = RingBuffer(
      capacity: buffer.sizeInBytes,
      pBuffer: buffer.pBuffer,
    );
  }

  final FrameBuffer buffer;
  late final RingBuffer ringBuffer;

  int get capacity => buffer.sizeInFrames;

  int get length => ringBuffer.length ~/ buffer.format.bytesPerFrame;

  int write(FrameBuffer buffer) {
    return ringBuffer.write(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  int read(FrameBuffer buffer) {
    return ringBuffer.read(buffer.pBuffer, 0, buffer.sizeInBytes) ~/ buffer.format.bytesPerFrame;
  }

  void dispose() {
    buffer.dispose();
  }
}
