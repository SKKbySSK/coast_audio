import '../../../dart_audio_graph.dart';

class PassthroughNode extends AudioNode {
  PassthroughNode([this.format]);

  final AudioFormat? format;

  late final inputBus = AudioInputBus(node: this, format: format);

  late final outputBus = AudioOutputBus(node: this, format: format);

  @override
  List<AudioInputBus> get inputs => [inputBus];

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    return inputBus.read(buffer);
  }
}
