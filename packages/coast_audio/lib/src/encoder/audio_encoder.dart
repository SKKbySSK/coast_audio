import 'package:coast_audio/coast_audio.dart';

class AudioEncodeResult {
  const AudioEncodeResult({
    required this.frames,
  });
  final int frames;
}

abstract class AudioEncoder {
  AudioFormat get inputFormat;

  void start();

  AudioEncodeResult encode(AudioBuffer buffer);

  void finalize();
}
