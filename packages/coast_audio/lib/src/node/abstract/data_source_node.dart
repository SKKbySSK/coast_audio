import 'package:coast_audio/coast_audio.dart';

abstract class DataSourceNode extends AudioNode with SingleOutNodeMixin {
  AudioFormat? get outputFormat;

  @override
  List<AudioInputBus> get inputs => const [];

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => outputFormat);
}
