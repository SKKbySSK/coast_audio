import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('SquareFunction', () {
    test('should return square value', () {
      const function = SquareFunction();
      expect(function.compute(AudioTime.zero), 1.0);
      expect(function.compute(AudioTime(0.25)), 1.0);
      expect(function.compute(AudioTime(0.5)), 1.0);
      expect(function.compute(AudioTime(0.75)), -1.0);
      expect(function.compute(AudioTime(1)), 1.0);
    });
  });
}
