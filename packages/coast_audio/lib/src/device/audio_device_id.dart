import 'dart:ffi';
import 'dart:typed_data';

class AudioDeviceId {
  const AudioDeviceId(this.data);

  AudioDeviceId.fromPointer(Pointer<Uint8> pId, int size) : data = Uint8List(size) {
    for (var i = 0; i < size; i++) {
      data[i] = pId[i];
    }
  }

  final Uint8List data;
}
