import 'package:coast_audio/coast_audio.dart';

/// [AudioNode] is the base class for all audio nodes.
///
/// An audio node is a node that can be connected to other audio nodes to create a audio node graph.
/// You can create a custom audio node by extending [AudioNode] and subclasses like [AudioFilterNode].
abstract class AudioNode {
  const AudioNode();

  /// The list of input buses.
  ///
  /// If you want to create a node that has only one input bus, you should mixin the [SingleInNodeMixin].
  List<AudioInputBus> get inputs;

  /// The list of output buses.
  ///
  /// If you want to create a node that has only one output bus, you should mixin the [SingleOutNodeMixin].
  List<AudioOutputBus> get outputs;

  /// Read audio data from the input bus and write audio data to the output bus.
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer);
}

/// [AudioFilterNode] is the handy base class for audio filter nodes.
///
/// If you want to create an audio filter, you should extend this class and implement the process method.
abstract class AudioFilterNode extends AudioNode with SingleInNodeMixin, SingleOutNodeMixin, ProcessorNodeMixin, BypassNodeMixin {
  AudioFilterNode();
}
