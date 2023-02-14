import 'package:dart_audio_graph/src/sample_format.dart';

class AudioFormat {
  const AudioFormat({
    required this.sampleRate,
    required this.channels,
    this.sampleFormat = SampleFormat.float,
  });

  final int sampleRate;
  final int channels;
  final SampleFormat sampleFormat;

  int get bytesPerFrame {
    return sampleFormat.size * samplesPerFrame;
  }

  int get samplesPerFrame {
    return channels;
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
