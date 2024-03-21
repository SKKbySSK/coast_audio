import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('OffsetFunction', () {
    test('should return offset value', () {
      final function = OffsetFunction(1.0);
      expect(function.compute(AudioTime.zero), 1.0);

      function.offset = 0;
      expect(function.compute(AudioTime(1)), 0);

      function.offset = -1;
      expect(function.compute(AudioTime(2)), -1);
    });
  });
}
