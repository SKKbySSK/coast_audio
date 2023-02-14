import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:test/test.dart';

void main() {
  group('frame buffer test', () {
    test('mono', () {
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      final buffer = FrameBuffer.allocate(frames: 10, format: format);
      expect(buffer.sizeInFrames, 10);
      expect(buffer.sizeInBytes, 10 * 4);
      expect(buffer.pBuffer.address, buffer.pBufferOrigin.address);
      buffer.dispose();
    });

    test('stereo', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final buffer = FrameBuffer.allocate(frames: 10, format: format);
      expect(buffer.sizeInFrames, 10);
      expect(buffer.sizeInBytes, 10 * 8);
      expect(buffer.pBuffer.address, buffer.pBufferOrigin.address);
      buffer.dispose();
    });

    test('add offset', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = FrameBuffer.allocate(frames: 10, format: format);
      buffer = buffer.offset(5);
      expect(buffer.sizeInFrames, 5);
      expect(buffer.sizeInBytes, 5 * 8);
      expect(buffer.pBuffer.address, buffer.pBufferOrigin.address + 5 * 8);
      buffer.dispose();
    });

    test('set limit', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = FrameBuffer.allocate(frames: 10, format: format);
      buffer = buffer.limit(5);
      expect(buffer.sizeInFrames, 5);
      expect(buffer.sizeInBytes, 5 * 8);
      expect(buffer.pBuffer.address, buffer.pBufferOrigin.address);
      buffer.dispose();
    });
  });
}
