import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/mab_audio_converter.dart';

class MabAudioConverterNode extends SingleInoutNode with SyncDisposableNodeMixin {
  MabAudioConverterNode({
    required this.converter,
  });

  MabAudioConverter converter;

  late final _inputFrames = DynamicAudioFrames(format: converter.inputFormat);

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => converter.inputFormat);

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => converter.outputFormat);

  var _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  int read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final readFrames = converter.getRequiredInputFrameCount(outputFrameCount: buffer.sizeInFrames);
    _inputFrames.requestFrames(readFrames);

    return _inputFrames.acquireBuffer((inputBuffer) {
      final actualReadFrames = super.read(outputBus, inputBuffer);
      final result = converter.process(inputBuffer.limit(actualReadFrames), buffer);
      return result.framesOut;
    });
  }

  @override
  void dispose() {
    throwIfNotAvailable();
    _isDisposed = true;
    _inputFrames.dispose();
  }
}
