import 'package:coast_audio/coast_audio.dart';

/// A mixin that provides a single input bus.
mixin SingleInNodeMixin on AudioNode {
  @override
  List<AudioInputBus> get inputs => [inputBus];

  /// inputBus of this node.
  AudioInputBus get inputBus;
}

/// A mixin that provides a single output bus.
mixin SingleOutNodeMixin on AudioNode {
  @override
  List<AudioOutputBus> get outputs => [outputBus];

  /// outputBus of this node.
  ///
  /// You can read audio data from this bus by calling read method.
  AudioOutputBus get outputBus;
}
