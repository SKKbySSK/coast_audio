import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class MabCaptureDeviceNode extends DataSourceNode {
  MabCaptureDeviceNode({
    required this.device,
  }) : super() {
    setOutputs([outputBus]);
  }

  MabCaptureDevice device;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => device.format);

  @override
  List<SampleFormat> get supportedSampleFormats => [device.format.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return device.read(buffer).framesRead;
  }
}
