import 'package:coast_audio/generated/bindings.dart';

enum AudioDeviceBackend {
  coreAudio(ca_backend.ca_backend_coreaudio),
  aaudio(ca_backend.ca_backend_aaudio),
  openSLES(ca_backend.ca_backend_opensl),
  wasapi(ca_backend.ca_backend_wasapi),
  alsa(ca_backend.ca_backend_alsa),
  pulseAudio(ca_backend.ca_backend_pulseaudio),
  jack(ca_backend.ca_backend_jack);

  const AudioDeviceBackend(this.caValue);
  final int caValue;
}
