import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_fft/coast_audio_fft.dart';

class ConvolverNode extends AutoFormatSingleInoutNode with SyncDisposableNodeMixin {
  ConvolverNode({
    required this.format,
    required AudioDecoder impulseResponseDecoder,
    required this.fftSize,
  }) {
    assert(format.isSameFormat(impulseResponseDecoder.format));

    _audioBuffer = AllocatedFrameBuffer(frames: fftSize, format: format);
    _impulseResponseFftData = _decodeImpulseResponseByChannel(impulseResponseDecoder, _fft, fftSize);
    _audioFftData = Float64x2List(fftSize);
  }

  final AudioFormat format;
  final int fftSize;

  late final AllocatedFrameBuffer _audioBuffer;
  late final _rawAudioBuffer = _audioBuffer.lock();
  late var _availableRawAudioBuffer = _rawAudioBuffer.limit(0);

  late final _fft = FFT(fftSize);
  late final List<Float64x2List> _impulseResponseFftData;
  late final Float64x2List _audioFftData;

  static List<Float64x2List> _decodeImpulseResponseByChannel(AudioDecoder decoder, FFT fft, int fftSize) {
    decoder.cursor = 0;

    final buffer = AllocatedFrameBuffer(frames: decoder.length, format: decoder.format);
    try {
      return buffer.acquireBuffer((buffer) {
        decoder.decode(destination: buffer);
        final floatData = buffer.asFloat32ListView();

        final results = <Float64x2List>[];
        for (var ch = 0; decoder.format.channels > ch; ch++) {
          results.add(Float64x2List(fftSize));
          for (var i = 0; min(fftSize, buffer.sizeInFrames) > i; i++) {
            results[ch][i] = Float64x2(floatData[ch * i], 0);
          }
          fft.inPlaceFft(results[ch]);
        }

        return results;
      });
    } finally {
      buffer.dispose();
    }
  }

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    throwIfNotAvailable();

    var framesLeft = buffer.sizeInFrames;
    while (framesLeft > 0) {
      if (_availableRawAudioBuffer.sizeInFrames == 0) {
        if (!_computeConvolution()) {
          break;
        }
      }

      final readableFrames = min(buffer.sizeInFrames, _availableRawAudioBuffer.sizeInFrames);
      _availableRawAudioBuffer.copy(buffer, frames: readableFrames);
      _availableRawAudioBuffer = _availableRawAudioBuffer.offset(readableFrames);
      framesLeft -= readableFrames;
    }

    return buffer.sizeInFrames - framesLeft;
  }

  bool _computeConvolution() {
    final readFrames = inputBus.connectedBus!.read(_rawAudioBuffer);
    if (readFrames == 0) {
      return false;
    }

    if (readFrames < fftSize) {
      // If readFrames is less than fftSize, fill the rest of the buffer with 0.
      _rawAudioBuffer.offset(readFrames).fill(0);
    }

    final audioData = _rawAudioBuffer.asFloat32ListView();

    for (var ch = 0; format.channels > ch; ch++) {
      for (var i = 0; fftSize > i; i++) {
        _audioFftData[i] = Float64x2(audioData[ch * i], 0);
      }

      _fft.inPlaceFft(_audioFftData);

      for (var i = 0; fftSize > i; i++) {
        _audioFftData[i] *= _impulseResponseFftData[ch][i];
      }

      _fft.inPlaceInverseFft(_audioFftData);

      for (var i = 0; fftSize > i; i++) {
        audioData[ch * i] = _audioFftData[i].x;
      }
    }

    _availableRawAudioBuffer = _rawAudioBuffer;

    return true;
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
    _audioBuffer
      ..unlock()
      ..dispose();
  }
}
