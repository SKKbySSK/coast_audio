import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

abstract class DeviceInfo<T> {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.backend,
  });

  final T id;
  final String name;
  final MabDeviceType type;
  final bool isDefault;
  final MabBackend backend;

  void fillInfo(MabDeviceInfo info);

  MabDeviceInfo allocateMabDeviceInfo({Memory? memory}) {
    final info = MabDeviceInfo(backend: backend, memory: memory);
    fillInfo(info);
    return info;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! DeviceInfo<T> || other.backend != backend) {
      return false;
    }

    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
