import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:fftea/fftea.dart';

class FftBuffer {
  FftBuffer(
    this.format,
    int size,
  )   : assert(format.channels == 1),
        assert((size & (size - 1)) == 0, 'size must be power of two.'),
        _complexArray = Float64x2List(size),
        _fft = FFT(size),
        _ringBuffer = FrameRingBuffer(frames: size, format: format),
        _buffer = AllocatedFrameBuffer(frames: size, format: format);

  final AudioFormat format;

  final Float64x2List _complexArray;
  final FFT _fft;
  final FrameRingBuffer _ringBuffer;
  final AllocatedFrameBuffer _buffer;

  late final RawFrameBuffer _rawBuffer = _buffer.lock();

  int get length => _ringBuffer.length;

  bool get isReady => _ringBuffer.length == _ringBuffer.capacity;

  int write(RawFrameBuffer buffer) {
    return _ringBuffer.write(buffer);
  }

  void clear() {
    _ringBuffer.clear();
  }

  FftResult? inPlaceFft() {
    if (!isReady) {
      return null;
    }

    _buffer.acquireBuffer((buffer) {
      _ringBuffer.read(buffer);
    });

    final floatList = _rawBuffer.copyFloat32List(deinterleave: true);
    for (var i = 0; _buffer.sizeInFrames > i; i++) {
      _complexArray[i] = Float64x2(floatList[i], 0);
    }
    _fft.inPlaceFft(_complexArray);
    return FftResult(
      frames: _ringBuffer.capacity,
      format: _ringBuffer.format,
      complexArray: Float64x2List.fromList(_complexArray),
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
