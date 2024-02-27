import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class FunctionNode extends DataSourceNode {
  FunctionNode({
    required this.function,
    required AudioFormat format,
    required double frequency,
    this.time = const AudioTime(0),
  })  : outputFormat = format,
        _advance = AudioTime(1.0 / (format.sampleRate / frequency)),
        _frequency = frequency {
    switch (format.sampleFormat) {
      case SampleFormat.float32:
        _readFunc = _readFloat32;
        break;
      case SampleFormat.int16:
        _readFunc = _readInt16;
        break;
      default:
        throw AudioFormatException.unsupportedSampleFormat(format.sampleFormat);
    }
  }

  @override
  final AudioFormat outputFormat;

  late final int Function(AudioOutputBus outputBus, AudioBuffer buffer) _readFunc;

  AudioTime _advance;

  double _frequency;

  double get frequency => _frequency;

  set frequency(double freq) {
    _frequency = freq;
    _advance = AudioTime(1.0 / (outputFormat.sampleRate / freq));
  }

  AudioTime time;

  WaveFunction function;

  int _readFloat32(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asFloat32ListView();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = sample;
      }
      time += _advance;
    }

    return buffer.sizeInFrames;
  }

  int _readInt16(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asInt16ListView();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = max((sample * SampleFormat.int16.max).toInt(), SampleFormat.int16.min.toInt());
      }
      time += _advance;
    }

    return buffer.sizeInFrames;
  }

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    return AudioReadResult(frameCount: _readFunc(outputBus, buffer), isEnd: false);
  }
}
