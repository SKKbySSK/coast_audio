import '../interop/internal/generated/bindings.dart';

enum AudioDeviceType {
  playback(ma_device_type.ma_device_type_playback),
  capture(ma_device_type.ma_device_type_capture);

  const AudioDeviceType(this.caValue);
  final int caValue;
}
