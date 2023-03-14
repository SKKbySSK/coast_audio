import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';
import 'package:ffi/ffi.dart';

class MabDeviceInfo extends MabBase {
  MabDeviceInfo({
    required this.backend,
    mab_device_info? info,
    Memory? memory,
  }) : super(memory: memory) {
    if (info != null) {
      pDeviceInfo.ref = info;
    }
  }

  late final pDeviceInfo = allocate<mab_device_info>(sizeOf<mab_device_info>());

  late final MabDeviceId id = MabDeviceId(
    backend: backend,
    id: pDeviceInfo.ref.id,
    memory: memory,
  );

  final MabBackend backend;

  String get name => pDeviceInfo.ref.name.getString(256);

  bool get isDefault => pDeviceInfo.ref.isDefault.toBool();

  DeviceInfo<dynamic> getDeviceInfo(MabDeviceType type) {
    switch (backend) {
      case MabBackend.coreAudio:
        return CoreAudioDevice.fromMabDeviceInfo(this, type);
      case MabBackend.aaudio:
        return AAudioDeviceInfo.fromMabDeviceInfo(this, type);
      case MabBackend.openSl:
        return OpenSLDeviceInfo.fromMabDeviceInfo(this, type);
    }
  }

  @override
  void uninit() {
    id.dispose();
  }

  @override
  String toString() {
    return 'MabDeviceInfo(name: $name, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! MabDeviceInfo || other.backend != backend) {
      return false;
    }

    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MabDeviceId extends MabBase {
  MabDeviceId({
    required this.backend,
    mab_device_id? id,
    Memory? memory,
  }) : super(memory: memory) {
    if (id != null) {
      pDeviceId.ref = id;
    }
  }

  final MabBackend backend;

  late final pDeviceId = allocate<mab_device_id>(sizeOf<mab_device_id>());

  String get stringId => pDeviceId.cast<Utf8>().toDartString();
  set stringId(String value) {
    if (value.length >= 256) {
      throw Exception('device id should be less than 256 characters');
    }

    final pStr = value.toNativeUtf8(allocator: memory.allocator);
    memory.copyMemory(pDeviceId.cast(), pStr.cast(), value.length + 1);
    memory.allocator.free(pStr);
  }

  int get intId => pDeviceId.cast<Int>().value;
  set intId(int value) => pDeviceId.cast<Int>().value = value;

  int get uintId => pDeviceId.cast<UnsignedInt>().value;
  set uintId(int value) => pDeviceId.cast<UnsignedInt>().value = value;

  String get coreAudio => stringId;

  int get aaudio => intId;

  int get openSl => uintId;

  MabDeviceId copyWith({
    mab_device_id? id,
    Memory? memory,
  }) {
    return MabDeviceId(
      backend: backend,
      id: id ?? pDeviceId.ref,
      memory: memory ?? this.memory,
    );
  }

  @override
  void uninit() {}

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! MabDeviceId || other.backend != backend) {
      return false;
    }

    return hashCode == other.hashCode;
  }

  @override
  int get hashCode {
    switch (backend) {
      case MabBackend.coreAudio:
        return coreAudio.hashCode;
      case MabBackend.aaudio:
        return aaudio.hashCode;
      case MabBackend.openSl:
        return openSl.hashCode;
    }
  }
}
