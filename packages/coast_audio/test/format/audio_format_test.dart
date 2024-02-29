import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioFormat', () {
    test('bytesPerFrame should return correct value on mono and stereo', () {
      expect(const AudioFormat(sampleRate: 48000, channels: 1).bytesPerFrame, 4);
      expect(const AudioFormat(sampleRate: 48000, channels: 2).bytesPerFrame, 8);
    });

    for (final sampleFormat in SampleFormat.values) {
      test('bytesPerFrame should return correct value on ${sampleFormat.name}', () {
        expect(
          AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: sampleFormat).bytesPerFrame,
          sampleFormat.size * 2,
        );
      });
    }
  });
}
