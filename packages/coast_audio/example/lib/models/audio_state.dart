import 'package:coast_audio/coast_audio.dart';

sealed class AudioState {
  const AudioState();
}

final class AudioStateInitial extends AudioState {
  const AudioStateInitial();
}

final class AudioStateConfigured extends AudioState {
  const AudioStateConfigured({
    required this.deviceContext,
    required this.inputDevice,
    required this.outputDevice,
  });

  final AudioDeviceContext deviceContext;
  final AudioDeviceInfo? inputDevice;
  final AudioDeviceInfo? outputDevice;
}
