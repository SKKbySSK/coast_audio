import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class _DurationNode extends AudioNode with SingleOutNodeMixin {
  _DurationNode({
    required this.duration,
    required this.node,
  });
  final AudioTime duration;
  final SingleOutNodeMixin node;

  var current = AudioTime.zero;

  @override
  List<AudioInputBus> get inputs => [];

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => node.outputBus.resolveFormat());

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final leftFrameCount = (duration - current).computeFrames(buffer.format);
    final frameCount = min(
      leftFrameCount,
      buffer.sizeInFrames,
    );

    final read = node.read(node.outputBus, buffer.limit(frameCount)).frameCount;
    current += AudioTime.fromFrames(frames: read, format: buffer.format);
    return AudioReadResult(
      frameCount: read,
      isEnd: leftFrameCount == read,
    );
  }
}

void main() {
  group('MixerNode', () {
    test('read should mix audio sources', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      const volume = 0.01;
      const inputCount = 10;
      for (var i = 0; i < inputCount; i++) {
        final input = FunctionNode(function: OffsetFunction(volume), format: format, frequency: 1);
        input.outputBus.connect(mixer.appendInputBus());
      }

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        final result = mixer.outputBus.read(buffer);
        expect(result.frameCount, 1024);
        expect(result.isEnd, false);
        buffer.asFloat32ListView().forEach((sample) {
          expect(sample, closeTo(volume * inputCount, 0.001));
        });
      });
    });

    test('read should return correct result', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      const inputCount = 5;

      for (var i = 0; i < inputCount; i++) {
        final input = _DurationNode(
          duration: AudioTime(i + 1),
          node: FunctionNode(function: OffsetFunction(0), format: format, frequency: 1),
        );
        input.outputBus.connect(mixer.appendInputBus());
      }

      AllocatedAudioFrames(length: AudioTime(1).computeFrames(format), format: format).acquireBuffer((buffer) {
        for (var i = 1; i <= inputCount; i++) {
          final result = mixer.outputBus.read(buffer);

          // isEnd should be true only when all inputs are ended
          expect(result.isEnd, i == inputCount);
        }
      });
    });

    test('mixed audio should be clamped when flag is set', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format, isClampEnabled: true);

      const volume = 1.0;
      const inputCount = 10;
      for (var i = 0; i < inputCount; i++) {
        final input = FunctionNode(function: OffsetFunction(volume), format: format, frequency: 1);
        input.outputBus.connect(mixer.appendInputBus());
      }

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        mixer.outputBus.read(buffer);
        buffer.asFloat32ListView().forEach((sample) {
          expect(sample, 1.0);
        });
      });
    });

    test('mixed audio should not be clamped when flag is unset', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format, isClampEnabled: false);

      const volume = 1.0;
      const inputCount = 10;
      for (var i = 0; i < inputCount; i++) {
        final input = FunctionNode(function: OffsetFunction(volume), format: format, frequency: 1);
        input.outputBus.connect(mixer.appendInputBus());
      }

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        mixer.outputBus.read(buffer);
        buffer.asFloat32ListView().forEach((sample) {
          expect(sample, 10.0);
        });
      });
    });

    test('removeInputBus should throw MixerNodeException when removing connected bus', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);
      final mixerInputBus = mixer.appendInputBus();

      final input = FunctionNode(function: OffsetFunction(0), format: format, frequency: 1);
      input.outputBus.connect(mixerInputBus);

      expect(() => mixer.removeInputBus(mixerInputBus), throwsA(isA<MixerNodeException>()));
    });

    test('removeInputBus should throw MixerNodeException when removing unowned bus', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      final input = FunctionNode(function: OffsetFunction(0), format: format, frequency: 1);
      final inputBus = AudioInputBus(node: input, formatResolver: (_) => null);

      expect(() => mixer.removeInputBus(inputBus), throwsA(isA<MixerNodeException>()));
    });

    test('removeInputBus should remove bus', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      final inputBus = mixer.appendInputBus();
      expect(mixer.inputs.isNotEmpty, isTrue);

      mixer.removeInputBus(inputBus);
      expect(mixer.inputs.isEmpty, isTrue);
    });
  });
}
