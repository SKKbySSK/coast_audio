import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'bypass_node_mixin_test.mocks.dart';

class ProcessedReadResult extends AudioReadResult {
  const ProcessedReadResult() : super(frameCount: 0, isEnd: false);
}

class BypassedReadResult extends AudioReadResult {
  const BypassedReadResult() : super(frameCount: 0, isEnd: false);
}

class MockBypassNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin, ProcessorNodeMixin, BypassNodeMixin {
  MockBypassNode({required this.inputBus});

  @override
  final AudioInputBus inputBus;

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => null);

  @override
  AudioReadResult process(AudioBuffer buffer, bool isEnd) {
    return const ProcessedReadResult();
  }
}

@GenerateMocks([AudioBuffer, AudioInputBus, AudioOutputBus])
void main() {
  group('BypassNodeMixin', () {
    final inputBus = MockAudioInputBus();

    final outputBus = MockAudioOutputBus();
    when(outputBus.read(any)).thenReturn(const BypassedReadResult());
    when(inputBus.connectedBus).thenReturn(outputBus);

    test('read should return expected result when bypass is true', () {
      final node = MockBypassNode(inputBus: inputBus);
      node.bypass = true;

      final result = node.read(node.outputBus, MockAudioBuffer());
      expect(result, const BypassedReadResult());
    });

    test('read should return expected result when bypass is false', () {
      final node = MockBypassNode(inputBus: inputBus);
      node.bypass = false;

      final buffer = MockAudioBuffer();
      when(buffer.limit(any)).thenReturn(buffer);

      final result = node.read(node.outputBus, buffer);
      expect(result, const ProcessedReadResult());
    });
  });
}
