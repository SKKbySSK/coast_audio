import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceOutputNode extends FixedFormatSingleInoutNode {
  MabDeviceOutputNode({
    required this.deviceOutput,
  }) : super(deviceOutput.format);

  final MabDeviceOutput deviceOutput;

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    final framesRead = super.read(outputBus, buffer.limit(min(deviceOutput.availableWriteFrames, buffer.sizeInFrames)));
    return deviceOutput.write(buffer.limit(framesRead)).framesWrite;
  }
}
