import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class MockDataSourceNode extends DataSourceNode {
  MockDataSourceNode({this.outputFormat});

  @override
  final AudioFormat? outputFormat;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    throw UnimplementedError();
  }
}

void main() {
  group('DataSourceNode', () {
    test('outputBus.resolveFormat() should return node.outputFormat', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final node = MockDataSourceNode(outputFormat: format);
      expect(node.outputBus.resolveFormat(), format);
    });

    test('outputBus.resolveFormat() should return node.outputFormat', () {
      final node = MockDataSourceNode(outputFormat: null);
      expect(node.outputBus.resolveFormat(), isNull);
    });
  });
}
