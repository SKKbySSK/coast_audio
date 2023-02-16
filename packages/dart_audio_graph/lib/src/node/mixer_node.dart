import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class MixerNode extends AudioNode with AnyFormatNodeMixin {
  MixerNode({
    this.isClampEnabled = true,
  });

  bool isClampEnabled;

  final _inputs = <AudioInputBus>[];

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => currentInputFormat);

  @override
  List<AudioInputBus> get inputs => List.unmodifiable(_inputs);

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  AudioInputBus appendInputBus() {
    final bus = AudioInputBus.anyFormat(node: this);
    _inputs.add(bus);
    return bus;
  }

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    if (_inputs.isEmpty) {
      return 0;
    }

    if (_inputs.length == 1) {
      return _inputs[0].read(buffer);
    }

    final bufferFloatList = buffer.asFloatList();
    for (var frame = 0; bufferFloatList.length > frame; frame++) {
      bufferFloatList[frame] = 0;
    }

    final format = _inputs[0].resolveFormat()!;
    final busBuffer = FrameBuffer.allocate(frames: buffer.sizeInFrames, format: format);
    final busBufferFloatList = busBuffer.asFloatList();

    for (var bus in _inputs) {
      var left = buffer.sizeInFrames;
      var readFrames = bus.read(busBuffer);
      var totalReadFrames = readFrames;
      left -= readFrames;
      while (left > 0 && readFrames > 0) {
        readFrames = bus.read(busBuffer.offset(totalReadFrames));
        totalReadFrames += readFrames;
        left -= readFrames;
      }

      for (var i = 0; bufferFloatList.length > i; i++) {
        bufferFloatList[i] += busBufferFloatList[i];
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
