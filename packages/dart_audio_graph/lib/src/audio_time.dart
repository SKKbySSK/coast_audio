import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioTime {
  const AudioTime(this.seconds);

  AudioTime.fromFrames({
    required int frames,
    required AudioFormat format,
  }) : seconds = (frames * format.bytesPerFrame) / (format.sampleRate * format.sampleFormat.size * format.channels);

  static AudioTime zero = const AudioTime(0);

  final double seconds;

  AudioTime operator +(AudioTime other) {
    return AudioTime(seconds + other.seconds);
  }

  @override
  String toString() {
    return 'AudioTime(${seconds.toStringAsPrecision(3)}s)';
  }
}
