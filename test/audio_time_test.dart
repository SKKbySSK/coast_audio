import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioTime', () {
    group('AudioTime.fromFrames', () {
      test('mono', () {
        final format = AudioFormat(sampleRate: 48000, channels: 1);
        final time = AudioTime.fromFrames(1, format: format);
        expect(time.seconds, 1 / 48000);
      });

      test('stereo', () {
        final format = AudioFormat(sampleRate: 48000, channels: 2);
        final time = AudioTime.fromFrames(1, format: format);
        expect(time.seconds, 1 / 48000);
      });
    });

    test('AudioTime.fromDuration should return correct time', () {
      final durationUs = 1234567;
      final duration = Duration(microseconds: durationUs);
      final time = AudioTime.fromDuration(duration);
      expect(time.seconds, durationUs / Duration.microsecondsPerSecond);
    });

    test('AudioTime.fromDuration should return correct time', () {
      final durationUs = 1234567;
      final duration = Duration(microseconds: durationUs);
      final time = AudioTime.fromDuration(duration);
      expect(time.seconds, durationUs / Duration.microsecondsPerSecond);
    });

    test('AudioTime operators should return correct results', () {
      final time1 = AudioTime(1);
      final time2 = AudioTime(2);
      final time3 = AudioTime(1);
      expect(time1 + time2, AudioTime(3));
      expect(time1 - time2, AudioTime(-1));
      expect(time1 * time2, AudioTime(2));
      expect(time1 / time2, AudioTime(0.5));
      expect(time1 > time2, isFalse);
      expect(time1 < time2, isTrue);
      expect(time1 >= time2, isFalse);
      expect(time1 <= time2, isTrue);
      expect(time1 <= time3, isTrue);
      expect(time1 >= time3, isTrue);
      expect(time1 == time2, isFalse);
      expect(time1 == time3, isTrue);
      expect(time1.hashCode == time3.hashCode, isTrue);
    });

    test('AudioTime format should return correct results', () {
      final time1 = AudioTime(1);
      final time2 = AudioTime(3600);
      final time3 = AudioTime(3600 * 100);
      expect(time1.formatMMSS(), '00:01');
      expect(time1.formatHHMMSS(), '00:00:01');
      expect(time2.formatMMSS(), '60:00');
      expect(time2.formatHHMMSS(), '01:00:00');
      expect(time3.formatMMSS(), '6000:00');
      expect(time3.formatHHMMSS(), '100:00:00');
    });
  });
}
