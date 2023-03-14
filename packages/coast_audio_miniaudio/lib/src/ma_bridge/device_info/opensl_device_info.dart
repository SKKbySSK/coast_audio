import 'dart:ffi';

import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class OpenSLDeviceInfo extends DeviceInfo<int> {
  const OpenSLDeviceInfo({
    required super.id,
    required super.name,
    required super.type,
    required super.isDefault,
  }) : super(backend: MabBackend.openSl);

  factory OpenSLDeviceInfo.fromMabDeviceInfo(MabDeviceInfo info, MabDeviceType type) {
    return OpenSLDeviceInfo(
      id: info.id.aaudio,
      name: info.name,
      type: type,
      isDefault: info.isDefault,
    );
  }

  @override
  void fillInfo(MabDeviceInfo info) {
    info.pDeviceInfo.ref.id.aaudio = id;
    info.pDeviceInfo.ref.name.setString(name);
    info.id.uintId = id;
  }
}
