import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class MabPlaybackDeviceNode extends FixedFormatSingleInoutNode {
  MabPlaybackDeviceNode({
    required this.device,
  }) : super(device.format);

  MabPlaybackDevice device;

  @override
  int read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final framesRead = super.read(outputBus, buffer.limit(min(device.availableWriteFrames, buffer.sizeInFrames)));
    return device.write(buffer.limit(framesRead)).framesWrite;
  }
}
