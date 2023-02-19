import 'package:dart_audio_graph/dart_audio_graph.dart';

class VolumeNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  VolumeNode({required this.volume});

  double volume;

  @override
  int process(AcquiredFrameBuffer buffer) {
    buffer.applyFloat32Volume(volume);
    return buffer.sizeInFrames;
  }
}
