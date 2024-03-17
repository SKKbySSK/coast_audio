import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../interop/internal/coast_audio_native_library.dart';
import '../node/helper/duration_node.dart';

void main() {
  CoastAudioNative.initialize(library: resolveNativeLib());

  late AudioMemoryDataSource dataSource;
  const duration = AudioTime(10);

  const format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: SampleFormat.int32);

  setUp(() {
    final node = FunctionNode(function: SineFunction(), format: format, frequency: 440);
    final durationNode = DurationNode(duration: duration, node: node);

    dataSource = AudioMemoryDataSource();
    final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

    AudioEncodeTask(
      format: format,
      endpoint: durationNode.outputBus,
      encoder: encoder,
    ).start();

    dataSource.position = 0;
  });

  test('should decode correctly', () async {
    final decoder = MaAudioDecoder(dataSource: dataSource);
    expect(decoder.cursorInFrames, 0);
    expect(decoder.lengthInFrames, duration.computeFrames(format));
    expect(decoder.outputFormat.isSameFormat(format), isTrue);

    final decoderNode = DecoderNode(decoder: decoder);

    AudioTask(
      clock: AudioLoopClock(),
      format: format,
      endpoint: decoderNode.outputBus,
      readFrameSize: duration.computeFrames(format),
      onRead: (buffer, isEnd) {
        expect(buffer.sizeInFrames, duration.computeFrames(format));
        expect(isEnd, isTrue);
      },
    ).start();
  });
}
