import 'package:coast_audio/coast_audio.dart';

/// [VolumeNode] is a node that changes the volume of the audio data.
class VolumeNode extends AudioFilterNode {
  VolumeNode({required this.volume});

  /// The volume of the audio data.
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
      case SampleFormat.int16:
        buffer.applyInt16Volume(volume);
      case SampleFormat.uint8:
        buffer.applyUint8Volume(volume);
      case SampleFormat.int32:
        buffer.applyInt32Volume(volume);
      case SampleFormat.int24:
        throw AudioFormatError.unsupportedSampleFormat(buffer.format.sampleFormat);
    }

    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: isEnd);
  }
}
