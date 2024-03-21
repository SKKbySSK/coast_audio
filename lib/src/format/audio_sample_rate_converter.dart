/// NOTE: This class is not fully implemented for now and is only used for internal purposes.
/// An audio resampler for converting audio data from one sample rate to another.
abstract class AudioSampleRateConverterConfig {
  const AudioSampleRateConverterConfig();
}

/// A linear audio resampler.
class LinearAudioSampleRateConverterConfig extends AudioSampleRateConverterConfig {
  const LinearAudioSampleRateConverterConfig({this.lpfOrder = 1});

  /// The order of the low-pass filter used by the resampler.
  final int lpfOrder;
}
