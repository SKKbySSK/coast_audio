import 'package:coast_audio/coast_audio.dart';

class EncoderNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  EncoderNode({
    required this.encoder,
  });
  final AudioEncoder encoder;

  @override
  List<SampleFormat> get supportedSampleFormats => [encoder.inputFormat.sampleFormat];

  @override
  int process(AudioBuffer buffer) {
    encoder.encode(buffer);
    return buffer.sizeInFrames;
  }
}
