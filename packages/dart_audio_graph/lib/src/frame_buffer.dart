import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';

class FrameBuffer {
  FrameBuffer({
    required this.pBuffer,
    required this.pBufferOrigin,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.isManaged,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  FrameBuffer.allocate({
    required int frames,
    required this.format,
  })  : pBuffer = malloc.allocate(frames * format.bytesPerFrame),
        sizeInBytes = frames * format.bytesPerFrame,
        sizeInFrames = frames,
        isManaged = true {
    pBufferOrigin = pBuffer;
  }

  final Pointer<Uint8> pBuffer;
  late final Pointer<Uint8> pBufferOrigin;
  final int sizeInBytes;
  final int sizeInFrames;
  final AudioFormat format;
  final bool isManaged;

  FrameBuffer offset(int frames) {
    return FrameBuffer(
      pBuffer: pBuffer.elementAt(format.bytesPerFrame * frames),
      pBufferOrigin: pBufferOrigin,
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      isManaged: isManaged,
    );
  }

  FrameBuffer limit(int frames) {
    return FrameBuffer(
      pBuffer: pBuffer,
      pBufferOrigin: pBufferOrigin,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      isManaged: isManaged,
    );
  }

  Uint8List asByteList({int? frames}) {
    return pBuffer.asTypedList((frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  Float32List asFloatList({int? frames}) {
    return pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Float32List toFloatList({int? frames, bool deinterleave = false}) {
    final list = asFloatList(frames: frames);
    if (!deinterleave) {
      return Float32List.fromList(list);
    }

    final deinterleaved = Float32List.fromList(list);
    final channelSize = list.length ~/ format.channels;
    for (var i = 0; list.length > i; i += format.channels) {
      for (var ch = 0; format.channels > ch; ch++) {
        deinterleaved[(i ~/ format.channels) + (ch * channelSize)] = list[i + ch];
      }
    }
    return deinterleaved;
  }

  void dispose() {
    if (isManaged) {
      malloc.free(pBufferOrigin);
    }
  }
}
