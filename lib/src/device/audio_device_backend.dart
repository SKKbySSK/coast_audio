import '../interop/internal/generated/bindings.dart';

enum AudioDeviceBackend {
  coreAudio(ma_backend.ma_backend_coreaudio),
  aaudio(ma_backend.ma_backend_aaudio),
  openSLES(ma_backend.ma_backend_opensl),
  wasapi(ma_backend.ma_backend_wasapi),
  alsa(ma_backend.ma_backend_alsa),
  pulseAudio(ma_backend.ma_backend_pulseaudio),
  jack(ma_backend.ma_backend_jack);

  const AudioDeviceBackend(this.maValue);
  final int maValue;
}
