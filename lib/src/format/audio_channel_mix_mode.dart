import '../interop/internal/generated/bindings.dart';

enum AudioChannelMixMode {
  simple(ma_channel_mix_mode.ma_channel_mix_mode_simple),
  rectangular(ma_channel_mix_mode.ma_channel_mix_mode_rectangular);

  const AudioChannelMixMode(this.maValue);
  final int maValue;
}
