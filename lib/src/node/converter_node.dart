import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

/// [ConverterNode] is a node that converts the audio data to the specified format.
class ConverterNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin {
  ConverterNode({
    required this.outputFormat,
    this.bufferFrameCount = 1024,
  });

  /// The output format of the audio data.
  final AudioFormat outputFormat;

  /// The buffer size for
  final int bufferFrameCount;

  AudioFormat? _cachedInputFormat;

  _Converter? _converter;

  _Converter _createOrGetConverter(AudioFormat inputFormat) {
    final lastConverter = _converter;
    if (lastConverter != null && lastConverter.isCompatible(inputFormat)) {
      return lastConverter;
    }

    _converter = _Converter(
      inputFormat: inputFormat,
      outputFormat: outputFormat,
      bufferFrameCount: bufferFrameCount,
    );
    return _converter!;
  }

  @override
  late final inputBus = AudioInputBus.autoFormat(
    node: this,
    attemptConnectBus: (bus) {
      // cache the input format if available
      _cachedInputFormat = bus.resolveFormat();
    },
  );

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => outputFormat);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final inputFormat = _cachedInputFormat ?? outputBus.resolveFormat();
    assert(inputFormat != null);

    final converter = _createOrGetConverter(inputFormat!);
    return converter.convert(inputBus, buffer);
  }
}

class _Converter {
  _Converter({
    required AudioFormat inputFormat,
    required AudioFormat outputFormat,
    required int bufferFrameCount,
  })  : _converter = AudioFormatConverter(
          inputFormat: inputFormat,
          outputFormat: outputFormat,
        ),
        _frames = AllocatedAudioFrames(format: inputFormat, length: bufferFrameCount);

  final AudioFormatConverter _converter;
  final AllocatedAudioFrames _frames;

  late final _inputBuffer = _frames.lock();

  bool isCompatible(AudioFormat inputFormat) => _converter.inputFormat.isSameFormat(inputFormat);

  AudioReadResult convert(AudioInputBus inputBus, AudioBuffer outputBuffer) {
    var framesRead = 0;
    var isEnd = false;
    while (framesRead < outputBuffer.sizeInFrames) {
      final readResult = inputBus.connectedBus!.read(
        _inputBuffer.limit(min(outputBuffer.sizeInFrames - framesRead, _inputBuffer.sizeInFrames)),
      );

      framesRead += readResult.frameCount;
      _converter.convert(input: _inputBuffer.limit(readResult.frameCount), output: outputBuffer.offset(framesRead));

      if (readResult.isEnd) {
        isEnd = true;
        break;
      }
    }

    return AudioReadResult(
      frameCount: framesRead,
      isEnd: isEnd,
    );
  }

  void dispose() {
    _frames.unlock();
  }
}
