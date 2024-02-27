import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('frame calculation', () {
    test('mono', () {
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      expect(format.bytesPerFrame, 4);
    });

    test('stereo', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      expect(format.bytesPerFrame, 8);
    });
  });
}
