import 'package:dart_audio_graph/dart_audio_graph.dart';

mixin AutoFormatNodeMixin on AudioNode {
  AudioFormat? get currentOutputFormat {
    if (inputs.isEmpty) {
      return null;
    }

    AudioFormat? format;
    for (var bus in inputs) {
      format = bus.connectedBus?.resolveFormat();
      if (format != null) {
        return format;
      }
    }

    return null;
  }
}
