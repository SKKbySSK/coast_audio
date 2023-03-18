import 'package:coast_audio/coast_audio.dart';

class ConvolverNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin, BypassNodeMixin {
  ConvolverNode({
    required this.format,
    required this.impulseResponse,
  }) : _impBuffer = List.filled(impulseResponse.length, 0);

  final AudioFormat format;
  final List<double> impulseResponse;

  final List<double> _impBuffer;
  var _cursor = 0;

  void reset() {
    _impBuffer.fillRange(0, _impBuffer.length, 0);
    _cursor = 0;
  }

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int process(RawFrameBuffer buffer) {
    final floatList = buffer.asFloat32ListView();

    for (var impulseIndex = 0; impulseResponse.length > impulseIndex; impulseIndex++) {
      final imp = impulseResponse[impulseIndex];

      for (var frame = 0; buffer.sizeInFrames > frame; frame++) {
        for (var channel = 0; format.channels > channel; channel++) {
          final impBufferIndex = (_cursor * format.channels) + channel;
          final bufferIndex = (frame * format.channels) + channel;

          _impBuffer[impBufferIndex] = _impBuffer[impBufferIndex] + (floatList[bufferIndex] * imp);
          floatList[bufferIndex] = _impBuffer[impBufferIndex];

          _cursor = (_cursor + 1) % impulseResponse.length;
        }
      }
    }
    return buffer.sizeInFrames;
  }
}
