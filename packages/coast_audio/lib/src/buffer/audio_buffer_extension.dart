import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

extension AudioFrameExtension on AudioFrames {
  /// Locks the AudioFrames and returns the internal buffer.
  ///
  /// When the callback is finished, the buffer is unlocked automatically.
  T acquireBuffer<T>(T Function(AudioBuffer buffer) callback) {
    try {
      return callback(lock());
    } finally {
      unlock();
    }
  }
}

extension AudioBufferExtension on AudioBuffer {
  /// Fills the buffer with the specified data.
  void fillBytes(int data, {int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    memory.setMemory(pBuffer.cast(), data, (frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  /// Copy the buffer into the [dst] buffer.
  void copyTo(AudioBuffer dst, {int? frames}) {
    assert(format.sampleFormat == dst.format.sampleFormat);
    assert((frames ?? sizeInFrames) <= dst.sizeInFrames);
    memory.copyMemory(dst.pBuffer.cast(), pBuffer.cast(), (frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  /// Treats the buffer as a list of [Uint8] and returns it.
  ///
  /// If [frames] is specified, the returned list is limited to the specified number of frames.
  /// Modified data is reflected in the buffer.
  Uint8List asUint8ListViewFrames({int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    return pBuffer.cast<Uint8>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  /// Treats the buffer as a list of [Uint8] and returns it.
  ///
  /// If [bytes] is specified, the returned list is limited to the specified number of bytes.
  /// Modified data is reflected in the buffer.
  Uint8List asUint8ListViewBytes({int? bytes}) {
    assert((bytes ?? sizeInBytes) <= sizeInBytes);
    return pBuffer.cast<Uint8>().asTypedList(bytes ?? sizeInBytes);
  }

  /// Treats the buffer as a list of [Int16] and returns it.
  ///
  /// If [frames] is specified, the returned list is limited to the specified number of frames.
  /// Modified data is reflected in the buffer.
  Int16List asInt16ListView({int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    return pBuffer.cast<Int16>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  /// Treats the buffer as a list of [Int32] and returns it.
  ///
  /// If [frames] is specified, the returned list is limited to the specified number of frames.
  /// Modified data is reflected in the buffer.
  Int32List asInt32ListView({int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    return pBuffer.cast<Int32>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  /// Treats the buffer as a list of [Float32] and returns it.
  ///
  /// If [frames] is specified, the returned list is limited to the specified number of frames.
  /// Modified data is reflected in the buffer.
  Float32List asFloat32ListView({int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    return pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.channels);
  }

  /// Copy the buffer as a list of [Float32] and returns it.
  ///
  /// If [frames] is specified, the returned list is limited to the specified number of frames.
  /// If [deinterleave] is true, the returned list contains deinterleaved audio data.
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

  /// Apply [volume] to the buffer while treating its sample format as [SampleFormat.uint8].
  ///
  /// You can specify the [volume] outside the range of 0.0 to 1.0.
  /// If [frames] is specified, volume is applied only to the specified number of frames.
  void applyUint8Volume(double volume, {int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fillBytes(SampleFormat.uint8.mid.toInt());
      return;
    }

    final list = asUint8ListViewFrames(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  /// Apply [volume] to the buffer while treating its sample format as [SampleFormat.int16].
  ///
  /// You can specify the [volume] outside the range of 0.0 to 1.0.
  /// If [frames] is specified, volume is applied only to the specified number of frames.
  void applyInt16Volume(double volume, {int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      memory.zeroMemory(pBuffer.cast(), sizeInBytes);
      return;
    }

    final list = asInt16ListView(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  /// Apply [volume] to the buffer while treating its sample format as [SampleFormat.int32].
  ///
  /// You can specify the [volume] outside the range of 0.0 to 1.0.
  /// If [frames] is specified, volume is applied only to the specified number of frames.
  void applyInt32Volume(double volume, {int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      memory.zeroMemory(pBuffer.cast(), sizeInBytes);
      return;
    }

    final list = asInt32ListView(frames: frames);
    for (var i = 0; list.length > i; i++) {
      list[i] = (list[i] * volume).toInt();
    }
  }

  /// Apply [volume] to the buffer while treating its sample format as [SampleFormat.float32].
  ///
  /// You can specify the [volume] outside the range of 0.0 to 1.0.
  /// If [frames] is specified, volume is applied only to the specified number of frames.
  void applyFloat32Volume(double volume, {int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      memory.zeroMemory(pBuffer.cast(), sizeInBytes);
      return;
    }

    final floatList = asFloat32ListView(frames: frames);
    for (var i = 0; floatList.length > i; i++) {
      floatList[i] *= volume;
    }
  }

  /// Clamp buffer values to the valid range of the sample format.
  ///
  /// e.g. If the sample format is [SampleFormat.float32], the value is clamped to the range of -1.0 to 1.0.
  void clamp({int? frames}) {
    assert((frames ?? sizeInFrames) <= sizeInFrames);

    final List<num> bufferList;
    switch (format.sampleFormat) {
      case SampleFormat.float32:
        bufferList = asFloat32ListView(frames: frames);
      case SampleFormat.int16:
        bufferList = asInt16ListView(frames: frames);
      case SampleFormat.int32:
        bufferList = asInt32ListView(frames: frames);
      case SampleFormat.uint8:
        bufferList = asUint8ListViewFrames(frames: frames);
    }

    final maxValue = format.sampleFormat.max;
    final minValue = format.sampleFormat.min;
    for (var i = 0; bufferList.length > i; i++) {
      bufferList[i] = min(maxValue, max(minValue, bufferList[i]));
    }
  }
}
