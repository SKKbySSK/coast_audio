import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';

class FftBuffer {
  FftBuffer(
    this.format,
    int size,
  )   : assert((size & (size - 1)) == 0, 'size must be power of two.'),
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

  int get capacity => _ringBuffer.capacity;

  bool get isReady => _ringBuffer.length == _ringBuffer.capacity;

  int write(RawFrameBuffer buffer, [bool mixChannels = true]) {
    if (mixChannels && buffer.format.channels > 1) {
      final dstBuffer = AllocatedFrameBuffer(frames: buffer.sizeInFrames, format: format.copyWith(channels: 1));
      final converter = AudioChannelConverter(inputChannels: buffer.format.channels, outputChannels: 1);
      try {
        return dstBuffer.acquireBuffer((dst) {
          converter.convert(bufferOut: dst, bufferIn: buffer);
          return _ringBuffer.write(dst);
        });
      } finally {
        dstBuffer.dispose();
      }
    }

    return _ringBuffer.write(buffer);
  }

  void clear() {
    _ringBuffer.clear();
  }

  FftResult inPlaceFft([Float64List? window]) {
    if (!isReady) {
      return throw const FftBufferNotReadyException();
    }

    _ringBuffer.read(_rawBuffer);
    final floatList = _rawBuffer.copyFloat32List(deinterleave: true);
    for (var i = 0; _buffer.sizeInFrames > i; i++) {
      _complexArray[i] = Float64x2(floatList[i], 0);
    }

    if (window != null) {
      window.inPlaceApplyWindow(_complexArray);
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

class FftBufferNotReadyException implements Exception {
  const FftBufferNotReadyException();

  @override
  String toString() {
    return 'FftBuffer is not ready for executing fft';
  }
}
