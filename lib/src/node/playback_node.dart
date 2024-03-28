import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class PlaybackNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin {
  PlaybackNode({
    required this.device,
  });

  final PlaybackDevice device;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => device.format);

  @override
  late final AudioEndpointBus outputBus = AudioEndpointBus(node: this, formatResolver: (_) => device.format);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final writableFrameCount = min(buffer.sizeInFrames, device.availableWriteFrames);
    final readResult = inputBus.connectedBus!.read(buffer.limit(writableFrameCount));
    final result = device.write(buffer.limit(readResult.frameCount));
    return AudioReadResult(
      frameCount: result.framesWrite,
      isEnd: readResult.isEnd,
    );
  }
}
