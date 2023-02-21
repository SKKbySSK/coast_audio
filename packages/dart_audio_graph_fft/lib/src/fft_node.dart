import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:fftea/fftea.dart';

class FftNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin {
  FftNode({
    required this.frames,
    this.onResult,
    this.noCopy = true,
  });

  final int frames;
  final bool noCopy;

  void Function(FftResult result)? onResult;

  FftBuffer? _fftBuffer;

  int get bufferedFrames => _fftBuffer?._ringBuffer.length ?? 0;

  @override
  List<SampleFormat> get supportedSampleFormats => [SampleFormat.float32];

  @override
  int process(RawFrameBuffer buffer) {
    var fftBuffer = _fftBuffer;
    if (fftBuffer == null || !fftBuffer.format.isSameFormat(buffer.format)) {
      fftBuffer?.dispose();
      fftBuffer = FftBuffer(buffer.format, frames);
      _fftBuffer = fftBuffer;
    }

    fftBuffer.write(buffer);
    if (fftBuffer.length >= frames) {
      onResult?.call(fftBuffer.inPlaceFft(noCopy: noCopy)!);
    }
    return buffer.sizeInFrames;
  }
}

class FftBuffer {
  FftBuffer(
    this.format,
    int frames,
  )   : complexArray = Float64x2List(frames),
        _fft = FFT(frames),
        _ringBuffer = FrameRingBuffer(frames: frames, format: format),
        _buffer = AllocatedFrameBuffer(frames: frames, format: format);

  final AudioFormat format;
  final Float64x2List complexArray;

  final FFT _fft;
  final FrameRingBuffer _ringBuffer;
  final AllocatedFrameBuffer _buffer;

  late final RawFrameBuffer _rawBuffer = _buffer.lock();

  int get length => _ringBuffer.length;

  void write(RawFrameBuffer buffer) {
    _ringBuffer.write(buffer);
  }

  FftResult? inPlaceFft({required bool noCopy}) {
    if (_ringBuffer.length < _ringBuffer.capacity) {
      return null;
    }

    _buffer.acquireBuffer((buffer) {
      _ringBuffer.read(buffer);
    });

    final floatList = _rawBuffer.copyFloat32List(deinterleave: true);
    for (var i = 0; _buffer.sizeInFrames > i; i++) {
      complexArray[i] = Float64x2(floatList[i], 0);
    }
    _fft.inPlaceFft(complexArray);
    return FftResult(
      frames: _ringBuffer.capacity,
      format: _ringBuffer.format,
      complexArray: noCopy ? complexArray : Float64x2List.fromList(complexArray),
    );
  }

  void dispose() {
    _ringBuffer.dispose();
    _buffer
      ..unlock()
      ..dispose();
  }
}

class FftResult {
  FftResult({
    required this.frames,
    required this.format,
    required this.complexArray,
  });

  final int frames;
  final AudioFormat format;
  final Float64x2List complexArray;

  double getFrequency(int index) {
    return index * format.sampleRate / frames;
  }

  int getIndex(double frequency) {
    return (frequency * frames) ~/ format.sampleRate;
  }
}
