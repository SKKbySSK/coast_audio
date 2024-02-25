import 'package:coast_audio/coast_audio.dart';

mixin BypassNodeMixin on ProcessorNodeMixin {
  var _bypass = false;
  bool get bypass => _bypass;
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
