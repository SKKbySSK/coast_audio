import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioBus {
  AudioBus({required this.node});

  final AudioNode node;

  AudioFormat? resolveFormat();
}
