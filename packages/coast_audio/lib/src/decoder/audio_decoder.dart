import 'package:coast_audio/coast_audio.dart';

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

  AudioDecodeResult decode({required RawFrameBuffer destination});
}
