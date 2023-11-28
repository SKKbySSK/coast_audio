import 'dart:ffi';

import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class AlsaDeviceInfo extends DeviceInfo<String> {
  const AlsaDeviceInfo({
    required super.id,
    required super.name,
    required super.type,
    required super.isDefault,
  }) : super(backend: MabBackend.alsa);

  factory AlsaDeviceInfo.fromMabDeviceInfo(
      MabDeviceInfo info, MabDeviceType type) {
    return AlsaDeviceInfo(
      id: info.id.alsa,
      name: info.name,
      type: type,
      isDefault: info.isDefault,
    );
  }

  @override
  void fillInfo(MabDeviceInfo info) {
    info.pDeviceInfo.ref.id.alsa.setString(id);
    info.pDeviceInfo.ref.name.setString(name);
    info.id.stringId = id;
  }
}
