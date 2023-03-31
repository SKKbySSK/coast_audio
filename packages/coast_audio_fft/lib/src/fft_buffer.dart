import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_fft/coast_audio_fft.dart';

class FftBuffer extends SyncDisposable {
  FftBuffer(
    this.format,
    int size,
  )   : assert((size & (size - 1)) == 0, 'size must be power of two.'),
        _complexArray = Float64x2List(size),
        _fft = FFT(size),
        _ringBuffer = FrameRingBuffer(frames: size, format: format),
        _buffer = AllocatedAudioFrames(frames: size, format: format);

  final AudioFormat format;

  final Float64x2List _complexArray;
  final FFT _fft;
  final FrameRingBuffer _ringBuffer;
  final AllocatedAudioFrames _buffer;

  late final AudioBuffer _rawBuffer = _buffer.lock();

  int get length => _ringBuffer.length;

  int get capacity => _ringBuffer.capacity;

  bool get isReady => _ringBuffer.length == _ringBuffer.capacity;

  int write(AudioBuffer buffer, [bool mixChannels = true]) {
    if (mixChannels && buffer.format.channels > 1) {
      final dstBuffer = AllocatedAudioFrames(frames: buffer.sizeInFrames, format: format.copyWith(channels: 1));
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

  FftResult inPlaceFft([Float64List? window, bool copy = true]) {
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
      complexArray: copy ? Float64x2List.fromList(_complexArray) : _complexArray,
    );
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
