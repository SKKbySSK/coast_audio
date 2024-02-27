import 'package:coast_audio/coast_audio.dart';

typedef DecodeResultListener = void Function(AudioDecodeResult result);

/// An audio node that decodes audio data by using [AudioDecoder].
class DecoderNode extends DataSourceNode {
  DecoderNode({required this.decoder});

  /// The decoder that decodes audio data.
  final AudioDecoder decoder;

  @override
  AudioFormat get outputFormat => decoder.outputFormat;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final result = decoder.decode(destination: buffer);
    return AudioReadResult(frameCount: result.frames, isEnd: result.isEnd);
  }
}
