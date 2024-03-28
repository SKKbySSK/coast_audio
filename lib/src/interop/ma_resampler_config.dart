import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';

extension AudioSampleRateConverterExtension on AudioSampleRateConverterConfig {
  ma_resampler_config get maConfig {
    final bindings = CoastAudioInterop().bindings;
    final self = this;
    switch (self) {
      case LinearAudioSampleRateConverterConfig():
        final config = bindings.ma_resampler_config_init(ma_format.ma_format_unknown, 0, 0, 0, ma_resample_algorithm.ma_resample_algorithm_linear);
        config.linear.lpfOrder = self.lpfOrder;
        return config;
      default:
        throw UnimplementedError('Unsupported resampler');
    }
  }
}
