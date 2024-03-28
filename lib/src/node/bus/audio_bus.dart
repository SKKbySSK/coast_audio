import 'package:coast_audio/coast_audio.dart';

/// [AudioBus] represents a audio node's format and connection.
abstract class AudioBus {
  AudioBus({required this.node});

  /// The node that this bus belongs to.
  final AudioNode node;

  /// The format of the audio data that this bus provides.
  AudioFormat? resolveFormat();
}
