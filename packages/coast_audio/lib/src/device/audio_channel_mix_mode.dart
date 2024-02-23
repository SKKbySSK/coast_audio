import 'package:coast_audio/generated/bindings.dart';

enum AudioChannelMixMode {
  simple(ca_channel_mix_mode.ca_channel_mix_mode_simple),
  rectangular(ca_channel_mix_mode.ca_channel_mix_mode_rectangular);

  const AudioChannelMixMode(this.caValue);
  final int caValue;
}
