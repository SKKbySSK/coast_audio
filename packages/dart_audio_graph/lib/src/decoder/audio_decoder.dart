import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioDecoder {
  AudioDecoder();

  AudioFormat get format;

  int get length;

  int get position;

  set position(int value);

  int decode(RawFrameBuffer buffer);
}
