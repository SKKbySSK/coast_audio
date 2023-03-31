import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

/// Convert the audio buffer into [outputFormat] if needed.
/// If [inputFormat] and [outputFormat] are same, no conversion will occurs.
/// Sample rate conversion is not supported currently.
class AudioFormatConverter {
  AudioFormatConverter({
    required this.inputFormat,
    required this.outputFormat,
  }) {
    // TODO: implement sample rate conversion
    assert(inputFormat.sampleRate == outputFormat.sampleRate);
    _sampleFormatConverter = AudioSampleFormatConverter.needsConversion(inputFormat.sampleFormat, outputFormat.sampleFormat)
        ? AudioSampleFormatConverter(inputSampleFormat: inputFormat.sampleFormat, outputSampleFormat: outputFormat.sampleFormat)
        : null;
    _channelConverter = AudioChannelConverter.needsConversion(inputFormat.channels, outputFormat.channels)
        ? AudioChannelConverter(inputChannels: inputFormat.channels, outputChannels: outputFormat.channels)
        : null;
    noConversion = _sampleFormatConverter == null && _channelConverter == null;
  }

  final AudioFormat inputFormat;

  final AudioFormat outputFormat;

  late final bool noConversion;

  late final AudioSampleFormatConverter? _sampleFormatConverter;
  late final AudioChannelConverter? _channelConverter;

  int computeInputFrames(int outputFrames) {
    return outputFrames;
  }

  int computeOutputFrames(int inputFrames) {
    return inputFrames;
  }

  /// Convert a [bufferIn] data and returns number of frames converted.
  int convert({required AudioBuffer bufferOut, required AudioBuffer bufferIn}) {
    if (noConversion) {
      bufferIn.copyTo(bufferOut);
    } else {
      _sampleFormatConverter?.convert(bufferOut: bufferOut, bufferIn: bufferIn);
      _channelConverter?.convert(bufferOut: bufferOut, bufferIn: bufferIn);
    }
    return min(bufferOut.sizeInFrames, bufferIn.sizeInFrames);
  }
}
