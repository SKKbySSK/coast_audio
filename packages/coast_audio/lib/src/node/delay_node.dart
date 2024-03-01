import 'package:coast_audio/coast_audio.dart';

class DelayNode extends AudioFilterNode {
  DelayNode({
    required this.delayFrames,
    required this.delayStart,
    required this.format,
    required this.decay,
    this.dry = 1,
    this.wet = 1,
  }) : _delayBuffer = List.filled(delayFrames * format.channels, 0);

  final int delayFrames;
  final bool delayStart;
  final AudioFormat format;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => format);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  double decay;
  double dry;
  double wet;

  final List<double> _delayBuffer;
  var _cursor = 0;

  void reset() {
    _delayBuffer.fillRange(0, _delayBuffer.length, 0);
    _cursor = 0;
  }

  @override
  AudioReadResult process(AudioBuffer buffer, bool isEnd) {
    final floatList = buffer.asFloat32ListView();

    for (var frame = 0; buffer.sizeInFrames > frame; frame++) {
      for (var channel = 0; format.channels > channel; channel++) {
        final delayBufferIndex = (_cursor * format.channels) + channel;
        final bufferIndex = (frame * format.channels) + channel;

        if (delayStart) {
          final sample = floatList[bufferIndex];
          floatList[bufferIndex] = _delayBuffer[delayBufferIndex] * wet;
          _delayBuffer[delayBufferIndex] = (_delayBuffer[delayBufferIndex] * decay) + (sample * dry);
        } else {
          _delayBuffer[delayBufferIndex] = (_delayBuffer[delayBufferIndex] * decay) + (floatList[bufferIndex] * dry);
          floatList[bufferIndex] = _delayBuffer[delayBufferIndex] * wet;
        }

        _cursor = (_cursor + 1) % delayFrames;
      }
    }

    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: false);
  }
}
