import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceOutputNode extends ProcessorNode {
  MabDeviceOutputNode({
    required this.deviceOutput,
  }) : super(deviceOutput.outputFormat);

  final MabDeviceOutput deviceOutput;

  @override
  void process(FrameBuffer buffer) {
    deviceOutput.write(buffer).throwIfNeeded();
  }
}
