import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:fftea/fftea.dart';

class FftNode extends ProcessorNode {
  FftNode({
    required this.frames,
    required this.onFftCompleted,
    this.noCopy = true,
  });

  final int frames;
  final bool noCopy;
  final void Function(FftResult result) onFftCompleted;

  FftBuffer? _fftBuffer;

  int get bufferedFrames => _fftBuffer?._ringBuffer.length ?? 0;

  @override
  void onInputConnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {
    super.onInputConnected(node, outputBus, inputBus);
    _fftBuffer = FftBuffer(inputBus.resolveFormat()!, frames);
  }

  @override
  void onInputDisconnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {
    super.onInputDisconnected(node, outputBus, inputBus);
    _fftBuffer?.dispose();
    _fftBuffer = null;
  }

  @override
  void process(FrameBuffer buffer) {
    final fftBuffer = _fftBuffer;
    if (fftBuffer == null) {
      return;
    }

    fftBuffer.write(buffer);
    if (fftBuffer.length >= frames) {
      onFftCompleted(fftBuffer.inPlaceFft(noCopy: noCopy)!);
    }
  }
}

class FftBuffer {
  FftBuffer(
    this.format,
    int frames,
  )   : complexArray = Float64x2List(frames),
        _fft = FFT(frames),
        _ringBuffer = FrameRingBuffer(frames: frames, format: format),
        _buffer = FrameBuffer.allocate(frames: frames, format: format);

  final AudioFormat format;
  final Float64x2List complexArray;

  final FFT _fft;
  final FrameRingBuffer _ringBuffer;
  final FrameBuffer _buffer;

  int get length => _ringBuffer.length;

  void write(FrameBuffer buffer) {
    _ringBuffer.write(buffer);
  }

  FftResult? inPlaceFft({required bool noCopy}) {
    if (_ringBuffer.length < _ringBuffer.capacity) {
      return null;
    }

    _ringBuffer.read(_buffer);

    final floatList = _buffer.copyFloatList(deinterleave: true);
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
    _buffer.dispose();
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
