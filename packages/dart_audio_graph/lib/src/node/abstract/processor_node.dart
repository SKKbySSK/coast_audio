import '../../../dart_audio_graph.dart';

abstract class ProcessorNode extends PassthroughNode {
  ProcessorNode([AudioFormat? format]) : super(format);

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final readFrames = inputBus.read(buffer);
    process(buffer.limit(readFrames));
    return readFrames;
  }

  void process(FrameBuffer buffer);
}
