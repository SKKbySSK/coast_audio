import 'package:dart_audio_graph/dart_audio_graph.dart';

mixin ProcessorNodeMixin on SingleInoutNode {
  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    assert(inputBus.resolveFormat()!.isSameFormat(buffer.format));
    final readFrames = inputBus.connectedBus!.read(buffer);
    return process(buffer.limit(readFrames));
  }

  int process(RawFrameBuffer buffer);
}
