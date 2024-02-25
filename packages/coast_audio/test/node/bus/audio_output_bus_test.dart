import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:coast_audio/coast_audio.dart';

import 'audio_output_bus_test.mocks.dart';

@GenerateMocks([AudioNode, AudioInputBus, AudioBuffer])
void main() {
  group('AudioOutputBus', () {
    final node = MockAudioNode();
    const format = AudioFormat(channels: 2, sampleRate: 44100);

    setUp(() => reset(node));

    test('connectedBus should return connected bus', () {
      final outputBus = AudioOutputBus(node: node, formatResolver: (_) => format);
      expect(outputBus.connectedBus, isNull);

      final inputBus = MockAudioInputBus();
      outputBus.onConnect(inputBus);

      expect(outputBus.connectedBus, inputBus);

      outputBus.onDisconnect();
      expect(outputBus.connectedBus, isNull);
    });

    test('resolveFormat should return expected format', () {
      var outputBus = AudioOutputBus(node: node, formatResolver: (_) => format);
      expect(outputBus.resolveFormat(), format);

      outputBus = AudioOutputBus(node: node, formatResolver: (_) => null);
      expect(outputBus.resolveFormat(), isNull);
    });

    test('read should return a result from the node', () {
      const result = AudioReadResult(frameCount: 100, isEnd: true);
      when(node.read(any, any)).thenReturn(result);

      final outputBus = AudioOutputBus(node: node, formatResolver: (_) => format);
      expect(outputBus.read(MockAudioBuffer()), result);
    });
  });
}
