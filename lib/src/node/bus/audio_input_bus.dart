import 'package:coast_audio/coast_audio.dart';

/// A callback that resolves the format of the [AudioInputBus].
typedef InputFormatResolver = AudioFormat? Function(AudioInputBus bus);

/// When a [AudioOutputBus] is trying to connect to [AudioInputBus], this callback will be called.
///
/// You can throw an exception to prevent the connection.
typedef AttemptConnectBusCallback = void Function(AudioOutputBus bus);

/// [AudioInputBus] represents a audio node's input format and connection.
class AudioInputBus extends AudioBus {
  AudioInputBus({
    required AudioNode node,
    required InputFormatResolver formatResolver,
    AttemptConnectBusCallback? attemptConnectBus,
  })  : _formatResolver = formatResolver,
        _attemptConnectBus = attemptConnectBus,
        super(node: node);

  /// Create a [AudioInputBus] with auto format resolution.
  factory AudioInputBus.autoFormat({
    required AudioNode node,
    AttemptConnectBusCallback? attemptConnectBus,
  }) {
    return AudioInputBus(
      node: node,
      formatResolver: (bus) => bus.connectedBus?.resolveFormat(),
      attemptConnectBus: attemptConnectBus,
    );
  }

  final InputFormatResolver _formatResolver;

  final AttemptConnectBusCallback? _attemptConnectBus;

  @override
  AudioFormat? resolveFormat() => _formatResolver(this);

  AudioOutputBus? _connectedBus;

  /// The connected [AudioOutputBus] of this bus.
  ///
  /// [connectedBus]'s format must be the same as this bus's format.
  AudioOutputBus? get connectedBus => _connectedBus;
}

extension InternalAudioInputBusExtension on AudioInputBus {
  void tryConnect(AudioOutputBus bus) {
    _attemptConnectBus?.call(bus);
    _connectedBus = bus;
  }

  void onDisconnect() {
    _connectedBus = null;
  }
}
