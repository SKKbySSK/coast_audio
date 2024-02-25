import 'package:coast_audio/coast_audio.dart';

abstract class AudioNode {
  const AudioNode();

  List<AudioInputBus> get inputs;

  List<AudioOutputBus> get outputs;

  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer);
}

abstract class AudioFilterNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin, ProcessorNodeMixin, BypassNodeMixin {
  AudioFilterNode();
}
