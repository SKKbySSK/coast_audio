import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionNode', () {
    test('[uint8] should return correct value', () {
      final function = OffsetFunction(1);
      final format = AudioFormat(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.uint8);
      final buffer = AllocatedAudioFrames(length: 100, format: format).lock();
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final list = buffer.asUint8ListViewFrames();

      node.outputBus.read(buffer);
      expect(list.every((e) => SampleFormat.uint8.max == e), isTrue);

      function.offset = -1;
      node.outputBus.read(buffer);
      expect(list.every((e) => SampleFormat.uint8.min == e), isTrue);
    });

    test('[int16] should return correct value', () {
      final function = OffsetFunction(1);
      final format = AudioFormat(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.int16);
      final buffer = AllocatedAudioFrames(length: 100, format: format).lock();
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final list = buffer.asInt16ListView();

      node.outputBus.read(buffer);
      expect(list.every((e) => SampleFormat.int16.max.toInt() == e.toInt()), isTrue);

      function.offset = -1;
      node.outputBus.read(buffer);
      expect(list.every((e) => -SampleFormat.int16.max.toInt() == e.toInt()), isTrue);
    });

    test('[int32] should return correct value', () {
      final function = OffsetFunction(1);
      final format = AudioFormat(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.int32);
      final buffer = AllocatedAudioFrames(length: 100, format: format).lock();
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final list = buffer.asInt32ListView();

      node.outputBus.read(buffer);
      expect(list.every((e) => SampleFormat.int32.max.toInt() == e.toInt()), isTrue);

      function.offset = -1;
      node.outputBus.read(buffer);
      expect(list.every((e) => -SampleFormat.int32.max.toInt() == e.toInt()), isTrue);
    });

    test('[float32] should return correct value', () {
      final function = OffsetFunction(1);
      final format = AudioFormat(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.float32);
      final buffer = AllocatedAudioFrames(length: 100, format: format).lock();
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final list = buffer.asFloat32ListView();

      node.outputBus.read(buffer);
      expect(list.every((e) => SampleFormat.float32.max == e), isTrue);

      function.offset = -1;
      node.outputBus.read(buffer);
      expect(list.every((e) => -SampleFormat.float32.max == e), isTrue);
    });
  });
}
