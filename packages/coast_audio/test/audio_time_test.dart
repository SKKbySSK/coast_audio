import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('calculate time from frames', () {
    test('mono', () {
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      final time = AudioTime.fromFrames(frames: 1, format: format);
      expect(time.seconds, 1 / 48000);
    });

    test('stereo', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final time = AudioTime.fromFrames(frames: 1, format: format);
      expect(time.seconds, 1 / 48000);
    });
  });
}
