import 'dart:ffi';
import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:test/test.dart';

void main() {
  group('function node', () {
    test('mono', () {
      final function = SineFunction();
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      final buffer = FrameBuffer.allocate(frames: 100, format: format);
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final framesRead = node.outputBus.read(buffer);
      expect(framesRead, 100);

      final arrayBuffer = buffer.pBuffer.cast<Float>().asTypedList(100);
      expect(arrayBuffer[0], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[10], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[20], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[50], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[99], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
    });

    test('stereo', () {
      final function = SineFunction();
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final buffer = FrameBuffer.allocate(frames: 100, format: format);
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final framesRead = node.outputBus.read(buffer);
      expect(framesRead, 100);

      final arrayBuffer = buffer.pBuffer.cast<Float>().asTypedList(100 * 2);
      expect(arrayBuffer[0], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[1], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[20], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[21], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[40], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[41], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[100], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[101], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[198], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
      expect(arrayBuffer[199], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
    });
  });
}
