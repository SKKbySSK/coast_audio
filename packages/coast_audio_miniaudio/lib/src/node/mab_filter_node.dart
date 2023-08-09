import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class MabFilterNode extends FixedFormatSingleInoutNode with ProcessorNodeMixin, BypassNodeMixin {
  MabFilterNode({
    required this.filter,
    required AudioFormat format,
  }) : super(format);

  final MabFilterBase filter;

  @override
  int process(AudioBuffer buffer) {
    filter.process(buffer, buffer);
    return buffer.sizeInFrames;
  }
}
