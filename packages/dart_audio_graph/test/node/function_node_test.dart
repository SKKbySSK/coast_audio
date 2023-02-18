import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:test/test.dart';

void main() {
  group('function node', () {
    test('mono', () {
      final function = SineFunction();
      final format = AudioFormat(sampleRate: 48000, channels: 1);
      final buffer = AllocatedFrameBuffer(frames: 100, format: format);
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final framesRead = node.outputBus.read(buffer);
      expect(framesRead, 100);

      buffer.acquireFloatListView(
        (list) {
          expect(list[0], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
          expect(list[10], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
          expect(list[20], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
          expect(list[50], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
          expect(list[99], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
        },
        frames: 100,
      );
    });

    test('stereo', () {
      final function = SineFunction();
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final buffer = AllocatedFrameBuffer(frames: 100, format: format);
      final node = FunctionNode(
        function: function,
        frequency: 440,
        format: format,
      );

      final framesRead = node.outputBus.read(buffer);
      expect(framesRead, 100);

      buffer.acquireFloatListView(
        (list) {
          expect(list[0], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
          expect(list[1], closeTo(sin(2 * pi * 440 * (0 / format.sampleRate)), 0.000001));
          expect(list[20], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
          expect(list[21], closeTo(sin(2 * pi * 440 * (10 / format.sampleRate)), 0.000001));
          expect(list[40], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
          expect(list[41], closeTo(sin(2 * pi * 440 * (20 / format.sampleRate)), 0.000001));
          expect(list[100], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
          expect(list[101], closeTo(sin(2 * pi * 440 * (50 / format.sampleRate)), 0.000001));
          expect(list[198], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
          expect(list[199], closeTo(sin(2 * pi * 440 * (99 / format.sampleRate)), 0.000001));
        },
        frames: 100,
      );
    });
  });
}
