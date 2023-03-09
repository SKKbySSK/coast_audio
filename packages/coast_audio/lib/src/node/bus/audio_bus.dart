import 'package:coast_audio/coast_audio.dart';

abstract class AudioBus {
  AudioBus({required this.node});

  final AudioNode node;

  AudioFormat? resolveFormat();
}
