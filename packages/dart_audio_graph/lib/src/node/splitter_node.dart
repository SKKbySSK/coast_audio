import 'package:dart_audio_graph/dart_audio_graph.dart';

class SplitterNode extends AudioNode with AnyFormatNodeMixin {
  SplitterNode({required this.bufferFrameSize});

  final _outputs = <AudioOutputBus>[];

  List<FrameRingBuffer?> _ringBuffers = [];

  final int bufferFrameSize;

  late final inputBus = AudioInputBus.anyFormat(node: this);

  @override
  List<AudioInputBus> get inputs => [inputBus];

  @override
  List<AudioOutputBus> get outputs => List.unmodifiable(_outputs);

  AudioOutputBus appendOutputBus() {
    final format = currentInputFormat;
    final bus = AudioOutputBus.anyFormat(node: this);
    _outputs.add(bus);
    _ringBuffers.add(format == null ? null : FrameRingBuffer(frames: bufferFrameSize, format: format));
    return bus;
  }

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final format = currentInputFormat!;

    final readFrames = inputBus.read(buffer);
    buffer = buffer.limit(readFrames);

    for (var i = 0; _ringBuffers.length > i; i++) {
      var ringBuffer = _ringBuffers[i] ?? FrameRingBuffer(frames: bufferFrameSize, format: format);
      if (!ringBuffer.format.isSameFormat(format)) {
        ringBuffer.dispose();
        ringBuffer = FrameRingBuffer(frames: bufferFrameSize, format: format);
      }
      _ringBuffers[i] = ringBuffer;
      ringBuffer.write(buffer);
    }

    return readFrames;
  }
}
