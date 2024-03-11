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

      var frames = 0;
      AudioEncodeTask(
        format: format,
        endpoint: durationNode.outputBus,
        encoder: encoder,
        onEncoded: (buffer, isEnd) {
          frames += buffer.sizeInFrames;
          if (isEnd) {
            expect(frames, durationNode.duration.computeFrames(format));
          }
        },
      ).start();

      final decoder = WavAudioDecoder(dataSource: dataSource);
      expect(decoder.lengthInFrames, AudioTime(10).computeFrames(format));

      final decoderNode = DecoderNode(decoder: decoder);

      decoder.cursorInFrames = 0;

      AudioTask(
        clock: AudioLoopClock(),
        format: format,
        endpoint: decoderNode.outputBus,
        readFrameSize: durationNode.duration.computeFrames(format),
        onRead: (buffer, isEnd) {
          expect(buffer.sizeInFrames, durationNode.duration.computeFrames(format));
          expect(isEnd, isTrue);
        },
      ).start();
    });

    test('[int32] should encode/decode correctly', () async {
      final format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: SampleFormat.int32);
      final node = FunctionNode(function: SineFunction(), format: format, frequency: 440);
      final durationNode = DurationNode(duration: AudioTime(10), node: node);

      final dataSource = AudioMemoryDataSource();
      final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

      var frames = 0;
      AudioEncodeTask(
        format: format,
        endpoint: durationNode.outputBus,
        encoder: encoder,
        onEncoded: (buffer, isEnd) {
          frames += buffer.sizeInFrames;
          if (isEnd) {
            expect(frames, durationNode.duration.computeFrames(format));
          }
        },
      ).start();

      final decoder = WavAudioDecoder(dataSource: dataSource);
      expect(decoder.lengthInFrames, AudioTime(10).computeFrames(format));

      final decoderNode = DecoderNode(decoder: decoder);

      decoder.cursorInFrames = 0;

      AudioTask(
        clock: AudioLoopClock(),
        format: format,
        endpoint: decoderNode.outputBus,
        readFrameSize: durationNode.duration.computeFrames(format),
        onRead: (buffer, isEnd) {
          expect(buffer.sizeInFrames, durationNode.duration.computeFrames(format));
          expect(isEnd, isTrue);
        },
      ).start();
    });

    test('should throw WavFormatException when decoding invalid data', () async {
      final dataSource = AudioMemoryDataSource(buffer: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]);
      expect(() => WavAudioDecoder(dataSource: dataSource), throwsA(isA<WavFormatException>()));
    });
  });
}
