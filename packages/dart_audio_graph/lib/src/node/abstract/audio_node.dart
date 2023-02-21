import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioNode {
  AudioNode();

  List<AudioInputBus> get inputs;

  List<AudioOutputBus> get outputs;

  List<SampleFormat> get supportedSampleFormats;

  int read(AudioOutputBus outputBus, RawFrameBuffer buffer);
}
