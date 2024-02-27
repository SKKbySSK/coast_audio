import 'package:coast_audio/coast_audio.dart';

typedef DecodeResultListener = void Function(AudioDecodeResult result);

class DecoderNode extends DataSourceNode {
  DecoderNode({required this.decoder});

  final AudioDecoder decoder;

  @override
  AudioFormat get outputFormat => decoder.outputFormat;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final result = decoder.decode(destination: buffer);
    return AudioReadResult(frameCount: result.frames, isEnd: result.isEnd);
  }
}
