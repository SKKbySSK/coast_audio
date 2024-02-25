import 'package:coast_audio/coast_audio.dart';

class VolumeNode extends AudioFilterNode {
  VolumeNode({required this.volume});

  double volume;

  @override
  late final inputBus = AudioInputBus.autoFormat(node: this);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => inputBus.resolveFormat());

  @override
  AudioReadResult process(AudioBuffer buffer, bool isEnd) {
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

    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: isEnd);
  }
}
