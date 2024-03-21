import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class FixedFrameNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin {
  FixedFrameNode({required this.size});

  int size;

  @override
  late final inputBus = AudioInputBus.autoFormat(node: this);

  @override
  late final outputBus = AudioOutputBus.autoFormat(node: this, inputBus: inputBus);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final readSize = min(size, buffer.sizeInFrames);
    return inputBus.connectedBus!.read(buffer.limit(readSize));
  }
}
