import 'package:dart_audio_graph/dart_audio_graph.dart';

typedef FormatResolver = AudioFormat? Function(AudioBus bus);

abstract class AudioBus {
  AudioBus({
    required this.node,
    required FormatResolver formatResolver,
  }) : _formatResolver = formatResolver;

  final AudioNode node;
  AudioBus? _connectedBus;
  final FormatResolver _formatResolver;

  AudioBus? get connectedBus => _connectedBus;

  AudioFormat? resolveFormat() => _formatResolver(this);

  void onConnect(AudioBus bus) {
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
    required FormatResolver formatResolver,
  }) : super(node: node, formatResolver: formatResolver);

  factory AudioInputBus.anyFormat({required AudioNode node}) {
    return AudioInputBus(
      node: node,
      formatResolver: (bus) => bus.connectedBus?.resolveFormat(),
    );
  }

  @override
  int read(FrameBuffer buffer) {
    assert(connectedBus != null);
    return connectedBus!.read(buffer);
  }
}

class AudioOutputBus extends AudioBus {
  AudioOutputBus({
    required AudioNode node,
    required FormatResolver formatResolver,
  }) : super(node: node, formatResolver: formatResolver);

  AudioOutputBus.anyFormat({required AnyFormatNodeMixin node}) : this(node: node, formatResolver: (_) => node.currentInputFormat);

  @override
  int read(FrameBuffer buffer) {
    return node.read(this, buffer);
  }
}
