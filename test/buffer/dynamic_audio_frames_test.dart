import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('DynamicAudioFrames', () {
    test('sizeInFrames and sizeInBytes should return correct result (lazy: true)', () {
      const format = AudioFormat(sampleRate: 48000, channels: 2);
      final frames = DynamicAudioFrames(format: format, initialFrameLength: 10);

      expect(frames.sizeInFrames, 10);
      expect(frames.sizeInBytes, 10 * format.bytesPerFrame);

      frames.acquireBuffer((buffer) {
        expect(buffer.sizeInFrames, 10);
        expect(buffer.sizeInBytes, 10 * format.bytesPerFrame);
      });

      expect(frames.requestFrames(20, lazy: true), isTrue);
      expect(frames.sizeInFrames, 20);
      expect(frames.sizeInBytes, 20 * format.bytesPerFrame);

      frames.acquireBuffer((buffer) {
        expect(buffer.sizeInFrames, 20);
        expect(buffer.sizeInBytes, 20 * format.bytesPerFrame);
      });
    });

    test('sizeInFrames and sizeInBytes should return correct result (lazy: false)', () {
      const format = AudioFormat(sampleRate: 48000, channels: 2);
      final frames = DynamicAudioFrames(format: format, initialFrameLength: 10);

      expect(frames.sizeInFrames, 10);
      expect(frames.sizeInBytes, 10 * format.bytesPerFrame);

      frames.acquireBuffer((buffer) {
        expect(buffer.sizeInFrames, 10);
        expect(buffer.sizeInBytes, 10 * format.bytesPerFrame);
      });

      expect(frames.requestFrames(20, lazy: false), isTrue);
      expect(frames.sizeInFrames, 20);
      expect(frames.sizeInBytes, 20 * format.bytesPerFrame);

      frames.acquireBuffer((buffer) {
        expect(buffer.sizeInFrames, 20);
        expect(buffer.sizeInBytes, 20 * format.bytesPerFrame);
      });
    });

    test('requestFrames should return false when exceeds maxFrames', () {
      const format = AudioFormat(sampleRate: 48000, channels: 2);
      final frames = DynamicAudioFrames(format: format, initialFrameLength: 10, maxFrames: 20);

      expect(frames.requestFrames(30), isFalse);
      expect(frames.sizeInFrames, 10);
      expect(frames.sizeInBytes, 10 * format.bytesPerFrame);
    });
  });
}
