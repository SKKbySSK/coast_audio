import 'package:dart_audio_graph/dart_audio_graph.dart';

mixin AnyFormatNodeMixin on AudioNode {
  AudioFormat? get currentInputFormat {
    if (inputs.isEmpty) {
      return null;
    }

    return inputs[0].connectedBus?.resolveFormat();
  }
}
