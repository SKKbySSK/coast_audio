import 'package:dart_audio_graph/src/frame_buffer.dart';

import 'audio_format.dart';
import 'node/abstract/audio_node.dart';

abstract class AudioBus {
  AudioBus({
    required this.node,
    required AudioFormat? format,
  }) : _defaultFormat = format;

  final AudioNode node;
  AudioFormat? _defaultFormat;
  AudioBus? _connectedBus;

  AudioFormat? get format {
    if (_defaultFormat != null) {
      return _defaultFormat;
    }

    if (connectedBus is AudioOutputBus) {
      return connectedBus!.format;
    }

    return null;
  }

  AudioBus? get connectedBus => _connectedBus;

  void setDefaultFormat(AudioFormat? format) {
    assert(connectedBus == null);
    _defaultFormat = format;
  }

  void onConnect(AudioBus bus) {
    // TODO: assert format compatibility
    _connectedBus = bus;
  }

  void onDisconnect() {
    _connectedBus = null;
  }

  int read(FrameBuffer buffer);
}

class AudioInputBus extends AudioBus {
  AudioInputBus({
    required AudioNode node,
    required AudioFormat? format,
  }) : super(node: node, format: format);

  @override
  int read(FrameBuffer buffer) {
    assert(connectedBus != null);
    return connectedBus!.read(buffer);
  }
}

class AudioOutputBus extends AudioBus {
  AudioOutputBus({
    required AudioNode node,
    required AudioFormat? format,
  }) : super(node: node, format: format);

  @override
  int read(FrameBuffer buffer) {
    return node.read(this, buffer);
  }
}
