import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

extension AudioFrameExtension on AudioFrames {
  T acquireBuffer<T>(T Function(AudioBuffer buffer) callback) {
    try {
      return callback(lock());
    } finally {
      unlock();
    }
  }
}

extension AudioBufferExtension on AudioBuffer {
  void fillBytes(int data, {int? frames}) {
    if (frames == null) {
      memory.setMemory(pBuffer.cast(), data, sizeInBytes);
    } else {
      memory.setMemory(pBuffer.cast(), data, frames * format.bytesPerFrame);
    }
  }

  void copyTo(AudioBuffer dst, {int? frames}) {
    assert(format.sampleFormat == dst.format.sampleFormat);
    memory.copyMemory(dst.pBuffer.cast(), pBuffer.cast(), (frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  Uint8List asUint8ListViewFrames({int? frames}) {
    return pBuffer.cast<Uint8>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  Uint8List asUint8ListViewBytes({int? bytes}) {
    return pBuffer.cast<Uint8>().asTypedList(bytes ?? sizeInBytes);
  }

  Int16List asInt16ListView({int? frames}) {
    return pBuffer.cast<Int16>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  Int32List asInt32ListView({int? frames}) {
    return pBuffer.cast<Int32>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  Float32List asFloat32ListView({int? frames}) {
    return pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.channels);
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
      fillBytes(SampleFormat.uint8.mid);
      return;
    }

    final list = asUint8ListViewFrames(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = ((list[i] - SampleFormat.uint8.mid) * volume).toInt() + SampleFormat.uint8.mid;
    }
  }

  void applyInt16Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fillBytes(0);
      return;
    }

    final list = asInt16ListView(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  void applyInt32Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fillBytes(0);
      return;
    }

    final list = asInt32ListView(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  void applyFloat32Volume(double volume, {int? frames}) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fillBytes(0);
      return;
    }

    final floatList = asFloat32ListView(frames: frames);
    for (var i = 0; floatList.length > i; i++) {
      floatList[i] *= volume;
    }
  }

  void clamp({int? frames}) {
    List<num> bufferList;
    switch (format.sampleFormat) {
      case SampleFormat.float32:
        bufferList = asFloat32ListView(frames: frames);
        break;
      case SampleFormat.int16:
        bufferList = asInt16ListView(frames: frames);
        break;
      case SampleFormat.int32:
        bufferList = asInt32ListView(frames: frames);
        break;
      case SampleFormat.uint8:
        bufferList = asUint8ListViewFrames(frames: frames);
        break;
    }

    final maxValue = format.sampleFormat.max;
    final minValue = format.sampleFormat.min;
    for (var i = 0; bufferList.length > i; i++) {
      bufferList[i] = min(maxValue, max(minValue, bufferList[i]));
    }
  }
}
