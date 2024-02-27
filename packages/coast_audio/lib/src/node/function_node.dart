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
      case SampleFormat.int16:
        _readFunc = _readInt16;
      case SampleFormat.int32:
        _readFunc = _readInt32;
      case SampleFormat.uint8:
        _readFunc = _readUint8;
    }
  }

  @override
  final AudioFormat outputFormat;

  late final void Function(AudioOutputBus outputBus, AudioBuffer buffer) _readFunc;

  AudioTime _advance;

  double _frequency;

  double get frequency => _frequency;

  set frequency(double freq) {
    _frequency = freq;
    _advance = AudioTime(freq / outputFormat.sampleRate);
  }

  AudioTime time;

  WaveFunction function;

  void _readFloat32(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asFloat32ListView();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = sample;
      }
      time += _advance;
    }
  }

  void _readInt16(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asInt16ListView();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = max((sample * SampleFormat.int16.max).toInt(), SampleFormat.int16.min.toInt());
      }
      time += _advance;
    }
  }

  void _readInt32(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asInt32ListView();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = max((sample * SampleFormat.int32.max).toInt(), SampleFormat.int32.min.toInt());
      }
      time += _advance;
    }
  }

  void _readUint8(AudioOutputBus outputBus, AudioBuffer buffer) {
    final list = buffer.asUint8ListViewFrames();
    for (var i = 0; list.length > i; i += outputFormat.channels) {
      final sample = function.compute(time);
      for (var ch = 0; outputFormat.channels > ch; ch++) {
        list[i + ch] = max((sample * SampleFormat.uint8.max).toInt(), SampleFormat.uint8.min.toInt());
      }
      time += _advance;
    }
  }

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    _readFunc(outputBus, buffer);
    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: false);
  }
}
