import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceOutputNode extends ProcessorNode {
  MabDeviceOutputNode({
    required this.deviceOutput,
  }) : super(deviceOutput.format);

  final MabDeviceOutput deviceOutput;

  @override
  void process(FrameBuffer buffer) {
    final result = deviceOutput.write(buffer);
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
  }
}
