import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class MixerNode extends AudioNode with SyncDisposableNodeMixin {
  MixerNode({
    required this.format,
    this.isClampEnabled = true,
    Memory? memory,
  }) : memory = memory ?? Memory() {
    switch (format.sampleFormat) {
      case SampleFormat.float32:
        _mixerFunc = _mixFloat32;
        break;
      case SampleFormat.int16:
        _mixerFunc = _mixInt16;
        break;
      default:
        throw AudioFormatException.unsupportedSampleFormat(format.sampleFormat);
    }
  }

  final Memory memory;
  final AudioFormat format;

  bool isClampEnabled;

  late final void Function(AudioBuffer bufferIn, AudioBuffer mixerOut, int totalReadFrames) _mixerFunc;

  final _inputs = <AudioInputBus>[];

  late final _audioFrame = DynamicAudioFrames(format: format);

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  @override
  List<AudioInputBus> get inputs => List.unmodifiable(_inputs);

  @override
  List<AudioOutputBus> get outputs => [outputBus];

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

  void _mixFloat32(AudioBuffer bufferIn, AudioBuffer mixerOut, int totalReadFrames) {
    final inFloatList = bufferIn.asFloat32ListView();
    final outFloatList = mixerOut.asFloat32ListView();
    for (var i = 0; (totalReadFrames * format.channels) > i; i++) {
      outFloatList[i] += inFloatList[i];
    }
  }

  void _mixInt16(AudioBuffer bufferIn, AudioBuffer mixerOut, int totalReadFrames) {
    final inInt16List = bufferIn.asInt16ListView();
    final outInt16List = mixerOut.asInt16ListView();
    for (var i = 0; (totalReadFrames * format.channels) > i; i++) {
      outInt16List[i] += inInt16List[i];
    }
  }

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    if (_inputs.isEmpty) {
      return AudioReadResult(frameCount: 0, isEnd: true);
    }

    if (_inputs.length == 1) {
      return _inputs[0].connectedBus!.read(buffer);
    }

    buffer.fillBytes(0);
    _audioFrame.requestFrames(buffer.sizeInFrames);
    var maxReadFrames = 0;

    _audioFrame.acquireBuffer((busBuffer) {
      for (var bus in _inputs) {
        var left = buffer.sizeInFrames;
        var readFrames = bus.connectedBus!.read(busBuffer).frameCount;
        var totalReadFrames = readFrames;
        left -= readFrames;
        while (left > 0 && readFrames > 0) {
          readFrames = bus.connectedBus!.read(busBuffer.offset(totalReadFrames)).frameCount;
          totalReadFrames += readFrames;
          left -= readFrames;
        }

        _mixerFunc(busBuffer, buffer, totalReadFrames);
        maxReadFrames = max(totalReadFrames, maxReadFrames);
      }
    });

    if (isClampEnabled) {
      buffer.clamp(frames: maxReadFrames);
    }

    return AudioReadResult(frameCount: maxReadFrames, isEnd: false);
  }

  @override
  void dispose() {
    super.dispose();
    _audioFrame.dispose();
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
