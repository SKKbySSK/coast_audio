import 'package:coast_audio/coast_audio.dart';

sealed class AudioState {
  const AudioState();
}

final class AudioStateInitial extends AudioState {
  const AudioStateInitial();
}

final class AudioStateConfigured extends AudioState {
  const AudioStateConfigured({
    required this.backend,
    required this.inputDevice,
    required this.outputDevice,
  });

  final AudioDeviceBackend backend;
  final AudioDeviceInfo? inputDevice;
  final AudioDeviceInfo? outputDevice;

  AudioStateConfigured copyWith({
    AudioDeviceBackend? backend,
    AudioDeviceInfo? inputDevice,
    AudioDeviceInfo? outputDevice,
  }) {
    return AudioStateConfigured(
      backend: backend ?? this.backend,
      inputDevice: inputDevice ?? this.inputDevice,
      outputDevice: outputDevice ?? this.outputDevice,
    );
  }
}
