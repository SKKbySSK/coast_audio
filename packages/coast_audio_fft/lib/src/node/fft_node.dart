import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_fft/coast_audio_fft.dart';

typedef FftCompletedCallback = void Function(FftResult result);

class FftNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin, SyncDisposableNodeMixin {
  FftNode({
    required this.format,
    required this.fftSize,
    required this.onFftCompleted,
    this.window,
  }) {
    _fftBuffer = FftBuffer(format, fftSize);
  }
  final AudioFormat format;
  final int fftSize;
  late final FftBuffer _fftBuffer;

  Float64List? window;

  FftCompletedCallback? onFftCompleted;

  @override
  List<SampleFormat> get supportedSampleFormats => [SampleFormat.float32];

  @override
  int process(AudioFrameBuffer buffer) {
    final callback = onFftCompleted;
    if (callback == null) {
      return buffer.sizeInFrames;
    }

    var processedFrames = 0;
    while (processedFrames < buffer.sizeInFrames) {
      final framesRead = min(buffer.sizeInFrames - processedFrames, _fftBuffer.capacity - _fftBuffer.length);
      final framesWritten = _fftBuffer.write(buffer.offset(processedFrames).limit(framesRead));
      processedFrames += framesWritten;

      if (_fftBuffer.isReady) {
        callback(_fftBuffer.inPlaceFft(window));
      }
    }

    return processedFrames;
  }

  var _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _fftBuffer.dispose();
  }
}
