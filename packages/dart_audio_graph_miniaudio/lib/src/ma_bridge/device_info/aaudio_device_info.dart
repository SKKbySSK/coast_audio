import 'dart:ffi';

import 'package:dart_audio_graph/ffi_extension.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class AAudioDeviceInfo extends DeviceInfo<int> {
  const AAudioDeviceInfo({
    required super.id,
    required super.name,
    required super.isDefault,
  }) : super(backend: MabBackend.aaudio);

  factory AAudioDeviceInfo.fromMabDeviceInfo(MabDeviceInfo info) {
    return AAudioDeviceInfo(
      id: info.id.aaudio,
      name: info.name,
      isDefault: info.isDefault,
    );
  }

  @override
  void fillInfo(MabDeviceInfo info) {
    info.pDeviceInfo.ref.id.aaudio = id;
    info.pDeviceInfo.ref.name.setString(name);
    info.id.intId = id;
  }
}
