import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class FunctionNode extends DataSourceNode {
  FunctionNode({
    required this.function,
    required this.format,
    required double frequency,
    this.time = const AudioTime(0),
  })  : _advance = AudioTime(1.0 / (format.sampleRate / frequency)),
        _frequency = frequency {
    setOutputs([outputBus]);
  }

  final AudioFormat format;

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

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    for (var frame = 0; buffer.sizeInFrames > frame; frame++) {
      final pFrame = buffer.offset(frame).pBuffer.cast<Float>();
      final sample = function.process(time);
      for (var ch = 0; format.channels > ch; ch++) {
        pFrame.elementAt(ch).value = sample;
      }
      time += _advance;
    }

    return buffer.sizeInFrames;
  }
}
