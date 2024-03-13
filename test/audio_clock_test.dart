import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioIntervalClock', () {
    test('behaves correctly', () async {
      final clock = AudioIntervalClock(Duration(milliseconds: 20));

      var count = 0;
      clock.callbacks.add((_) {
        count++;
      });

      clock.start();
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
      clock.callbacks.add((_) {
        count++;
        if (count == 100) {
          clock.stop();
        }
      });
      clock.start();

      // the clock stops here because the callback stops it
      expect(clock.isStarted, isFalse);

      expect(count, 100);
      expect(clock.elapsedTime > AudioTime.zero, isTrue);
    });

    test('start should throw an exception when there is no callback', () async {
      final clock = AudioLoopClock();
      expect(() => clock.start(), throwsA(isA<AssertionError>()));

      var count = 0;
      clock.callbacks.add((_) {
        count++;
        if (count == 100) {
          clock.callbacks.clear();
        }
      });

      expect(() => clock.start(), throwsA(isA<ConcurrentModificationError>()));
      expect(count, 100);
    });

    test('reset should reset elapsed time', () async {
      final clock = AudioLoopClock();

      var count = 0;
      clock.callbacks.add((_) {
        count++;
        if (count == 100) {
          clock.stop();
        }
      });
      clock.start();
      clock.reset();
      expect(clock.elapsedTime, AudioTime.zero);
    });
  });
}
