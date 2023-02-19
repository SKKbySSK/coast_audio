import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

extension FrameBufferExtension on FrameBuffer {
  void fill(int data, {int? frames}) {
    acquireBuffer((buffer) {
      buffer.fill(data, frames: frames);
    });
  }

  void copy(FrameBuffer dst, {int? frames}) {
    acquireBuffer((src) {
      dst.acquireBuffer((dst) {
        src.copy(dst, frames: frames);
      });
    });
  }

  T acquireUint8ListView<T>(T Function(Uint8List list) callback, {int? frames}) {
    return acquireBuffer((buffer) {
      return callback(buffer.asUint8ListView(frames: frames));
    });
  }

  T acquireInt16ListView<T>(T Function(Int16List list) callback, {int? frames}) {
    return acquireBuffer((buffer) {
      return callback(buffer.asInt16ListView(frames: frames));
    });
  }

  T acquireInt32ListView<T>(T Function(Int32List list) callback, {int? frames}) {
    return acquireBuffer((buffer) {
      return callback(buffer.asInt32ListView(frames: frames));
    });
  }

  T acquireFloatListView<T>(T Function(Float32List list) callback, {int? frames}) {
    return acquireBuffer((buffer) {
      return callback(buffer.asFloat32ListView(frames: frames));
    });
  }

  Float32List copyFloat32List({int? frames, bool deinterleave = false}) {
    return acquireBuffer((buffer) {
      return buffer.copyFloat32List(frames: frames, deinterleave: deinterleave);
    });
  }
}

extension AcquiredFrameBufferExtension on AcquiredFrameBuffer {
  void fill(int data, {int? frames}) {
    if (frames == null) {
      memory.setMemory(pBuffer.cast(), data, sizeInBytes);
    } else {
      memory.setMemory(pBuffer.cast(), data, frames * format.bytesPerFrame);
    }
  }

  void copy(AcquiredFrameBuffer dst, {int? frames}) {
    assert(format.sampleFormat.isCompatible(dst.format.sampleFormat));
    memory.copyMemory(dst.pBuffer.cast(), pBuffer.cast(), (frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  Uint8List asUint8ListView({int? frames}) {
    return pBuffer.cast<Uint8>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
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
