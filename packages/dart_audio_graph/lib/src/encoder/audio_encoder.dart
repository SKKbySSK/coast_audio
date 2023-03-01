import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioEncoder {
  void start();

  int encode(RawFrameBuffer buffer);

  void stop();
}
