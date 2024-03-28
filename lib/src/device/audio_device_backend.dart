import '../interop/internal/generated/bindings.dart';

/// The device backend which is used to communicate with the native audio device.
enum AudioDeviceBackend {
  /// Core Audio for macOS and iOS.
  coreAudio(ma_backend.ma_backend_coreaudio),

  /// AAudio for Android.
  aaudio(ma_backend.ma_backend_aaudio),

  /// OpenSL ES for Android.
  openSLES(ma_backend.ma_backend_opensl),

  /// WASAPI for Windows.
  wasapi(ma_backend.ma_backend_wasapi),

  /// ALSA for Linux.
  alsa(ma_backend.ma_backend_alsa),

  /// PulseAudio for Linux.
  pulseAudio(ma_backend.ma_backend_pulseaudio),

  /// JACK for Linux.
  jack(ma_backend.ma_backend_jack),

  /// Dummy backend which does nothing.
  dummy(ma_backend.ma_backend_null);

  const AudioDeviceBackend(this.maValue);
  final int maValue;
}
