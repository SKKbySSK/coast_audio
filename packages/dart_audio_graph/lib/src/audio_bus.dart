import 'package:dart_audio_graph/dart_audio_graph.dart';

typedef InputFormatResolver = AudioFormat? Function(AudioInputBus bus);
typedef OutputFormatResolver = AudioFormat? Function(AudioOutputBus bus);

abstract class AudioBus {
  AudioBus({required this.node});

  final AudioNode node;

  AudioFormat? resolveFormat();
}

class AudioInputBus extends AudioBus {
  AudioInputBus({
    required AudioNode node,
    required InputFormatResolver formatResolver,
  })  : _formatResolver = formatResolver,
        super(node: node);

  factory AudioInputBus.autoFormat({required AudioNode node}) {
    return AudioInputBus(
      node: node,
      formatResolver: (bus) => bus.connectedBus?.resolveFormat(),
    );
  }

  final InputFormatResolver _formatResolver;

  @override
  AudioFormat? resolveFormat() => _formatResolver(this);

  AudioOutputBus? _connectedBus;
  AudioOutputBus? get connectedBus => _connectedBus;

  void onConnect(AudioOutputBus bus) {
    _connectedBus = bus;
  }

  void onDisconnect() {
    _connectedBus = null;
  }
}

class AudioOutputBus extends AudioBus {
  AudioOutputBus({
    required AudioNode node,
    required OutputFormatResolver formatResolver,
  })  : _formatResolver = formatResolver,
        super(node: node);

  AudioOutputBus.autoFormat({required AutoFormatNodeMixin node}) : this(node: node, formatResolver: (_) => node.currentOutputFormat);

  final OutputFormatResolver _formatResolver;

  @override
  AudioFormat? resolveFormat() => _formatResolver(this);

  AudioInputBus? _connectedBus;
  AudioInputBus? get connectedBus => _connectedBus;

  void onConnect(AudioInputBus bus) {
    _connectedBus = bus;
  }

  void onDisconnect() {
    _connectedBus = null;
  }

  int read(RawFrameBuffer buffer) {
    return node.read(this, buffer);
  }
}
