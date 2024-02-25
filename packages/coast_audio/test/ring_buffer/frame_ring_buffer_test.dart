import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('FrameRingBuffer', () {
    const format = AudioFormat(channels: 2, sampleRate: 44100);

    test('output == input', () {
      final frames = AllocatedAudioFrames(length: 100, format: format);
      final ringBuffer = FrameRingBuffer(capacity: 100, format: format);

      frames.acquireBuffer((buffer) {
        expect(ringBuffer.write(buffer), 100);
        expect(ringBuffer.read(buffer), 100);
      });
    });

    test('copyTo should copy ring buffer as much as possible', () {
      final frames = AllocatedAudioFrames(length: 100, format: format);
      final ringBuffer1 = FrameRingBuffer(capacity: 100, format: format);
      final ringBuffer2 = FrameRingBuffer(capacity: 100, format: format);

      frames.acquireBuffer((buffer) {
        expect(ringBuffer1.write(buffer), 100);
      });

      expect(ringBuffer1.copyTo(ringBuffer2, advance: false), 100);
      expect(ringBuffer1.length, 100);
      expect(ringBuffer2.length, 100);

      ringBuffer2.clear();

      expect(ringBuffer1.copyTo(ringBuffer2, advance: true), 100);
      expect(ringBuffer1.length, 0);
      expect(ringBuffer2.length, 100);
    });

    test('clear should reset length to 0', () {
      final frames = AllocatedAudioFrames(length: 100, format: format);
      final ringBuffer = FrameRingBuffer(capacity: 100, format: format);

      frames.acquireBuffer((buffer) {
        expect(ringBuffer.write(buffer), 100);
      });

      expect(ringBuffer.length, 100);

      ringBuffer.clear();
      expect(ringBuffer.length, 0);
    });

    test('dispose should change isDisposed flag', () {
      final ringBuffer = FrameRingBuffer(capacity: 300, format: format);
      expect(ringBuffer.isDisposed, isFalse);

      ringBuffer.dispose();
      expect(ringBuffer.isDisposed, isTrue);
    });
  });
}
