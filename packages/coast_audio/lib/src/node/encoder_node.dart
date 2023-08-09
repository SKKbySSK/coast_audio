import 'package:coast_audio/coast_audio.dart';

class EncoderNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  EncoderNode({
    required this.encoder,
  });
  final AudioEncoder encoder;

  @override
  int process(AudioBuffer buffer) {
    encoder.encode(buffer);
    return buffer.sizeInFrames;
  }
}
