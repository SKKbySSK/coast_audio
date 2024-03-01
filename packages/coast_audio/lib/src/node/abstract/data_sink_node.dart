import 'package:coast_audio/coast_audio.dart';

/// [DataSourceNode] is a node that provides audio data to outputBus.
abstract class DataSinkNode extends AudioNode with SingleInNodeMixin {
  /// The format of the audio data that this node receives.
  ///
  /// If this node can receive multiple formats, you should return null.
  AudioFormat? get inputFormat;

  @override
  late final inputBus = AudioInputBus(node: this, formatResolver: (_) => inputFormat);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    final result = inputBus.connectedBus!.read(buffer);
    process(buffer.limit(result.frameCount), result.isEnd);
    return result;
  }

  void process(AudioBuffer buffer, bool isEnd);
}
