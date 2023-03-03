import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

abstract class DeviceInfo<T> {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.backend,
  });

  final T id;
  final String name;
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
