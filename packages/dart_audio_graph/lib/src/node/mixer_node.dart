import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class MixerNode extends AudioNode with AutoFormatNodeMixin {
  MixerNode({
    this.isClampEnabled = true,
    Memory? memory,
  }) : memory = memory ?? Memory();

  final Memory memory;

  bool isClampEnabled;

  final _inputs = <AudioInputBus>[];

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => currentInputFormat);

  @override
  List<AudioInputBus> get inputs => List.unmodifiable(_inputs);

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  AudioInputBus appendInputBus() {
    final bus = AudioInputBus.autoFormat(node: this);
    _inputs.add(bus);
    return bus;
  }

  void removeInputBus(AudioInputBus bus) {
    if (bus.connectedBus != null) {
      throw MixerNodeException.connectedInputBus();
    }

    if (bus.node != this) {
      throw MixerNodeException.invalidBus();
    }

    _inputs.remove(bus);
  }

  @override
  int read(AudioOutputBus outputBus, AcquiredFrameBuffer buffer) {
    if (_inputs.isEmpty) {
      return 0;
    }

    if (_inputs.length == 1) {
      return _inputs[0].connectedBus!.read(buffer);
    }

    final bufferFloatList = buffer.asFloat32ListView();
    for (var frame = 0; bufferFloatList.length > frame; frame++) {
      bufferFloatList[frame] = 0;
    }

    final format = _inputs[0].resolveFormat()!;
    final busBuffer = AllocatedFrameBuffer(frames: buffer.sizeInFrames, format: format);
    final acqBusBuffer = busBuffer.lock();
    final busBufferFloatList = acqBusBuffer.asFloat32ListView();

    try {
      for (var bus in _inputs) {
        var left = buffer.sizeInFrames;
        var readFrames = bus.connectedBus!.read(acqBusBuffer);
        var totalReadFrames = readFrames;
        left -= readFrames;
        while (left > 0 && readFrames > 0) {
          readFrames = bus.connectedBus!.read(acqBusBuffer.offset(totalReadFrames));
          totalReadFrames += readFrames;
          left -= readFrames;
        }

        for (var i = 0; (totalReadFrames * format.samplesPerFrame) > i; i++) {
          bufferFloatList[i] += busBufferFloatList[i];
        }
      }
    } finally {
      busBuffer.unlock();
      busBuffer.dispose();
    }

    if (isClampEnabled) {
      for (var frame = 0; bufferFloatList.length > frame; frame++) {
        bufferFloatList[frame] = min(1, max(bufferFloatList[frame], -1));
      }
    }

    return buffer.sizeInFrames;
  }
}

class MixerNodeException implements Exception {
  const MixerNodeException(this.message, this.code);

  const MixerNodeException.connectedInputBus()
      : message = 'input bus is connected to another bus',
        code = -1;

  const MixerNodeException.invalidBus()
      : message = 'the bus is not associated to this node',
        code = -2;

  final String message;
  final int code;

  @override
  String toString() {
    return message;
  }
}
