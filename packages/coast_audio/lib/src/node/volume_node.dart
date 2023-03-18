import 'package:coast_audio/coast_audio.dart';

class VolumeNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin, BypassNodeMixin {
  VolumeNode({required this.volume});

  double volume;

  @override
  List<SampleFormat> get supportedSampleFormats => const [
        SampleFormat.int16,
        SampleFormat.uint8,
        SampleFormat.int32,
        SampleFormat.float32,
      ];

  @override
  int process(RawFrameBuffer buffer) {
    switch (buffer.format.sampleFormat) {
      case SampleFormat.float32:
        buffer.applyFloat32Volume(volume);
        break;
      case SampleFormat.int16:
        buffer.applyInt16Volume(volume);
        break;
      case SampleFormat.uint8:
        buffer.applyUint8Volume(volume);
        break;
      case SampleFormat.int32:
        buffer.applyInt32Volume(volume);
        break;
    }

    return buffer.sizeInFrames;
  }
}
