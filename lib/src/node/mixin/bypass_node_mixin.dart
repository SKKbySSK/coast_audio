import 'package:coast_audio/coast_audio.dart';

/// A mixin that can bypass the node's process method.
mixin BypassNodeMixin on SingleInNodeMixin {
  var _bypass = false;

  /// Whether the node is bypassed.
  ///
  /// If true, the node will not process the input data and just pass the input data to the output bus.
  bool get bypass => _bypass;

  /// Set the bypass state.
  ///
  /// If true, the node will not process the input data and just pass the input data to the output bus.
  set bypass(bool value) => _bypass = value;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    if (bypass) {
      return inputBus.connectedBus!.read(buffer);
    } else {
      return super.read(outputBus, buffer);
    }
  }
}
