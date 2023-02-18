import 'package:dart_audio_graph/dart_audio_graph.dart';

class VolumeNode extends ProcessorNode {
  VolumeNode({required this.volume});

  double volume;

  @override
  void process(FrameBuffer buffer) {
    buffer.applyVolume(volume);
  }
}
