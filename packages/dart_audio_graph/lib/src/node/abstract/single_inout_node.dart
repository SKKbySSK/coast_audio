import '../../../dart_audio_graph.dart';

abstract class SingleInoutNode extends AudioNode {
  SingleInoutNode();

  AudioInputBus get inputBus;

  AudioOutputBus get outputBus;

  @override
  List<AudioInputBus> get inputs => [inputBus];

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return inputBus.connectedBus!.read(buffer);
  }
}

abstract class AutoFormatSingleInoutNode extends SingleInoutNode with AutoFormatNodeMixin {
  @override
  late final inputBus = AudioInputBus.autoFormat(node: this);

  @override
  late final outputBus = AudioOutputBus.autoFormat(node: this);
}

abstract class FixedFormatSingleInoutNode extends SingleInoutNode {
  FixedFormatSingleInoutNode(this.format);

  final AudioFormat format;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => format);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);
}
