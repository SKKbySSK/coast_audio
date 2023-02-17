import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class VolumeNode extends ProcessorNode {
  VolumeNode({required this.volume});

  double volume;

  @override
  void process(FrameBuffer buffer) {
    if (volume == 1) {
      return;
    }

    if (volume == 0) {
      buffer.fillZero();
      return;
    }

    for (var i = 0; buffer.sizeInFrames > i; i++) {
      final pSample = buffer.offset(i).pBuffer.cast<Float>();
      for (var ch = 0; currentInputFormat!.channels > ch; ch++) {
        pSample.elementAt(ch).value *= volume;
      }
    }
  }
}
