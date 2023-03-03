import 'dart:ffi';

import 'package:dart_audio_graph/ffi_extension.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class CoreAudioDevice extends DeviceInfo<String> {
  const CoreAudioDevice({
    required super.id,
    required super.name,
    required super.isDefault,
  }) : super(backend: MabBackend.coreAudio);

  factory CoreAudioDevice.fromMabDeviceInfo(MabDeviceInfo info) {
    return CoreAudioDevice(
      id: info.id.coreAudio,
      name: info.name,
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
