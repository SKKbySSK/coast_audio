import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/ffi_extension.dart';

import '../interop/internal/generated/bindings.dart';
import '../interop/internal/ma_extension.dart';

class AudioDeviceInfo {
  const AudioDeviceInfo._init({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.type,
    required this.backend,
  });

  factory AudioDeviceInfo({
    required AudioDeviceType type,
    required AudioDeviceBackend backend,
    required void Function(Pointer<ca_device_info> handle) configure,
  }) {
    final memory = Memory();
    final pInfo = memory.allocator.allocate<ca_device_info>(sizeOf<ca_device_info>());
    try {
      configure(pInfo);

      // MEMO: Assuming id field is always the first field in ca_device_info.
      final id = switch (backend) {
        AudioDeviceBackend.coreAudio => AudioDeviceId.fromPointer(pInfo.cast(), 256),
        AudioDeviceBackend.aaudio => AudioDeviceId.fromPointer(pInfo.cast(), sizeOf<Int>()),
        AudioDeviceBackend.openSLES => AudioDeviceId.fromPointer(pInfo.cast(), sizeOf<Int>()),
        AudioDeviceBackend.wasapi => AudioDeviceId.fromPointer(pInfo.cast(), 256),
        AudioDeviceBackend.alsa => AudioDeviceId.fromPointer(pInfo.cast(), 256),
        AudioDeviceBackend.pulseAudio => AudioDeviceId.fromPointer(pInfo.cast(), 256),
        AudioDeviceBackend.jack => AudioDeviceId.fromPointer(pInfo.cast(), sizeOf<Int>()),
      };
      final name = pInfo.ref.name.getUtf8String(256);
      final isDefault = pInfo.ref.isDefault.asMaBool();

      return AudioDeviceInfo._init(
        id: id,
        name: name,
        isDefault: isDefault,
        type: type,
        backend: backend,
      );
    } finally {
      memory.allocator.free(pInfo);
    }
  }

  final AudioDeviceId id;

  final String name;

  final bool isDefault;

  final AudioDeviceType type;

  final AudioDeviceBackend backend;
}
