import 'package:coast_audio/src/format/sample_format.dart';

class AudioFormat {
  const AudioFormat({
    required this.sampleRate,
    required this.channels,
    this.sampleFormat = SampleFormat.float32,
  });

  final int sampleRate;
  final int channels;
  final SampleFormat sampleFormat;

  int get bytesPerFrame {
    return sampleFormat.size * channels;
  }

  bool isSameFormat(AudioFormat other) {
    return sampleRate == other.sampleRate && channels == other.channels && sampleFormat == other.sampleFormat;
  }

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

class AudioFormatException implements Exception {
  const AudioFormatException(this.message);
  AudioFormatException.unsupportedSampleFormat(SampleFormat format) : message = '${format.name} is not supported';
  final String message;

  @override
  String toString() {
    return message;
  }
}
