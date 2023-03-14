import 'dart:ffi';

import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class CoreAudioDevice extends DeviceInfo<String> {
  const CoreAudioDevice({
    required super.id,
    required super.name,
    required super.type,
    required super.isDefault,
  }) : super(backend: MabBackend.coreAudio);

  factory CoreAudioDevice.fromMabDeviceInfo(MabDeviceInfo info, MabDeviceType type) {
    return CoreAudioDevice(
      id: info.id.coreAudio,
      name: info.name,
      type: type,
      isDefault: info.isDefault,
    );
  }

  @override
  void fillInfo(MabDeviceInfo info) {
    info.pDeviceInfo.ref.id.coreaudio.setString(id);
    info.pDeviceInfo.ref.name.setString(name);
    info.id.stringId = id;
  }
}
