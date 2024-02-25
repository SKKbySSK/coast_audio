import 'package:coast_audio/coast_audio.dart';

mixin SingleInNodeMixin on AudioNode {
  @override
  List<AudioInputBus> get inputs => [inputBus];

  AudioInputBus get inputBus;
}

mixin SingleOutNodeMixin on AudioNode {
  @override
  List<AudioOutputBus> get outputs => [outputBus];

  AudioOutputBus get outputBus;
}
