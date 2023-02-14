import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class MixerNode extends AudioNode {
  MixerNode({
    this.isClampEnabled = true,
    required this.format,
  });

  final AudioFormat format;

  bool isClampEnabled;

  final _inputs = <AudioInputBus>[];

  late final outputBus = AudioOutputBus(node: this, format: format);

  @override
  List<AudioInputBus> get inputs => List.unmodifiable(_inputs);

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  AudioInputBus appendInputBus() {
    final bus = AudioInputBus(node: this, format: format);
    _inputs.add(bus);
    return bus;
  }

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    if (_inputs.isEmpty) {
      return 0;
    }

    final bufferFloatList = buffer.asFloatList();
    for (var frame = 0; bufferFloatList.length > frame; frame++) {
      bufferFloatList[frame] = 0;
    }

    final format = _inputs[0].format!;
    final busBuffer = FrameBuffer.allocate(frames: buffer.sizeInFrames, format: format);
    final busBufferFloatList = busBuffer.asFloatList();

    for (var bus in _inputs) {
      var left = buffer.sizeInFrames;
      var readFrames = bus.read(busBuffer);
      var totalReadFrames = readFrames;
      left -= readFrames;
      while (left > 0 && readFrames > 0) {
        readFrames = bus.read(busBuffer);
        totalReadFrames += readFrames;
        left -= readFrames;
      }

      for (var frame = 0; totalReadFrames > frame; frame++) {
        bufferFloatList[frame] += busBufferFloatList[frame];
      }
    }

    busBuffer.dispose();

    if (isClampEnabled) {
      for (var frame = 0; bufferFloatList.length > frame; frame++) {
        bufferFloatList[frame] = min(1, max(bufferFloatList[frame], -1));
      }
    }

    return buffer.sizeInFrames;
  }
}
