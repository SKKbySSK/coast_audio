import '../../../dart_audio_graph.dart';

class PassthroughNode extends AudioNode with AnyFormatNodeMixin {
  PassthroughNode([this._format]);

  final AudioFormat? _format;

  @override
  AudioFormat? get currentInputFormat => _format ?? super.currentInputFormat;

  late final inputBus = AudioInputBus.anyFormat(node: this);

  late final outputBus = AudioOutputBus.anyFormat(node: this);

  @override
  List<AudioInputBus> get inputs => [inputBus];

  @override
  List<AudioOutputBus> get outputs => [outputBus];

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    return inputBus.read(buffer);
  }
}
