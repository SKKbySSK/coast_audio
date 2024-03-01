import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../node/helper/duration_node.dart';

void main() {
  group('WavAudioDecoder and WavAudioEncoder', () {
    test('should encode/decode correctly', () async {
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

      dataSource.position = 0;

      final decoder = WavAudioDecoder(dataSource: dataSource);
      final decoderNode = DecoderNode(decoder: decoder);

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
  });
}
