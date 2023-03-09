import 'package:coast_audio/coast_audio.dart';

mixin ProcessorNodeMixin on SingleInoutNode {
  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    assert(inputBus.resolveFormat()!.isSameFormat(buffer.format));
    final readFrames = inputBus.connectedBus!.read(buffer);
    return process(buffer.limit(readFrames));
  }

  int process(RawFrameBuffer buffer);
}
