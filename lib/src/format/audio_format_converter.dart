import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ma_data_converter.dart';

/// The configuration of an audio format converter.
class AudioFormatConverterConfig {
  const AudioFormatConverterConfig({
    this.ditherMode = AudioDitherMode.none,
    this.channelMixMode = AudioChannelMixMode.rectangular,
    this.resampling = const LinearAudioSampleRateConverterConfig(),
  });

  /// The dither mode used by the converter to dither the audio.
  final AudioDitherMode ditherMode;

  /// The channel mix mode used by the converter to mix the channels.
  final AudioChannelMixMode channelMixMode;

  /// The resampler configuration used by the converter to resample the audio.
  final AudioSampleRateConverterConfig resampling;
}

/// The result of an audio format conversion.
class AudioFormatConverterResult {
  const AudioFormatConverterResult({
    required this.inputFrameCount,
    required this.outputFrameCount,
  });

  /// The number of frames consumed from the input buffer.
  final int inputFrameCount;

  /// The number of frames written to the output buffer.
  final int outputFrameCount;
}

/// Converts audio data from one format to another.
class AudioFormatConverter with AudioResourceMixin {
  AudioFormatConverter({
    required this.inputFormat,
    required this.outputFormat,
    this.config = const AudioFormatConverterConfig(),
  }) {
    final captured = _native;
    setResourceFinalizer(() {
      captured.dispose();
    });
  }

  late final _native = MaDataConverter(
    inputFormat: inputFormat,
    outputFormat: outputFormat,
    config: config,
  );

  /// The input format of the audio.
  final AudioFormat inputFormat;

  /// The output format of the audio.
  final AudioFormat outputFormat;

  /// The configuration of the converter.
  final AudioFormatConverterConfig config;

  /// The input latency introduced by the converter.
  int get inputLatencyFrameCount => _native.inputLatencyFrameCount;

  /// The output latency introduced by the converter.
  int get outputLatencyFrameCount => _native.outputLatencyFrameCount;

  /// Resets the converter's internal state.
  ///
  /// This method should be called when the input audio data is discontinuous.
  void reset() => _native.reset();

  /// Gets the number of input frames required to produce [outputFrameCount] frames.
  int getRequiredInputFrameCount({required int outputFrameCount}) => _native.getRequiredInputFrameCount(outputFrameCount: outputFrameCount);

  /// Gets the number of output frames expected to be produced from [inputFrameCount] frames.
  int getExpectedOutputFrameCount({required int inputFrameCount}) => _native.getExpectedOutputFrameCount(inputFrameCount: inputFrameCount);

  /// Converts audio data format from [inputFormat] to [outputFormat] and writes the result to [output].
  AudioFormatConverterResult convert({required AudioBuffer input, required AudioBuffer output}) => _native.process(input, output);
}
