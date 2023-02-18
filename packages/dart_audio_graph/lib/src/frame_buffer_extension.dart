import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

extension FrameBufferExtension on FrameBuffer {
  void fill(int data) {
    acquireBuffer((pBuffer) {
      memory.setMemory(pBuffer.cast(), data, sizeInBytes);
    });
  }

  void copy(FrameBuffer dst, int sizeInFrames) {
    acquireBuffer((pSrc) {
      dst.acquireBuffer((pDst) {
        memory.copyMemory(pDst.cast(), pSrc.cast(), sizeInFrames * format.bytesPerFrame);
      });
    });
  }

  T acquireUint8ListView<T>(T Function(Uint8List list) callback, {int? frames}) {
    return acquireBuffer((pBuffer) {
      return callback(pBuffer.cast<Uint8>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame * format.bytesPerFrame));
    });
  }

  T acquireFloatListView<T>(T Function(Float32List list) callback, {int? frames}) {
    return acquireBuffer((pBuffer) {
      return callback(pBuffer.cast<Float>().asTypedList((frames ?? sizeInFrames) * format.samplesPerFrame));
    });
  }

  Float32List copyFloatList({int? frames, bool deinterleave = false}) {
    return acquireFloatListView((list) {
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
    });
  }

  void applyVolume(double volume) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      fill(0);
      return;
    }

    acquireFloatListView((list) {
      for (var i = 0; list.length > i; i++) {
        list[i] *= volume;
      }
    });
  }
}
