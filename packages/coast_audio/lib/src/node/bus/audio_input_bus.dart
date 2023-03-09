import 'package:coast_audio/coast_audio.dart';

typedef InputFormatResolver = AudioFormat? Function(AudioInputBus bus);

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
