import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

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
