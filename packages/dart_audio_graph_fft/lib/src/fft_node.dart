import 'dart:math';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';

typedef FftCompletedCallback = void Function(FftResult result);

class FftNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  FftNode({
    required this.fftBuffer,
    required this.onFftCompleted,
    this.window,
  });
  final FftBuffer fftBuffer;

  Float64List? window;

  FftCompletedCallback? onFftCompleted;

  @override
  List<SampleFormat> get supportedSampleFormats => [SampleFormat.float32];

  @override
  int process(RawFrameBuffer buffer) {
    final callback = onFftCompleted;
    if (callback == null) {
      return buffer.sizeInFrames;
    }

    var processedFrames = 0;
    while (processedFrames < buffer.sizeInFrames) {
      final framesRead = min(buffer.sizeInFrames - processedFrames, fftBuffer.capacity - fftBuffer.length);
      final framesWritten = fftBuffer.write(buffer.offset(processedFrames).limit(framesRead));
      processedFrames += framesWritten;

      if (fftBuffer.isReady) {
        callback(fftBuffer.inPlaceFft(window));
      }
    }

    return processedFrames;
  }
}
