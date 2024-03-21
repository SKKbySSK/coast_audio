import 'dart:ffi';
import 'dart:typed_data';

import 'package:coast_audio/src/interop/internal/generated/bindings.dart';

/// A unique identifier for an audio device.
class AudioDeviceId {
  const AudioDeviceId(this.data);

  AudioDeviceId.fromPointer(Pointer<ca_device_id> pId, int size) : data = Uint8List(size) {
    final pRawData = pId.cast<Uint8>();
    for (var i = 0; i < size; i++) {
      data[i] = pRawData[i];
    }
  }

  /// The raw data of the identifier.
  final Uint8List data;
}
