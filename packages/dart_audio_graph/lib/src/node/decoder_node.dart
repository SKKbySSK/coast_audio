import 'package:dart_audio_graph/dart_audio_graph.dart';

class DecoderNode extends DataSourceNode {
  DecoderNode({
    required this.decoder,
    this.isLoop = false,
  }) {
    setOutputs([outputBus]);
  }

  final AudioDecoder decoder;

  bool isLoop;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => decoder.format);

  @override
  List<SampleFormat> get supportedSampleFormats => [decoder.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    final result = decoder.decode(destination: buffer);
    if (result.isEnd && isLoop) {
      decoder.cursor = 0;
    }
    return result.frames;
  }
}
