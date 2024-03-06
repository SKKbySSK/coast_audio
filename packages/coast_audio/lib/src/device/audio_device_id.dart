import 'dart:ffi';
import 'dart:typed_data';

import '../interop/coast_audio_interop.dart';
import '../interop/generated/bindings.dart';

class AudioDeviceId extends CoastAudioInterop {
  AudioDeviceId.fromArrayChar(Array<Char> id, int size) {
    allocateTemporary<Char>(size, (ptr) {
      for (var i = 0; i < size; i++) {
        Pointer<Char>.fromAddress(ptr.address + i).value = id[i];
      }
      memory.copyMemory(_pId.cast(), ptr.cast(), sizeOf<ca_device_id>());
    });
  }
  AudioDeviceId.fromArrayWChar(Array<WChar> id, int size) {
    allocateTemporary<WChar>(size, (ptr) {
      for (var i = 0; i < size; i++) {
        Pointer<Char>.fromAddress(ptr.address + i).value = id[i];
      }
      memory.copyMemory(_pId.cast(), ptr.cast(), sizeOf<ca_device_id>());
    });
  }

  AudioDeviceId.fromInt(int id) {
    allocateTemporary<Int>(sizeOf<Int>(), (ptr) {
      ptr.value = id;
      memory.copyMemory(_pId.cast(), ptr.cast(), sizeOf<ca_device_id>());
    });
  }

  AudioDeviceId.deserialize(SerializedAudioDeviceId id) {
    _pId.cast<Uint8>().asTypedList(id.packet.length).setAll(0, id.packet);
  }

  SerializedAudioDeviceId serialize() {
    return SerializedAudioDeviceId(_pId.cast<Uint8>().asTypedList(sizeOf<ca_device_id>()));
  }

  late final _pId = allocateManaged<ca_device_id>(sizeOf<ca_device_id>());

  Pointer<ca_device_id> get handle => _pId;
}

class SerializedAudioDeviceId {
  const SerializedAudioDeviceId(this.packet);
  final Uint8List packet;
}
