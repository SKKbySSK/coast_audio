import 'package:coast_audio/generated/bindings.dart';

enum AudioDeviceType {
  playback(ca_device_type.ca_device_type_playback),
  capture(ca_device_type.ca_device_type_capture);

  const AudioDeviceType(this.caValue);
  final int caValue;
}
