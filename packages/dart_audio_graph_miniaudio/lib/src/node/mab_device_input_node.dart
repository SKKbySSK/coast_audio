import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceInputNode extends DataSourceNode {
  MabDeviceInputNode({
    required this.deviceInput,
  }) : super() {
    setOutputs([outputBus]);
  }

  final MabDeviceInput deviceInput;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => deviceInput.format);

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    return deviceInput.read(buffer).framesRead;
  }
}
