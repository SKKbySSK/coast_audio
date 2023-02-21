import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

extension FrameBufferExtension on FrameBuffer {
  T acquireBuffer<T>(T Function(RawFrameBuffer buffer) callback) {
    try {
      return callback(lock());
    } finally {
      unlock();
    }
  }
}

extension AcquiredFrameBufferExtension on RawFrameBuffer {
  void fill(int data, {int? frames}) {
    if (frames == null) {
      memory.setMemory(pBuffer.cast(), data, sizeInBytes);
    } else {
      memory.setMemory(pBuffer.cast(), data, frames * format.bytesPerFrame);
    }
  }

  void copy(RawFrameBuffer dst, {int? frames}) {
    assert(format.sampleFormat.isCompatible(dst.format.sampleFormat));
    memory.copyMemory(dst.pBuffer.cast(), pBuffer.cast(), (frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  Uint8List asUint8ListViewFrames({int? frames}) {
    return pBuffer.cast<Uint8>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Uint8List asUint8ListViewBytes({int? bytes}) {
    return pBuffer.cast<Uint8>().asTypedList((bytes ?? sizeInBytes) * format.samplesPerFrame);
  }

  Int16List asInt16ListView({int? frames}) {
    return pBuffer.cast<Int16>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Int32List asInt32ListView({int? frames}) {
    return pBuffer.cast<Int32>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Float32List asFloat32ListView({int? frames}) {
    return pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Float32List copyFloat32List({int? frames, bool deinterleave = false}) {
    final floatList = asFloat32ListView(frames: frames);
    if (!deinterleave) {
      return Float32List.fromList(floatList);
    }

    final deinterleaved = Float32List(floatList.length);
    final channelSize = deinterleaved.length ~/ format.channels;
    for (var i = 0; deinterleaved.length > i; i += format.channels) {
      for (var ch = 0; format.channels > ch; ch++) {
        deinterleaved[(i ~/ format.channels) + (ch * channelSize)] = floatList[i + ch];
      }
    }
    return deinterleaved;
  }

  void applyUint8Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fill(0);
      return;
    }

    final list = asUint8ListViewFrames(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  void applyInt16Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fill(0);
      return;
    }

    final list = asInt16ListView(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  void applyInt32Volume(double volume, {int? frames}) {
    applyFloat32Volume(volume, frames: frames);
  }

  void applyFloat32Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fill(0);
      return;
    }

    final floatList = asFloat32ListView(frames: frames);
    for (var i = 0; floatList.length > i; i++) {
      floatList[i] *= volume;
    }
  }
}
