import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioFormatConverter {
  AudioFormatConverter({
    required this.inputFormat,
    required this.outputFormat,
  }) {
    // sample rate conversion is not supported currently.
    // TODO: implement sample rate conversion
    assert(inputFormat.sampleRate == outputFormat.sampleRate);
    _sampleFormatConverter = AudioSampleFormatConverter.needsConversion(inputFormat.sampleFormat, outputFormat.sampleFormat)
        ? AudioSampleFormatConverter(inputSampleFormat: inputFormat.sampleFormat, outputSampleFormat: outputFormat.sampleFormat)
        : null;
    _channelConverter = AudioChannelConverter.needsConversion(inputFormat.channels, outputFormat.channels)
        ? AudioChannelConverter(inputChannels: inputFormat.channels, outputChannels: outputFormat.channels)
        : null;
  }

  final AudioFormat inputFormat;
  final AudioFormat outputFormat;

  late final AudioSampleFormatConverter? _sampleFormatConverter;
  late final AudioChannelConverter? _channelConverter;

  int convert({required AcquiredFrameBuffer bufferOut, required AcquiredFrameBuffer bufferIn}) {
    _sampleFormatConverter?.convert(bufferOut: bufferOut, bufferIn: bufferIn);
    _channelConverter?.convert(bufferOut: bufferOut, bufferIn: bufferIn);
    return bufferOut.sizeInFrames;
  }
}
