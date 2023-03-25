import 'package:coast_audio/coast_audio.dart';

class EncoderNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  EncoderNode({
    required this.encoder,
  });
  final AudioEncoder encoder;

  @override
  List<SampleFormat> get supportedSampleFormats => [encoder.format.sampleFormat];

  @override
  int process(AudioFrameBuffer buffer) {
    encoder.encode(buffer);
    return buffer.sizeInFrames;
  }
}
