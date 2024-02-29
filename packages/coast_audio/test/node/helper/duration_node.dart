import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class DurationNode extends AudioNode with SingleOutNodeMixin {
  DurationNode({
    required this.duration,
    required this.node,
  });
  final AudioTime duration;
  final SingleOutNodeMixin node;

  var current = AudioTime.zero;

  @override
  List<AudioInputBus> get inputs => [];

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => node.outputBus.resolveFormat());

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final leftFrameCount = (duration - current).computeFrames(buffer.format);
    final frameCount = min(
      leftFrameCount,
      buffer.sizeInFrames,
    );

    final read = node.read(node.outputBus, buffer.limit(frameCount)).frameCount;
    current += AudioTime.fromFrames(read, format: buffer.format);
    return AudioReadResult(
      frameCount: read,
      isEnd: leftFrameCount == read,
    );
  }
}
