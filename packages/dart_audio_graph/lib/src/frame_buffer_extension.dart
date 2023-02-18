import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

extension FrameBufferExtension on FrameBuffer {
  Uint8List asByteList({int? frames}) {
    return pBuffer.asTypedList((frames ?? sizeInFrames) * format.bytesPerFrame);
  }

  Float32List asFloatList({int? frames}) {
    return pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame);
  }

  Float32List copyFloatList({int? frames, bool deinterleave = false}) {
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

  void applyVolume(double volume) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fill(0);
      return;
    }

    for (var i = 0; sizeInFrames > i; i++) {
      final pSample = offset(i).pBuffer.cast<Float>();
      for (var ch = 0; format.channels > ch; ch++) {
        pSample.elementAt(ch).value *= volume;
      }
    }
  }
}
