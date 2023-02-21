import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioDecodeResult {
  const AudioDecodeResult({
    required this.frames,
    required this.isEnd,
  });
  final int frames;
  final bool isEnd;
}

abstract class AudioDecoder {
  AudioDecoder();

  AudioFormat get format;

  int get length;

  int get cursor;

  set cursor(int value);

  AudioDecodeResult decode(RawFrameBuffer buffer);
}
