import 'package:coast_audio/src/format/sample_format.dart';

class AudioFormat {
  const AudioFormat({
    required this.sampleRate,
    required this.channels,
    this.sampleFormat = SampleFormat.float32,
  });

  /// The sample rate in hertz.
  final int sampleRate;

  /// The number of channels.
  final int channels;

  /// The sample format.
  final SampleFormat sampleFormat;

  /// The number of bytes per frame.
  int get bytesPerFrame {
    return sampleFormat.size * channels;
  }

  /// Verifies that the format is same as [other].
  bool isSameFormat(AudioFormat other) {
    return sampleRate == other.sampleRate && channels == other.channels && sampleFormat == other.sampleFormat;
  }

  /// Creates a copy of the format with the specified parameters.
  AudioFormat copyWith({
    int? sampleRate,
    int? channels,
    SampleFormat? sampleFormat,
  }) {
    return AudioFormat(
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      sampleFormat: sampleFormat ?? this.sampleFormat,
    );
  }

  @override
  String toString() {
    return 'AudioFormat(${sampleRate}hz, ${channels}ch, ${sampleFormat.name})';
  }
}

class AudioFormatError extends Error {
  AudioFormatError.unsupportedSampleFormat(SampleFormat format) : message = '${format.name} is not supported.';
  final String message;

  @override
  String toString() {
    return 'AudioFormatError: $message';
  }
}
