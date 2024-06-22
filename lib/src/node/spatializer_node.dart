import 'package:coast_audio/coast_audio.dart';

class SpatializerNode extends AudioFilterNode {
  SpatializerNode({
    required this.spatializer,
    required this.listener,
  });

  final AudioSpatializer spatializer;

  AudioSpatializerListener listener;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => spatializer.inputFormat);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => spatializer.outputFormat);

  @override
  AudioReadResult process(AudioBuffer buffer, bool isEnd) {
    final frameCount = spatializer.process(listener, buffer, buffer);
    return AudioReadResult(frameCount: frameCount, isEnd: isEnd);
  }
}
