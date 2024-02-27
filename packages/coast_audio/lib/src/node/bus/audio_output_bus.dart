import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/node/bus/audio_input_bus.dart';

typedef OutputFormatResolver = AudioFormat? Function(AudioOutputBus bus);

/// [AudioOutputBus] represents a audio node's output format and connection.
class AudioOutputBus extends AudioBus {
  AudioOutputBus({
    required AudioNode node,
    required OutputFormatResolver formatResolver,
  })  : _formatResolver = formatResolver,
        super(node: node);

  final OutputFormatResolver _formatResolver;

  @override
  AudioFormat? resolveFormat() => _formatResolver(this);

  AudioInputBus? _connectedBus;

  /// The connected [AudioInputBus] of this bus.
  ///
  /// [connectedBus]'s format must be the same as this bus's format.
  AudioInputBus? get connectedBus => _connectedBus;

  void connect(AudioInputBus inputBus) {
    if (node == inputBus.node) {
      throw const AudioBusConnectionException.sameNode();
    }

    if (!canConnect(inputBus)) {
      throw const AudioBusConnectionException.incompatibleFormat();
    }

    _connectedBus = inputBus;
    inputBus.onConnect(this);
  }

  void disconnect() {
    _connectedBus?.onDisconnect();
    _connectedBus = null;
  }

  bool canConnect(AudioInputBus inputBus) {
    if (node == inputBus.node) {
      return false;
    }

    final outputFormat = resolveFormat();
    final inputFormat = inputBus.resolveFormat();

    if (outputFormat == null || inputFormat == null) {
      return true;
    }

    return outputFormat.isSameFormat(inputFormat);
  }

  /// Read audio data from the associated node.
  AudioReadResult read(AudioBuffer buffer) {
    return node.read(this, buffer);
  }
}
