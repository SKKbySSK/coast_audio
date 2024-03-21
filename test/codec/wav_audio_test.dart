import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../node/helper/duration_node.dart';

void main() {
  group('WavAudioDecoder and WavAudioEncoder', () {
    test('[int16] should encode/decode correctly', () async {
      final format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: SampleFormat.int16);
      final node = FunctionNode(function: SineFunction(), format: format, frequency: 440);
      final durationNode = DurationNode(duration: AudioTime(10), node: node);

      final dataSource = AudioMemoryDataSource();
      final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

      encoder.start();

      var frames = 0;
      await AudioLoopClock().runWithBuffer(
        frames: AllocatedAudioFrames(length: 4096, format: format),
        onTick: (clock, buffer) {
          final result = durationNode.outputBus.read(buffer);
          encoder.encode(buffer.limit(result.frameCount));

          frames += result.frameCount;
          if (result.isEnd) {
            expect(frames, durationNode.duration.computeFrames(format));
          }

          return !result.isEnd;
        },
      );

      encoder.finalize();

      final decoder = WavAudioDecoder(dataSource: dataSource);
      expect(decoder.lengthInFrames, AudioTime(10).computeFrames(format));

      final decoderNode = DecoderNode(decoder: decoder);

      decoder.cursorInFrames = 0;

      await AudioLoopClock().runWithBuffer(
        frames: AllocatedAudioFrames(length: durationNode.duration.computeFrames(format), format: format),
        onTick: (clock, buffer) {
          final result = decoderNode.outputBus.read(buffer);

          expect(buffer.sizeInFrames, durationNode.duration.computeFrames(format));
          expect(result.isEnd, isTrue);

          return !result.isEnd;
        },
      );
    });

    test('[int32] should encode/decode correctly', () async {
      final format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: SampleFormat.int32);
      final node = FunctionNode(function: SineFunction(), format: format, frequency: 440);
      final durationNode = DurationNode(duration: AudioTime(10), node: node);

      final dataSource = AudioMemoryDataSource();
      final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

      encoder.start();

      var frames = 0;
      await AudioLoopClock().runWithBuffer(
        frames: AllocatedAudioFrames(length: 4096, format: format),
        onTick: (clock, buffer) {
          final result = durationNode.outputBus.read(buffer);
          encoder.encode(buffer.limit(result.frameCount));

          frames += result.frameCount;
          if (result.isEnd) {
            expect(frames, durationNode.duration.computeFrames(format));
          }

          return !result.isEnd;
        },
      );

      encoder.finalize();

      final decoder = WavAudioDecoder(dataSource: dataSource);
      expect(decoder.lengthInFrames, AudioTime(10).computeFrames(format));

      final decoderNode = DecoderNode(decoder: decoder);

      decoder.cursorInFrames = 0;

      await AudioLoopClock().runWithBuffer(
        frames: AllocatedAudioFrames(length: durationNode.duration.computeFrames(format), format: format),
        onTick: (clock, buffer) {
          final result = decoderNode.outputBus.read(buffer);

          expect(buffer.sizeInFrames, durationNode.duration.computeFrames(format));
          expect(result.isEnd, isTrue);

          return !result.isEnd;
        },
      );
    });

    test('should throw WavFormatException when decoding invalid data', () async {
      final dataSource = AudioMemoryDataSource(buffer: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]);
      expect(() => WavAudioDecoder(dataSource: dataSource), throwsA(isA<WavFormatException>()));
    });
  });
}
