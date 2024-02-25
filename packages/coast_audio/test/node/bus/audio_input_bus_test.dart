import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:coast_audio/coast_audio.dart';

import 'audio_input_bus_test.mocks.dart';

@GenerateMocks([AudioNode, AudioOutputBus])
void main() {
  group('AudioInputBus', () {
    final node = MockAudioNode();
    const format = AudioFormat(channels: 2, sampleRate: 44100);

    setUp(() => reset(node));

    test('connectedBus should return connected bus', () {
      final inputBus = AudioInputBus(node: node, formatResolver: (_) => format);
      expect(inputBus.connectedBus, isNull);

      final outputBus = MockAudioOutputBus();
      inputBus.onConnect(outputBus);

      expect(inputBus.connectedBus, outputBus);

      inputBus.onDisconnect();
      expect(inputBus.connectedBus, isNull);
    });

    test('resolveFormat should return expected format', () {
      var inputBus = AudioInputBus(node: node, formatResolver: (_) => format);
      expect(inputBus.resolveFormat(), format);

      inputBus = AudioInputBus(node: node, formatResolver: (_) => null);
      expect(inputBus.resolveFormat(), isNull);
    });

    group('autoFormat', () {
      test('resolveFormat should return null when disconnected', () {
        final inputBus = AudioInputBus.autoFormat(node: node);
        expect(inputBus.resolveFormat(), isNull);
      });

      test('resolveFormat should return output bus format when connected', () {
        final outputBus = MockAudioOutputBus();
        when(outputBus.resolveFormat()).thenReturn(format);

        final inputBus = AudioInputBus.autoFormat(node: node);
        inputBus.onConnect(outputBus);

        expect(inputBus.resolveFormat(), format);
      });
    });
  });
}
