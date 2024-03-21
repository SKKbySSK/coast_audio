import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import 'helper/duration_node.dart';
import 'helper/fixed_frame_node.dart';
import 'helper/offset_node.dart';

void main() {
  group('MixerNode', () {
    for (final sampleFormat in SampleFormat.values.where((e) => e != SampleFormat.int24)) {
      test('[${sampleFormat.name}] read should mix audio sources', () {
        final format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: sampleFormat);
        final mixer = MixerNode(format: format, isClampEnabled: false);

        const offset = 10;
        const inputCount = 10;
        for (var i = 0; i < inputCount; i++) {
          final input = OffsetNode(offset: offset, outputFormat: format);
          input.outputBus.connect(mixer.appendInputBus());
        }

        AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
          final result = mixer.outputBus.read(buffer);
          expect(result.frameCount, 1024);
          expect(result.isEnd, false);
          switch (sampleFormat) {
            case SampleFormat.int16:
              buffer.asInt16ListView().forEach((sample) {
                expect(sample, offset * inputCount);
              });
            case SampleFormat.int32:
              buffer.asInt32ListView().forEach((sample) {
                expect(sample, offset * inputCount);
              });
            case SampleFormat.float32:
              buffer.asFloat32ListView().forEach((sample) {
                expect(sample, offset * inputCount);
              });
            case SampleFormat.uint8:
              buffer.asUint8ListViewFrames().forEach((sample) {
                expect(sample, offset * inputCount);
              });
            case SampleFormat.int24:
              fail('int24 is not supported');
          }
        });
      });
    }

    test('read should mix audio sources', () {
      final format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format, isClampEnabled: false);

      const offset = 10;
      const inputCount = 10;
      for (var i = 0; i < inputCount; i++) {
        final input = OffsetNode(offset: offset, outputFormat: format);
        final fixedFrameNode = FixedFrameNode(size: 100);
        input.outputBus.connect(fixedFrameNode.inputBus);
        fixedFrameNode.outputBus.connect(mixer.appendInputBus());
      }

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        final result = mixer.outputBus.read(buffer);
        expect(result.frameCount, 1024);
        expect(result.isEnd, false);
        buffer.asFloat32ListView().forEach((sample) {
          expect(sample, offset * inputCount);
        });
      });
    });

    test('read should return correct result with single input', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      final input = DurationNode(
        duration: AudioTime(1),
        node: FunctionNode(function: OffsetFunction(0), format: format, frequency: 1),
      );
      input.outputBus.connect(mixer.appendInputBus());

      AllocatedAudioFrames(length: AudioTime(1).computeFrames(format), format: format).acquireBuffer((buffer) {
        final result = mixer.outputBus.read(buffer);
        expect(result.frameCount, AudioTime(1).computeFrames(format));
        expect(result.isEnd, true);
      });
    });

    test('read should return correct result with multiple inputs', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      const inputCount = 5;

      for (var i = 0; i < inputCount; i++) {
        final input = DurationNode(
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

    test('read should return 0 frame result', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final mixer = MixerNode(format: format);

      AllocatedAudioFrames(length: AudioTime(1).computeFrames(format), format: format).acquireBuffer((buffer) {
        final result = mixer.outputBus.read(buffer);

        // isEnd should be true only when all inputs are ended
        expect(result.frameCount, 0);
        expect(result.isEnd, isTrue);
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

    test('should throw when int24 format', () {
      const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int24);
      expect(() => MixerNode(format: format), throwsA(isA<AudioFormatError>()));
    });
  });
}
