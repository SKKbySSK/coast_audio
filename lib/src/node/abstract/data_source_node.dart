import 'package:coast_audio/coast_audio.dart';

/// [DataSourceNode] is a node that provides audio data to outputBus.
abstract class DataSourceNode extends AudioNode with SingleOutNodeMixin {
  /// The format of the audio data that this node provides.
  ///
  /// If this node provides audio data with multiple formats, you should return null.
  AudioFormat? get outputFormat;

  @override
  List<AudioInputBus> get inputs => const [];

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => outputFormat);
}
