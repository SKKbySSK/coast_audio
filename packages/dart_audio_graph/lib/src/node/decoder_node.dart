import 'package:dart_audio_graph/dart_audio_graph.dart';

class DecoderNode extends DataSourceNode {
  DecoderNode({
    required this.decoder,
  }) {
    setOutputs([outputBus]);
  }

  final AudioDecoder decoder;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => decoder.format);

  @override
  List<SampleFormat> get supportedSampleFormats => [decoder.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return decoder.decode(buffer);
  }
}
