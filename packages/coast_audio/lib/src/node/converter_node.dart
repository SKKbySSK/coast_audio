import 'package:coast_audio/coast_audio.dart';

class ConverterNode extends SingleInoutNode {
  ConverterNode({required this.converter});

  final AudioFormatConverter converter;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => converter.inputFormat);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => converter.outputFormat);

  @override
  List<SampleFormat> get supportedSampleFormats => const [
        SampleFormat.int16,
        SampleFormat.uint8,
        SampleFormat.int32,
        SampleFormat.float32,
      ];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    final readBuffer = AllocatedFrameBuffer(frames: buffer.sizeInFrames, format: converter.inputFormat);
    var acqReadBuffer = readBuffer.lock();

    var readFrames = super.read(outputBus, acqReadBuffer);
    acqReadBuffer = acqReadBuffer.limit(readFrames);

    readFrames = converter.convert(bufferOut: buffer.limit(readFrames), bufferIn: acqReadBuffer);
    readBuffer
      ..unlock()
      ..dispose();
    return readFrames;
  }
}
