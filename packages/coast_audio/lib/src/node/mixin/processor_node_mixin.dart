import 'package:coast_audio/coast_audio.dart';

mixin ProcessorNodeMixin on SingleInNodeMixin {
  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final originalResult = inputBus.connectedBus!.read(buffer);
    return process(
      buffer.limit(originalResult.frameCount),
      originalResult.isEnd,
    );
  }

  AudioReadResult process(AudioBuffer buffer, bool isEnd);
}
