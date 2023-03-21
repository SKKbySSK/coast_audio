import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/buffer/dynamic_audio_frame.dart';

class ConverterNode extends SingleInoutNode with SyncDisposableNodeMixin {
  ConverterNode({required this.converter});

  final AudioFormatConverter converter;

  late final _audioFrame = DynamicAudioFrame(format: converter.inputFormat);

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
  int read(AudioOutputBus outputBus, AudioFrameBuffer buffer) {
    _audioFrame.requestFrames(buffer.sizeInFrames);

    return _audioFrame.acquireBuffer((buffer) {
      var readFrames = super.read(outputBus, buffer);
      readFrames = converter.convert(bufferOut: buffer.limit(readFrames), bufferIn: buffer.limit(readFrames));

      return readFrames;
    });
  }

  bool _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    _isDisposed = true;
    _audioFrame.dispose();
  }
}
