import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_fft/coast_audio_fft.dart';

class ConvolverNode extends AutoFormatSingleInoutNode with SyncDisposableNodeMixin {
  ConvolverNode({
    required this.format,
    required AudioDecoder impulseResponseDecoder,
  }) {
    assert(format.isSameFormat(impulseResponseDecoder.outputFormat));
    fftSize = _computeFftSize(impulseResponseDecoder);

    _inputBuffer = AllocatedAudioFrames(length: fftSize, format: format);
    _outputBuffer = AllocatedAudioFrames(length: fftSize, format: format);

    final irChannels = _decodeImpulseResponseByChannel(impulseResponseDecoder, FFT(fftSize));
    for (var ch = 0; format.channels > ch; ch++) {
      _convolvers.add(ChannelConvolver(
        fft: FFT(fftSize),
        impulseResponse: irChannels[ch],
      ));
    }

    _rawInputBuffer.fillBytes(0);
    _rawOutputBuffer.fillBytes(0);
  }

  final AudioFormat format;
  late final int fftSize;

  late final AllocatedAudioFrames _inputBuffer;
  late final _rawInputBuffer = _inputBuffer.lock();
  late var _readableRawInputBuffer = _rawInputBuffer.limit(0);

  late final AllocatedAudioFrames _outputBuffer;
  late final _rawOutputBuffer = _outputBuffer.lock();
  late var _readableRawOutputBuffer = _rawOutputBuffer.limit(0);

  late final List<ChannelConvolver> _convolvers = [];

  static int _computeFftSize(AudioDecoder decoder) {
    var fftSize = 2;
    while (fftSize < decoder.lengthInFrames) {
      fftSize *= 2;
    }
    return fftSize;
  }

  static List<Float64x2List> _decodeImpulseResponseByChannel(AudioDecoder decoder, FFT fft) {
    decoder.cursorInFrames = 0;

    final buffer = AllocatedAudioFrames(length: decoder.lengthInFrames, format: decoder.outputFormat);
    try {
      return buffer.acquireBuffer((buffer) {
        decoder.decode(destination: buffer);
        final scale = _computeNormalizationScale(buffer);
        final floatData = buffer.asFloat32ListView();

        final results = <Float64x2List>[];
        for (var ch = 0; decoder.outputFormat.channels > ch; ch++) {
          results.add(Float64x2List(fft.size));
          for (var i = 0; min(fft.size, buffer.sizeInFrames) > i; i++) {
            results[ch][i] = Float64x2(floatData[ch * i] * scale, 0);
          }
          fft.inPlaceFft(results[ch]);
        }

        return results;
      });
    } finally {
      buffer.dispose();
    }
  }

  static double _computeNormalizationScale(AudioBuffer buffer) {
    const gainCalibration = -58.0;
    const gainCalibrationSampleRate = 44100.0;
    const minPower = 0.000125;

    final floatData = buffer.asFloat32ListView();

    double power = 0;
    for (var ch = 0; buffer.format.channels > ch; ch++) {
      double channelPower = 0;
      for (var i = 0; buffer.sizeInFrames > i; i++) {
        channelPower += pow(floatData[ch * i], 2);
      }
      power += channelPower;
    }

    power = sqrt(power / (buffer.format.channels * buffer.sizeInFrames));

    if (power.isInfinite || power.isNaN || power < minPower) {
      power = minPower;
    }

    var scale = 1 / power;
    scale *= pow(10, gainCalibration * 0.05);

    scale *= gainCalibrationSampleRate / buffer.format.sampleRate;

    if (buffer.format.channels == 4) {
      scale *= 0.5;
    }

    return scale;
  }

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, AudioBuffer buffer) {
    throwIfNotAvailable();

    var offsetBuffer = buffer;
    while (offsetBuffer.sizeInFrames > 0) {
      if (_readableRawOutputBuffer.sizeInFrames == 0) {
        if (!_computeConvolution()) {
          break;
        }
      }

      final readableFrames = min(offsetBuffer.sizeInFrames, _readableRawOutputBuffer.sizeInFrames);
      _readableRawOutputBuffer.copyTo(offsetBuffer, frames: readableFrames);
      _readableRawOutputBuffer = _readableRawOutputBuffer.offset(readableFrames);

      offsetBuffer = offsetBuffer.offset(readableFrames);
    }

    return buffer.sizeInFrames - offsetBuffer.sizeInFrames;
  }

  bool _fillInputBuffer() {
    while (_rawInputBuffer.sizeInFrames - _readableRawInputBuffer.sizeInFrames > 0) {
      final readFrames = inputBus.connectedBus!.read(_rawInputBuffer.offset(_readableRawInputBuffer.sizeInFrames));
      if (readFrames == 0) {
        return false;
      }

      _readableRawInputBuffer = _rawInputBuffer.limit(_readableRawInputBuffer.sizeInFrames + readFrames);
    }

    return true;
  }

  bool _computeConvolution() {
    if (!_fillInputBuffer()) {
      _readableRawOutputBuffer = _rawOutputBuffer.limit(0);
      return false;
    }

    final inputBufferList = _readableRawInputBuffer.asFloat32ListView();
    final outputBufferList = _rawOutputBuffer.asFloat32ListView();

    final bufferIn = AllocatedAudioFrames(length: fftSize, format: format.copyWith(channels: 1));
    final bufferOut = AllocatedAudioFrames(length: fftSize, format: format.copyWith(channels: 1));
    final rawBufferIn = bufferIn.lock();
    final bufferInList = rawBufferIn.asFloat32ListView();
    final rawBufferOut = bufferOut.lock();
    final bufferOutList = rawBufferOut.asFloat32ListView();
    try {
      for (var ch = 0; format.channels > ch; ch++) {
        for (var frame = 0; fftSize > frame; frame++) {
          bufferInList[frame] = inputBufferList[frame * (ch + 1)];
        }
        final convolver = _convolvers[ch];
        convolver.process(rawBufferIn, rawBufferOut);
        for (var frame = 0; fftSize > frame; frame++) {
          outputBufferList[frame * (ch + 1)] = bufferOutList[frame];
        }
      }

      _readableRawInputBuffer = _rawInputBuffer.limit(0);
      _readableRawOutputBuffer = _rawOutputBuffer.limit(fftSize);
    } finally {
      bufferIn.unlock();
      bufferOut.unlock();

      bufferIn.dispose();
      bufferOut.dispose();
    }

    return true;
  }

  int computeInterleavedIndex(int sample, int channel) {
    return sample * channel;
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
    _inputBuffer
      ..unlock()
      ..dispose();
  }
}

class ChannelConvolver {
  ChannelConvolver({
    required this.fft,
    required Float64x2List impulseResponse,
    this.divisionCount = 2,
  })  : divisionSize = fft.size ~/ divisionCount,
        _irBuffer = impulseResponse,
        _inputBuffer = Float64x2List(fft.size),
        _outputBuffer = Float64x2List(fft.size),
        _overlapBuffer = Float64x2List(fft.size ~/ divisionCount),
        _lastInputBuffer = Float64List(fft.size);

  final int divisionCount;
  final int divisionSize;
  final FFT fft;

  final Float64x2List _irBuffer;
  final Float64x2List _inputBuffer;
  final Float64x2List _outputBuffer;
  final Float64x2List _overlapBuffer;
  final Float64List _lastInputBuffer;
  var _readWriteIndex = 0;

  void process(AudioBuffer bufferIn, AudioBuffer bufferOut) {
    final floatListIn = bufferIn.asFloat32ListView();
    final floatListOut = bufferOut.asFloat32ListView();

    var offsetIn = 0;
    var offsetOut = 0;

    for (var division = 0; divisionCount > division; division++) {
      for (var i = 0; divisionSize > i; i++) {
        _inputBuffer[i + _readWriteIndex] = Float64x2(floatListIn[i + offsetIn], 0);
      }

      for (var i = 0; divisionSize > i; i++) {
        floatListOut[i + offsetOut] = _outputBuffer[i + _readWriteIndex].x;
      }
      _readWriteIndex += divisionSize;

      if (_readWriteIndex == divisionSize) {
        fft.inPlaceFft(_inputBuffer);

        for (var i = 0; divisionSize > i; i++) {
          _inputBuffer[i] *= _irBuffer[i];
        }

        fft.inPlaceInverseFft(_inputBuffer);

        for (var i = 0; divisionSize > i; i++) {
          _outputBuffer[i] = _overlapBuffer[i];
        }

        for (var i = 0; divisionSize > i; i++) {
          _overlapBuffer[i] = _outputBuffer[i + divisionSize] + _inputBuffer[i + _readWriteIndex];
        }

        _readWriteIndex = 0;
      }

      for (var i = 0; floatListIn.length > i; i++) {
        _lastInputBuffer[i] = floatListIn[i];
      }

      offsetIn += divisionSize;
      offsetOut += divisionSize;
    }
  }
}
