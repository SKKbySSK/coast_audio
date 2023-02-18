import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:test/test.dart';

void main() {
  group('frame buffer test', () {
    test('mono', () {
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      final buffer = AllocatedFrameBuffer(frames: 10, format: format);
      expect(buffer.sizeInFrames, 10);
      expect(buffer.sizeInBytes, 10 * 4);
      buffer.acquireBuffer((pBuffer) {
        buffer.acquireBufferOrigin((pBufferOrigin) {
          expect(pBuffer.address, pBufferOrigin.address);
        });
      });
      buffer.dispose();
    });

    test('stereo', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final buffer = AllocatedFrameBuffer(frames: 10, format: format);
      expect(buffer.sizeInFrames, 10);
      expect(buffer.sizeInBytes, 10 * 8);
      buffer.acquireBuffer((pBuffer) {
        buffer.acquireBufferOrigin((pBufferOrigin) {
          expect(pBuffer.address, pBufferOrigin.address);
        });
      });
      buffer.dispose();
    });

    test('add offset', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedFrameBuffer(frames: 10, format: format);
      var subBuffer = buffer.offset(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      subBuffer.acquireBuffer((pBuffer) {
        subBuffer.acquireBufferOrigin((pBufferOrigin) {
          expect(pBuffer.address, pBufferOrigin.address + 5 * 8);
        });
      });
      buffer.dispose();
    });

    test('set limit', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedFrameBuffer(frames: 10, format: format);
      var subBuffer = buffer.limit(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      subBuffer.acquireBuffer((pBuffer) {
        subBuffer.acquireBufferOrigin((pBufferOrigin) {
          expect(pBuffer.address, pBufferOrigin.address);
        });
      });
      buffer.dispose();
    });
  });
}
