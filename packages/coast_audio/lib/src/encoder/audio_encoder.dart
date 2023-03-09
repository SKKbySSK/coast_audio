import 'package:coast_audio/coast_audio.dart';

abstract class AudioEncoder {
  void start();

  int encode(RawFrameBuffer buffer);

  void stop();
}
