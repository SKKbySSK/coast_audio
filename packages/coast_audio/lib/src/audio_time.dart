import 'package:coast_audio/coast_audio.dart';

/// A class for representing audio time.
class AudioTime {
  /// Constructs an [AudioTime] from [seconds].
  const AudioTime(this.seconds);

  /// Constructs an [AudioTime] from [frames] and [format].
  AudioTime.fromFrames(
    int frames, {
    required AudioFormat format,
  }) : seconds = (frames * format.bytesPerFrame) / (format.sampleRate * format.sampleFormat.size * format.channels);

  /// Constructs an [AudioTime] from [duration].
  AudioTime.fromDuration(Duration duration) : seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;

  static AudioTime zero = const AudioTime(0);

  /// Time in seconds.
  final double seconds;

  /// Format [seconds] as MM:SS.
  String formatMMSS() {
    final minutes = (this.seconds / 60).floor();
    final seconds = (this.seconds - (minutes * 60)).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format [seconds] as HH:MM:SS.
  String formatHHMMSS() {
    final hours = (this.seconds / 3600).floor();
    final minutes = ((this.seconds - (hours * 3600)) / 60).floor();
    final seconds = (this.seconds - (hours * 3600) - (minutes * 60)).floor();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Compute the number of frames from [format].
  int computeFrames(AudioFormat format) {
    return (seconds * format.sampleRate * format.sampleFormat.size * format.channels) ~/ format.bytesPerFrame;
  }

  AudioTime operator +(AudioTime other) {
    return AudioTime(seconds + other.seconds);
  }

  AudioTime operator -(AudioTime other) {
    return AudioTime(seconds - other.seconds);
  }

  AudioTime operator /(AudioTime other) {
    return AudioTime(seconds / other.seconds);
  }

  AudioTime operator *(AudioTime other) {
    return AudioTime(seconds * other.seconds);
  }

  bool operator >(AudioTime other) {
    return seconds > other.seconds;
  }

  bool operator <(AudioTime other) {
    return seconds < other.seconds;
  }

  bool operator >=(AudioTime other) {
    return seconds >= other.seconds;
  }

  bool operator <=(AudioTime other) {
    return seconds <= other.seconds;
  }

  @override
  bool operator ==(Object other) {
    if (other is! AudioTime) {
      return false;
    }

    return seconds == other.seconds;
  }

  @override
  int get hashCode => seconds.hashCode;

  @override
  String toString() {
    return 'AudioTime(${formatHHMMSS()})';
  }
}
