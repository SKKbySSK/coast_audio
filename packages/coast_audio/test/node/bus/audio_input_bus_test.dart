import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:coast_audio/coast_audio.dart';

import 'audio_input_bus_test.mocks.dart';

@GenerateMocks([AudioNode])
void main() {
  group('AudioInputBus', () {
    final node1 = MockAudioNode();
    final node2 = MockAudioNode();
    const format = AudioFormat(channels: 2, sampleRate: 44100);

    setUp(() => reset(node1));

    test('connectedBus should return connected bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      expect(inputBus.connectedBus, isNull);

      final outputBus = AudioOutputBus(node: node2, formatResolver: (_) => format);
      outputBus.connect(inputBus);

      expect(inputBus.connectedBus, outputBus);

      outputBus.disconnect();
      expect(inputBus.connectedBus, isNull);
    });

    test('resolveFormat should return expected format', () {
      var inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      expect(inputBus.resolveFormat(), format);

      inputBus = AudioInputBus(node: node1, formatResolver: (_) => null);
      expect(inputBus.resolveFormat(), isNull);
    });

    group('autoFormat', () {
      test('resolveFormat should return null when disconnected', () {
        final inputBus = AudioInputBus.autoFormat(node: node1);
        expect(inputBus.resolveFormat(), isNull);
      });

      test('resolveFormat should return output bus format when connected', () {
        final outputBus = AudioOutputBus(node: node2, formatResolver: (_) => format);
        final inputBus = AudioInputBus.autoFormat(node: node1);
        outputBus.connect(inputBus);

        expect(inputBus.resolveFormat(), format);
      });
    });
  });
}
