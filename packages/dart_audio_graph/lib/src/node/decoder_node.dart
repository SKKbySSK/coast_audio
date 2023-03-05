import 'package:dart_audio_graph/dart_audio_graph.dart';

typedef DecodeResultListener = void Function(AudioDecodeResult result);

class DecoderNode extends DataSourceNode {
  DecoderNode({required this.decoder}) {
    setOutputs([outputBus]);
  }

  final AudioDecoder decoder;

  final _listeners = <DecodeResultListener>[];

  void addListener(DecodeResultListener listener) {
    _listeners.add(listener);
  }

  void removeListener(DecodeResultListener listener) {
    _listeners.remove(listener);
  }

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => decoder.format);

  @override
  List<SampleFormat> get supportedSampleFormats => [decoder.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    final result = decoder.decode(destination: buffer);
    for (var listener in _listeners) {
      listener(result);
    }

    return result.frames;
  }
}
