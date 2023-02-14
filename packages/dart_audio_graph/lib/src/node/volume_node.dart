import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class VolumeNode extends ProcessorNode {
  VolumeNode({required this.volume});

  double volume;

  @override
  void process(FrameBuffer buffer) {
    for (var i = 0; buffer.sizeInFrames > i; i++) {
      final pSample = buffer.offset(i).pBuffer.cast<Float>();
      for (var ch = 0; inputBus.format!.channels > ch; ch++) {
        pSample.elementAt(ch).value *= volume;
      }
    }
  }

  @override
  void onInputConnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {
    super.onInputConnected(node, outputBus, inputBus);
    this.outputBus.setDefaultFormat(inputBus.format!);
  }

  @override
  void onInputDisconnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {
    super.onInputDisconnected(node, outputBus, inputBus);
    this.outputBus.setDefaultFormat(null);
  }
}
