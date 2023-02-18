import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_extension.dart';
import 'package:ffi/ffi.dart';

class MabDeviceInfo extends MabBase {
  MabDeviceInfo({
    mab_device_info? info,
    Memory? memory,
  }) : super(memory: memory) {
    if (info != null) {
      pDeviceInfo.ref = info;
    }
  }

  late final pDeviceInfo = allocate<mab_device_info>(sizeOf<mab_device_info>());
  late final MabDeviceId id = MabDeviceId(id: pDeviceInfo.ref.id, memory: memory);

  String? _name;
  String get name {
    if (_name == null) {
      const int maxLength = 256;
      final pName = allocate<Utf8>(sizeOf<Char>() * maxLength);
      for (var i = 0; maxLength > i; i++) {
        pName.cast<Char>().elementAt(i).value = pDeviceInfo.ref.name[i];
      }
      _name = pName.toDartString();
    }

    return _name!;
  }

  bool get isDefault => pDeviceInfo.ref.isDefault.toBool();

  @override
  void uninit() {
    id.dispose();
  }

  @override
  String toString() {
    return 'MabDeviceInfo(name: $name, isDefault: $isDefault)';
  }
}

class MabDeviceId extends MabBase {
  MabDeviceId({
    mab_device_id? id,
    Memory? memory,
  }) : super(memory: memory) {
    if (id != null) {
      pDeviceId.ref = id;
    }
  }

  late final pDeviceId = allocate<mab_device_id>(sizeOf<mab_device_id>());

  String get stringId => pDeviceId.cast<Utf8>().toDartString();

  int get intId => pDeviceId.cast<Int>().value;

  int get uintId => pDeviceId.cast<UnsignedInt>().value;

  String get coreAudio => stringId;

  int get jack => intId;

  int get aaudio => intId;

  int get openSl => uintId;

  int get nullBackend => intId;

  MabDeviceId copyWith({
    mab_device_id? id,
    Memory? memory,
  }) {
    return MabDeviceId(
      id: id ?? pDeviceId.ref,
      memory: memory ?? this.memory,
    );
  }

  @override
  void uninit() {}
}
