import 'package:coast_audio/coast_audio.dart';

mixin BypassNodeMixin on ProcessorNodeMixin {
  var _bypass = false;
  bool get bypass => _bypass;
  set bypass(bool value) => _bypass = value;

  @override
  int read(AudioOutputBus outputBus, AudioFrameBuffer buffer) {
    assert(inputBus.resolveFormat()!.isSameFormat(buffer.format));
    final readFrames = inputBus.connectedBus!.read(buffer);
    if (bypass) {
      return readFrames;
    }

    return process(buffer.limit(readFrames));
  }
}
