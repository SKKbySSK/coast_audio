import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioNode {
  AudioNode();

  List<AudioInputBus> get inputs;

  List<AudioOutputBus> get outputs;

  void onInputConnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {}

  void onOutputConnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {}

  void onInputDisconnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {}

  void onOutputDisconnected(AudioNode node, AudioOutputBus outputBus, AudioInputBus inputBus) {}

  int read(AudioOutputBus outputBus, FrameBuffer buffer);
}

abstract class AudioEndpointNode extends AudioNode {
  @override
  List<AudioOutputBus> get outputs => const [];
}
