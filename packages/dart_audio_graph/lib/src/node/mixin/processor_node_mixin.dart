import 'package:dart_audio_graph/dart_audio_graph.dart';

mixin ProcessorNodeMixin on SingleInoutNode {
  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final readFrames = inputBus.connectedBus!.read(buffer);
    process(buffer.limit(readFrames));
    return readFrames;
  }

  void process(FrameBuffer buffer);
}
