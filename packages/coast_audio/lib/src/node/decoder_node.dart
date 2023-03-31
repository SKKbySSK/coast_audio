import 'package:coast_audio/coast_audio.dart';

typedef DecodeResultListener = void Function(AudioDecodeResult result);

class DecoderNode extends DataSourceNode with SyncDisposableNodeMixin {
  DecoderNode({required this.decoder}) {
    setOutputs([outputBus]);
  }

  final AudioDecoder decoder;

  final _listeners = <DecodeResultListener>[];

  void addListener(DecodeResultListener listener) {
    throwIfNotAvailable();
    _listeners.add(listener);
  }

  void removeListener(DecodeResultListener listener) {
    throwIfNotAvailable();
    _listeners.remove(listener);
  }

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => decoder.outputFormat);

  @override
  List<SampleFormat> get supportedSampleFormats => [decoder.outputFormat.sampleFormat];

  @override
  int read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final result = decoder.decode(destination: buffer);
    for (var listener in _listeners) {
      listener(result);
    }

    return result.frames;
  }

  var _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    _isDisposed = true;
    _listeners.clear();
  }
}
