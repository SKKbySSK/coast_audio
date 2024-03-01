import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'processor_node_mixin_test.mocks.dart';

abstract class AudioProcessor {
  AudioReadResult process(AudioBuffer buffer, bool isEnd);
}

class MockProcessorNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin, ProcessorNodeMixin {
  MockProcessorNode({
    required this.processor,
    required this.inputBus,
  });

  final AudioProcessor processor;

  @override
  final AudioInputBus inputBus;

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => null);

  @override
  AudioReadResult process(AudioBuffer buffer, bool isEnd) {
    return processor.process(buffer, isEnd);
  }
}

@GenerateMocks([AudioBuffer, AudioInputBus, AudioOutputBus, AudioProcessor])
void main() {
  group('ProcessorNodeMixin', () {
    final inputBus = MockAudioInputBus();

    final outputBus = MockAudioOutputBus();
    when(inputBus.connectedBus).thenReturn(outputBus);

    final buffer = MockAudioBuffer();
    const bufferCapacity = 100;

    when(buffer.sizeInFrames).thenReturn(bufferCapacity);
    when(buffer.limit(any)).thenReturn(buffer);

    group('node.read should call node.process with correct parameters', () {
      final processor = MockAudioProcessor();
      final node = MockProcessorNode(
        processor: processor,
        inputBus: inputBus,
      );

      test('isEnd == false', () {
        final expectedResult = const AudioReadResult(frameCount: 10, isEnd: false);
        when(outputBus.read(any)).thenReturn(expectedResult);
        when(processor.process(buffer, false)).thenReturn(expectedResult);

        expect(node.read(node.outputBus, buffer), expectedResult);
        verify(processor.process(buffer, false)).called(1);
      });

      test('isEnd == true', () {
        final expectedResult = const AudioReadResult(frameCount: 10, isEnd: true);
        when(outputBus.read(any)).thenReturn(expectedResult);
        when(processor.process(buffer, true)).thenReturn(expectedResult);

        expect(node.read(node.outputBus, buffer), expectedResult);
        verify(processor.process(buffer, true)).called(1);
      });
    });
  });
}
