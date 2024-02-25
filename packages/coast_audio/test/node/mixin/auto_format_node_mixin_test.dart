import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'auto_format_node_mixin_test.mocks.dart';

class MockAutoFormatNode extends AudioNode with AutoFormatNodeMixin {
  @override
  final List<AudioInputBus> inputs = [];

  @override
  final outputs = const <AudioOutputBus>[];

  @override
  AudioReadResult read(AudioOutputBus bus, AudioBuffer buffer) {
    throw UnimplementedError();
  }
}

@GenerateMocks([AudioOutputBus])
void main() {
  group('AutoFormatNodeMixin', () {
    final connectedBus = MockAudioOutputBus();
    final node = MockAutoFormatNode();

    final inputBus = AudioInputBus.autoFormat(node: node);
    node.inputs.add(inputBus);

    test('currentOutputFormat should return expected format', () {
      final format = AudioFormat(channels: 2, sampleRate: 44100);

      when(connectedBus.resolveFormat()).thenReturn(format);
      inputBus.onConnect(connectedBus);

      expect(node.currentOutputFormat, format);
    });

    test('currentOutputFormat should return null when the connected bus is also autoFormat', () {
      when(connectedBus.resolveFormat()).thenReturn(null);
      inputBus.onConnect(connectedBus);

      expect(node.currentOutputFormat, isNull);
    });

    test('currentOutputFormat should return null when disconnected', () {
      inputBus.onDisconnect();

      expect(node.currentOutputFormat, isNull);
    });
  });
}
