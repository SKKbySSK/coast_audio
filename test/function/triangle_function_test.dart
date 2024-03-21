import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('TriangleFunction', () {
    test('should return triangle value', () {
      const function = TriangleFunction();
      expect(function.compute(AudioTime.zero), 1.0);
      expect(function.compute(AudioTime(0.25)), closeTo(0.0, 0.001));
      expect(function.compute(AudioTime(0.5)), closeTo(-1.0, 0.001));
      expect(function.compute(AudioTime(0.75)), closeTo(0.0, 0.001));
      expect(function.compute(AudioTime(1)), 1.0);
    });
  });
}
