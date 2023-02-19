import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceOutputNode extends FixedFormatSingleInoutNode with ProcessorNodeMixin {
  MabDeviceOutputNode({
    required this.deviceOutput,
  }) : super(deviceOutput.format);

  final MabDeviceOutput deviceOutput;

  @override
  int process(AcquiredFrameBuffer buffer) {
    final result = deviceOutput.write(buffer);
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return buffer.sizeInFrames;
  }
}
