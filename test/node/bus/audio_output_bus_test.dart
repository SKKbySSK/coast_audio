import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'audio_output_bus_test.mocks.dart';

@GenerateMocks([AudioNode, AudioBuffer])
void main() {
  group('AudioOutputBus', () {
    final node1 = MockAudioNode();
    final node2 = MockAudioNode();
    const format = AudioFormat(channels: 2, sampleRate: 44100);

    setUp(() => reset(node1));

    test('throw AudioBusConnectionException when connecting incompatible format bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node2, formatResolver: (_) => format.copyWith(channels: 1));

      expect(() => outputBus.connect(inputBus), throwsA(isA<AudioBusConnectionException>()));
    });

    test('throw AudioBusConnectionException when connecting same node bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);

      expect(() => outputBus.connect(inputBus), throwsA(isA<AudioBusConnectionException>()));
    });
    test('throw AudioBusConnectionException when connecting same node bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);

      expect(() => outputBus.connect(inputBus), throwsA(isA<AudioBusConnectionException>()));
    });

    test('canConnect should return false when testing incompatible format bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node2, formatResolver: (_) => format.copyWith(channels: 1));

      expect(outputBus.canConnect(inputBus), isFalse);
    });

    test('canConnect should return false when testing same node bus', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);

      expect(outputBus.canConnect(inputBus), isFalse);
    });

    test('canConnect should return true', () {
      final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
      final outputBus = AudioOutputBus(node: node2, formatResolver: (_) => format);

      expect(outputBus.canConnect(inputBus), isTrue);
    });

    test('connectedBus should return connected bus', () {
      final outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);
      expect(outputBus.connectedBus, isNull);

      final inputBus = AudioInputBus(node: node2, formatResolver: (_) => format);
      outputBus.connect(inputBus);

      expect(outputBus.connectedBus, inputBus);

      outputBus.disconnect();

      expect(outputBus.connectedBus, isNull);
    });

    test('resolveFormat should return expected format', () {
      var outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);
      expect(outputBus.resolveFormat(), format);

      outputBus = AudioOutputBus(node: node1, formatResolver: (_) => null);
      expect(outputBus.resolveFormat(), isNull);
    });

    test('read should return a result from the node', () {
      const result = AudioReadResult(frameCount: 100, isEnd: true);
      when(node1.read(any, any)).thenReturn(result);

      final outputBus = AudioOutputBus(node: node1, formatResolver: (_) => format);
      expect(outputBus.read(MockAudioBuffer()), result);
    });

    group('autoFormat', () {
      test('resolveFormat should return inputBus\'s format (null)', () {
        final inputBus = AudioInputBus(node: node1, formatResolver: (_) => null);
        final outputBus = AudioOutputBus.autoFormat(node: node1, inputBus: inputBus);

        expect(outputBus.resolveFormat(), isNull);
      });

      test('resolveFormat should return inputBus\'s format (not null)', () {
        final inputBus = AudioInputBus(node: node1, formatResolver: (_) => format);
        final outputBus = AudioOutputBus.autoFormat(node: node1, inputBus: inputBus);

        expect(outputBus.resolveFormat(), format);
      });
    });
  });

  group('AudioEndpointBus', () {
    test('connect should throw AudioEndpointBusConnectionError', () {
      final inputBus = AudioInputBus(node: MockAudioNode(), formatResolver: (_) => const AudioFormat(channels: 2, sampleRate: 44100));
      final outputBus = AudioEndpointBus(node: MockAudioNode(), formatResolver: (_) => const AudioFormat(channels: 2, sampleRate: 44100));

      expect(() => outputBus.connect(inputBus), throwsA(isA<AudioEndpointBusConnectionError>()));
    });

    test('canConnect should return false', () {
      final inputBus = AudioInputBus(node: MockAudioNode(), formatResolver: (_) => const AudioFormat(channels: 2, sampleRate: 44100));
      final outputBus = AudioEndpointBus(node: MockAudioNode(), formatResolver: (_) => const AudioFormat(channels: 2, sampleRate: 44100));

      expect(outputBus.canConnect(inputBus), isFalse);
    });
  });
}
