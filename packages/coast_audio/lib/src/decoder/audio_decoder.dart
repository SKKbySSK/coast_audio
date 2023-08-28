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

  AudioFormat get outputFormat;

  int? get lengthInFrames;

  int get cursorInFrames;

  set cursorInFrames(int value);

  bool get canSeek;

  AudioDecodeResult decode({required AudioBuffer destination});
}
