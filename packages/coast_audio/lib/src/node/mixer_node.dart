import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class MixerNode extends AudioNode {
  MixerNode({
    required this.format,
    this.isClampEnabled = true,
    Memory? memory,
  }) : memory = memory ?? Memory() {
    if (format.sampleFormat != SampleFormat.float32) {
      throw AudioFormatException.unsupportedSampleFormat(format.sampleFormat);
    }
  }

  final Memory memory;
  final AudioFormat format;

  bool isClampEnabled;

  final _inputs = <AudioInputBus>[];

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  @override
  List<AudioInputBus> get inputs => List.unmodifiable(_inputs);

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  AudioInputBus appendInputBus() {
    final bus = AudioInputBus(node: this, formatResolver: (_) => format);
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
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    if (_inputs.isEmpty) {
      return 0;
    }

    if (_inputs.length == 1) {
      return _inputs[0].connectedBus!.read(buffer);
    }

    buffer.fill(0);
    final busBuffer = AllocatedFrameBuffer(frames: buffer.sizeInFrames, format: format);

    final outFloatList = buffer.asFloat32ListView();
    var maxReadFrames = 0;

    try {
      busBuffer.acquireBuffer((rawBusBuffer) {
        final busFloatList = rawBusBuffer.asFloat32ListView();
        for (var bus in _inputs) {
          var left = buffer.sizeInFrames;
          var readFrames = bus.connectedBus!.read(rawBusBuffer);
          var totalReadFrames = readFrames;
          left -= readFrames;
          while (left > 0 && readFrames > 0) {
            readFrames = bus.connectedBus!.read(rawBusBuffer.offset(totalReadFrames));
            totalReadFrames += readFrames;
            left -= readFrames;
          }

          for (var i = 0; (totalReadFrames * format.channels) > i; i++) {
            outFloatList[i] += busFloatList[i];
          }

          maxReadFrames = max(totalReadFrames, maxReadFrames);
        }
      });
    } finally {
      busBuffer.dispose();
    }

    if (isClampEnabled) {
      buffer.clamp(frames: maxReadFrames);
    }

    return maxReadFrames;
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
