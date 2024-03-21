import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../interop/internal/coast_audio_native_library.dart';
import '../node/helper/duration_node.dart';

void main() {
  CoastAudioNative.initialize(library: resolveNativeLib());

  late AudioMemoryDataSource dataSource;
  const duration = AudioTime(10);

  const format = AudioFormat(channels: 2, sampleRate: 44100, sampleFormat: SampleFormat.int32);

  setUp(() async {
    final node = FunctionNode(function: SineFunction(), format: format, frequency: 440);
    final durationNode = DurationNode(duration: duration, node: node);

    dataSource = AudioMemoryDataSource();
    final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

    encoder.start();

    await AudioLoopClock().runWithBuffer(
      frames: AllocatedAudioFrames(length: 4096, format: format),
      onTick: (clock, buffer) {
        final result = durationNode.outputBus.read(buffer);
        encoder.encode(buffer.limit(result.frameCount));

        return !result.isEnd;
      },
    );

    encoder.finalize();

    dataSource.position = 0;
  });

  test('should decode correctly', () async {
    final decoder = MaAudioDecoder(dataSource: dataSource);
    expect(decoder.cursorInFrames, 0);
    expect(decoder.lengthInFrames, duration.computeFrames(format));
    expect(decoder.outputFormat.isSameFormat(format), isTrue);

    await AudioLoopClock().runWithBuffer(
      frames: AllocatedAudioFrames(length: duration.computeFrames(format), format: format),
      onTick: (clock, buffer) {
        final result = decoder.decode(destination: buffer);
        expect(buffer.sizeInFrames, duration.computeFrames(format));
        expect(result.isEnd, isTrue);

        return !result.isEnd;
      },
    );
  });
}
