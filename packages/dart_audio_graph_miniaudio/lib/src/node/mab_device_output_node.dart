import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceOutputNode extends FixedFormatSingleInoutNode {
  MabDeviceOutputNode({
    required this.device,
  }) : super(device.format);

  MabDeviceOutput device;

  @override
  List<SampleFormat> get supportedSampleFormats => [device.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    final framesRead = super.read(outputBus, buffer.limit(min(device.availableWriteFrames, buffer.sizeInFrames)));
    return device.write(buffer.limit(framesRead)).framesWrite;
  }
}
