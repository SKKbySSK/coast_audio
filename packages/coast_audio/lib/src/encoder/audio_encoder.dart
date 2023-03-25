import 'package:coast_audio/coast_audio.dart';

abstract class AudioEncoder {
  AudioFormat get format;

  void start();

  int encode(AudioFrameBuffer buffer);

  void stop();
}
