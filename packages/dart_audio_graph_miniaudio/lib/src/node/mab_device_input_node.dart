import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceInputNode extends DataSourceNode {
  MabDeviceInputNode({
    required this.device,
  }) : super() {
    setOutputs([outputBus]);
  }

  MabDeviceInput device;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => device.format);

  @override
  List<SampleFormat> get supportedSampleFormats => [device.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return device.read(buffer).framesRead;
  }
}
