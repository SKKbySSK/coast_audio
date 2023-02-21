import 'package:dart_audio_graph/dart_audio_graph.dart';

class DecoderNode extends DataSourceNode {
  DecoderNode({
    required this.decoders,
  }) {
    setOutputs([outputBus]);
  }

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => _activeDecoder?.format);

  final List<AudioDecoder> decoders;

  AudioDecoder? _activeDecoder;
  AudioDecoder? get activeDecoder => _activeDecoder;

  Future<void> prepare({required AudioDataSource dataSource}) async {
    for (final decoder in decoders) {
      if (await decoder.verify(dataSource: dataSource)) {
        await decoder.open(dataSource: dataSource);
        _activeDecoder = decoder;
        break;
      }
    }
  }

  @override
  List<SampleFormat> get supportedSampleFormats => [if (_activeDecoder != null) _activeDecoder!.format!.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return _activeDecoder!.decode(buffer);
  }
}
