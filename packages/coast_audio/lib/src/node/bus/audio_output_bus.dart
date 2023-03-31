import 'package:coast_audio/coast_audio.dart';

typedef OutputFormatResolver = AudioFormat? Function(AudioOutputBus bus);

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

  int read(AudioBuffer buffer) {
    return node.read(this, buffer);
  }
}
