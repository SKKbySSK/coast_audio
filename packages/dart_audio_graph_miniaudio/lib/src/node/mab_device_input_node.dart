import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class MabDeviceInputNode extends DataSourceNode {
  MabDeviceInputNode({
    required this.deviceInput,
    this.waitForFill = false,
  }) : super() {
    setOutputs([outputBus]);
  }

  final MabDeviceInput deviceInput;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => deviceInput.format);

  /// wait for the internal buffer to be filled when reading samples.
  bool waitForFill;

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    if (!waitForFill) {
      return deviceInput.read(buffer).framesRead;
    }

    if (deviceInput.availableWriteFrames == 0) {
      return deviceInput.read(buffer).framesRead;
    }

    return 0;
  }
}
