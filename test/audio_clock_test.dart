import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioIntervalClock', () {
    test('behaves correctly', () async {
      final clock = AudioIntervalClock(AudioTime(20 / 1000));

      var count = 0;
      clock.start(
        onTick: (_) {
          count++;
        },
      );
      expect(clock.isStarted, isTrue);

      await Future.delayed(Duration(milliseconds: 50));
      clock.stop();
      expect(count, 2);
      expect(clock.isStarted, isFalse);
      expect(clock.elapsedTime >= AudioTime(0.04), isTrue);

      clock.reset();
      expect(clock.elapsedTime, AudioTime.zero);
    });
  });

  group('AudioLoopClock', () {
    test('start should invoke callbacks until the stop is called', () async {
      final clock = AudioLoopClock();

      var count = 0;
      clock.start(
        onTick: (_) {
          count++;
          if (count == 100) {
            clock.stop();
          }
        },
      );

      // the clock stops here because the callback stops it
      expect(clock.isStarted, isFalse);

      expect(count, 100);
      expect(clock.elapsedTime > AudioTime.zero, isTrue);
    });

    test('reset should reset elapsed time', () async {
      final clock = AudioLoopClock();

      var count = 0;
      clock.start(
        onTick: (_) {
          count++;
          if (count == 100) {
            clock.stop();
          }
        },
      );

      clock.reset();
      expect(clock.elapsedTime, AudioTime.zero);
    });
  });
}
