import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioTime {
  const AudioTime(this.seconds);

  AudioTime.fromFrames({
    required int frames,
    required AudioFormat format,
  }) : seconds = (frames * format.bytesPerFrame) / (format.sampleRate * format.sampleFormat.size * format.channels);

  static AudioTime zero = const AudioTime(0);

  final double seconds;

  String formattedString() {
    final hours = (this.seconds / 3600).floor();
    final minutes = ((this.seconds - (hours * 3600)) / 60).floor();
    final seconds = (this.seconds - (hours * 3600) - (minutes * 60)).floor();
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  AudioTime operator +(AudioTime other) {
    return AudioTime(seconds + other.seconds);
  }

  @override
  String toString() {
    return 'AudioTime(${seconds.toStringAsPrecision(3)}s)';
  }
}
