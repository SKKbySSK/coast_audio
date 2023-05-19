import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

abstract class MabFilterBase extends MabBase {
  MabFilterBase({required super.memory});

  void process(AudioBuffer bufferOut, AudioBuffer bufferIn);
}
