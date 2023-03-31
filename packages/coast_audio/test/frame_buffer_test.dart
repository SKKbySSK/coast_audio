import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('frame buffer test', () {
    test('add offset', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedAudioFrames(frames: 10, format: format).lock();
      var subBuffer = buffer.offset(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      expect(subBuffer.pBuffer.address, buffer.pBuffer.address + 5 * 8);
    });

    test('set limit', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedAudioFrames(frames: 10, format: format).lock();
      var subBuffer = buffer.limit(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      expect(subBuffer.pBuffer.address, buffer.pBuffer.address);
    });
  });
}
