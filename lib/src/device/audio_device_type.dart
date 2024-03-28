import '../interop/internal/generated/bindings.dart';

/// The type of the audio device.
enum AudioDeviceType {
  /// Playback device such as speakers.
  playback(ma_device_type.ma_device_type_playback),

  /// Capture device such as microphone.
  capture(ma_device_type.ma_device_type_capture);

  const AudioDeviceType(this.maValue);
  final int maValue;
}
