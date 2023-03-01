import 'package:dart_audio_graph/dart_audio_graph.dart';

class FunctionNode extends DataSourceNode {
  FunctionNode({
    required this.function,
    required this.format,
    required double frequency,
    this.time = const AudioTime(0),
  })  : _advance = AudioTime(1.0 / (format.sampleRate / frequency)),
        _frequency = frequency {
    if (format.sampleFormat != SampleFormat.float32) {
      throw AudioFormatException.unsupportedSampleFormat(format.sampleFormat);
    }
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
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
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
}
