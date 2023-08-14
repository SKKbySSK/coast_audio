import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class FunctionNode extends DataSourceNode {
  FunctionNode({
    required this.function,
    required this.format,
    required double frequency,
    this.time = const AudioTime(0),
  })  : _advance = AudioTime(1.0 / (format.sampleRate / frequency)),
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
    setOutputs([outputBus]);
  }

  final AudioFormat format;

  late final int Function(AudioOutputBus outputBus, AudioBuffer buffer) _readFunc;

  AudioTime _advance;

  double _frequency;

  double get frequency => _frequency;

  set frequency(double freq) {
    _frequency = freq;
    _advance = AudioTime(1.0 / (format.sampleRate / freq));
  }

  AudioTime time;

  WaveFunction function;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  int _readFloat32(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asFloat32ListView();
    for (var i = 0; list.length > i; i += format.channels) {
      final sample = function.compute(time);
      for (var ch = 0; format.channels > ch; ch++) {
        list[i + ch] = sample;
      }
      time += _advance;
    }

    return buffer.sizeInFrames;
  }

  int _readInt16(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asInt16ListView();
    for (var i = 0; list.length > i; i += format.channels) {
      final sample = function.compute(time);
      for (var ch = 0; format.channels > ch; ch++) {
        list[i + ch] = max((sample * SampleFormat.int16.max).toInt(), SampleFormat.int16.min);
      }
      time += _advance;
    }

    return buffer.sizeInFrames;
  }

  @override
  int read(AudioOutputBus outputBus, AudioBuffer buffer) => _readFunc(outputBus, buffer);
}
