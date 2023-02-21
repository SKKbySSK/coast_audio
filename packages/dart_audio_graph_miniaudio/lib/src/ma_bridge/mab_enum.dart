import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';

enum MabBackend {
  wasapi(mab_backend.mab_backend_wasapi),
  dsound(mab_backend.mab_backend_dsound),
  winmm(mab_backend.mab_backend_winmm),
  coreAudio(mab_backend.mab_backend_coreaudio),
  sndio(mab_backend.mab_backend_sndio),
  audio4(mab_backend.mab_backend_audio4),
  oss(mab_backend.mab_backend_oss),
  pulseAudio(mab_backend.mab_backend_pulseaudio),
  alsa(mab_backend.mab_backend_alsa),
  jack(mab_backend.mab_backend_jack),
  aaudio(mab_backend.mab_backend_aaudio),
  openSl(mab_backend.mab_backend_opensl),
  webAudio(mab_backend.mab_backend_webaudio);

  const MabBackend(this.value);
  factory MabBackend.fromRawValue(int backend) {
    return MabBackend.values.firstWhere((b) => b.value == backend);
  }
  final int value;
}

enum MabDitherMode {
  none(mab_dither_mode.mab_dither_mode_none),
  rectangle(mab_dither_mode.mab_dither_mode_triangle),
  triangle(mab_dither_mode.mab_dither_mode_triangle);

  const MabDitherMode(this.value);
  final int value;
}

enum MabChannelMixMode {
  simple(mab_channel_mix_mode.mab_channel_mix_mode_simple),
  rectangular(mab_channel_mix_mode.mab_channel_mix_mode_rectangular);

  const MabChannelMixMode(this.value);
  final int value;
}

enum MabFormat {
  uint8(mab_format.mab_format_u8),
  int16(mab_format.mab_format_s16),
  int32(mab_format.mab_format_s32),
  float32(mab_format.mab_format_f32);

  const MabFormat(this.value);
  final int value;

  SampleFormat get sampleFormat {
    switch (this) {
      case MabFormat.uint8:
        return SampleFormat.uint8;
      case MabFormat.int16:
        return SampleFormat.int16;
      case MabFormat.int32:
        return SampleFormat.int32;
      case MabFormat.float32:
        return SampleFormat.float32;
    }
  }
}
