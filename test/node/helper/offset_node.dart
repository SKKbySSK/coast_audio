import 'package:coast_audio/coast_audio.dart';

class OffsetNode extends DataSourceNode {
  OffsetNode({
    required this.offset,
    required this.outputFormat,
  });

  final num offset;

  @override
  final AudioFormat outputFormat;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    switch (outputFormat.sampleFormat) {
      case SampleFormat.float32:
        final list = buffer.asFloat32ListView();
        list.fillRange(0, list.length, offset.toDouble());
      case SampleFormat.int16:
        final list = buffer.asInt16ListView();
        list.fillRange(0, list.length, offset.toInt());
      case SampleFormat.int32:
        final list = buffer.asInt32ListView();
        list.fillRange(0, list.length, offset.toInt());
      case SampleFormat.uint8:
        final list = buffer.asUint8ListViewFrames();
        list.fillRange(0, list.length, offset.toInt());
      case SampleFormat.int24:
        throw AudioFormatError.unsupportedSampleFormat(outputFormat.sampleFormat);
    }

    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: false);
  }
}
