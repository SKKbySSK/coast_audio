import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';

/// Mapped enum of ma_backend.
enum MabBackend {
  // wasapi(mab_backend.mab_backend_wasapi, 'WASAPI'),
  // dsound(mab_backend.mab_backend_dsound, 'DirectSound'),
  // winmm(mab_backend.mab_backend_winmm, 'WinMM'),
  coreAudio(mab_backend.mab_backend_coreaudio, 'Core Audio'),
  // sndio(mab_backend.mab_backend_sndio, 'sndio'),
  // audio4(mab_backend.mab_backend_audio4, 'audio(4)'),
  // oss(mab_backend.mab_backend_oss, 'OSS'),
  pulseAudio(mab_backend.mab_backend_pulseaudio, 'PulseAudio'),
  alsa(mab_backend.mab_backend_alsa, 'ALSA'),
  // jack(mab_backend.mab_backend_jack, 'JACK'),
  aaudio(mab_backend.mab_backend_aaudio, 'AAudio'),
  openSl(mab_backend.mab_backend_opensl, 'OpenSL|ES');
  // webAudio(mab_backend.mab_backend_webaudio, 'Web Audio');

  const MabBackend(this.value, this.formattedName);
  factory MabBackend.fromRawValue(int backend) {
    return MabBackend.values.firstWhere((b) => b.value == backend);
  }
  final int value;
  final String formattedName;
}

/// Mapped enum of ma_dither_mode.
enum MabDitherMode {
  none(mab_dither_mode.mab_dither_mode_none),
  rectangle(mab_dither_mode.mab_dither_mode_triangle),
  triangle(mab_dither_mode.mab_dither_mode_triangle);

  const MabDitherMode(this.value);
  final int value;
}

/// Mapped enum of ma_channel_mix_mode.
enum MabChannelMixMode {
  simple(mab_channel_mix_mode.mab_channel_mix_mode_simple),
  rectangular(mab_channel_mix_mode.mab_channel_mix_mode_rectangular);

  const MabChannelMixMode(this.value);
  final int value;
}

/// Mapped enum of ma_format.
enum MabFormat {
  unknown(mab_format.mab_format_unknown),
  uint8(mab_format.mab_format_u8),
  int16(mab_format.mab_format_s16),
  int24(mab_format.mab_format_s24),
  int32(mab_format.mab_format_s32),
  float32(mab_format.mab_format_f32),
  count(mab_format.mab_format_count);

  const MabFormat(this.value);
  final int value;

  SampleFormat? get sampleFormat {
    switch (this) {
      case MabFormat.uint8:
        return SampleFormat.uint8;
      case MabFormat.int16:
        return SampleFormat.int16;
      case MabFormat.int32:
        return SampleFormat.int32;
      case MabFormat.float32:
        return SampleFormat.float32;
      case MabFormat.int24:
      case MabFormat.unknown:
      case MabFormat.count:
        return null;
    }
  }
}

/// Mapped enum of ma_device_state.
enum MabDeviceState {
  uninitialized(mab_device_state.mab_device_state_uninitialized),
  stopped(mab_device_state.mab_device_state_stopped),
  started(mab_device_state.mab_device_state_started),
  starting(mab_device_state.mab_device_state_starting),
  stopping(mab_device_state.mab_device_state_stopping);

  const MabDeviceState(this.value);
  final int value;
}

/// Mapped enum of ma_device_type.
enum MabDeviceType {
  playback(mab_device_type.mab_device_type_playback),
  capture(mab_device_type.mab_device_type_capture);

  const MabDeviceType(this.value);
  final int value;
}

/// Mapped enum of ma_device_notification_type.
enum MabDeviceNotificationType {
  started(mab_device_notification_type.mab_device_notification_type_started),
  stopped(mab_device_notification_type.mab_device_notification_type_stopped),
  rerouted(mab_device_notification_type.mab_device_notification_type_rerouted),
  interruptionBegan(mab_device_notification_type.mab_device_notification_type_interruption_began),
  interruptionEnded(mab_device_notification_type.mab_device_notification_type_interruption_ended);

  const MabDeviceNotificationType(this.value);
  final int value;
}

/// Mapped enum of ma_performance_profile.
enum MabPerformanceProfile {
  lowLatency(mab_performance_profile.mab_performance_profile_low_latency),
  conservative(mab_performance_profile.mab_performance_profile_conservative);

  const MabPerformanceProfile(this.value);
  final int value;
}

/// Mapped enum of ma_encoding_format.
enum MabEncodingFormat {
  unknown(mab_encoding_format.mab_encoding_format_unknown),
  wav(mab_encoding_format.mab_encoding_format_wav),
  flac(mab_encoding_format.mab_encoding_format_flac),
  mp3(mab_encoding_format.mab_encoding_format_mp3);

  const MabEncodingFormat(this.value);
  final int value;
}
