import 'dart:ffi';
import 'dart:typed_data';

/// A unique identifier for an audio device.
class AudioDeviceId {
  const AudioDeviceId(this.data);

  AudioDeviceId.fromPointer(Pointer<Uint8> pId, int size) : data = Uint8List(size) {
    for (var i = 0; i < size; i++) {
      data[i] = pId[i];
    }
  }

  /// The raw data of the identifier.
  final Uint8List data;
}
