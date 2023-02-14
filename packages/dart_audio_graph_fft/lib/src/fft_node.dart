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

  _FftBuffer? _fftBuffer;

  int get bufferedFrames => _fftBuffer?._ringBuffer.length ?? 0;

  @override
  void onInputConnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {
    _fftBuffer = _FftBuffer(inputBus.format!, frames);
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
      fftBuffer.runFft();
      onFftCompleted(FftResult(
        frames: frames,
        format: fftBuffer.format,
        complexArray: noCopy ? fftBuffer.complexArray : Float64x2List.fromList(fftBuffer.complexArray),
      ));
    }
  }
}

class _FftBuffer {
  _FftBuffer(this.format,
      int frames,)
      : complexArray = Float64x2List(frames),
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

  void runFft() {
    _ringBuffer.read(_buffer);

    final floatList = _buffer.asFloatList();
    for (var i = 0; _buffer.sizeInFrames > i; i++) {
      complexArray[i] = Float64x2(floatList[i], 0);
    }
    _fft.inPlaceFft(complexArray);
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
