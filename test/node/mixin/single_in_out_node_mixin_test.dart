import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class MockSingleInOutNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin {
  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => null);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => null);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    throw UnimplementedError();
  }
}

void main() {
  group('SingleInNodeMixin', () {
    test('outputs only contain outputBus', () {
      final node = MockSingleInOutNode();
      expect(node.outputs, [node.outputBus]);
    });

    test('inputs only contain inputBus', () {
      final node = MockSingleInOutNode();
      expect(node.inputs, [node.inputBus]);
    });
  });
}
