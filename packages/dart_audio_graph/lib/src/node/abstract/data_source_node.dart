import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class DataSourceNode extends AudioNode {
  final List<AudioOutputBus> _outputs = [];

  @override
  List<AudioInputBus> get inputs => const [];

  @override
  List<AudioOutputBus> get outputs => List.unmodifiable(_outputs);

  void setOutputs(Iterable<AudioOutputBus> outputs) {
    _outputs
      ..clear()
      ..addAll(outputs);
  }
}
