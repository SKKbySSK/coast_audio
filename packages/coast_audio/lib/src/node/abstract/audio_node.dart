import 'package:coast_audio/coast_audio.dart';

abstract class AudioNode {
  AudioNode();

  List<AudioInputBus> get inputs;

  List<AudioOutputBus> get outputs;

  List<SampleFormat> get supportedSampleFormats;

  int read(AudioOutputBus outputBus, RawFrameBuffer buffer);
}
