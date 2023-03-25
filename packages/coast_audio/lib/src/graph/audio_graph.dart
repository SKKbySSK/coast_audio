import 'package:coast_audio/coast_audio.dart';

class AudioGraph extends AsyncDisposable {
  AudioGraph({
    required Map<String, AudioNode> nodes,
    required this.graphNode,
    required this.task,
    required DisposableBag disposableBag,
  })  : _nodes = nodes,
        _disposableBag = disposableBag;

  final Map<String, AudioNode> _nodes;
  final GraphNode graphNode;
  final AudioTask task;
  final DisposableBag _disposableBag;

  T? findNode<T extends AudioNode>(String identifier) {
    final node = _nodes[identifier];
    if (node is T) {
      return node;
    }
    return null;
  }

  T replaceNode<T extends AudioNode>(String identifier, T newNode) {
    final oldNode = findNode<T>(identifier)!;
    assert(oldNode.inputs.length == newNode.inputs.length);
    assert(oldNode.outputs.length == newNode.outputs.length);

    // Swap input busses
    for (var i = 0; oldNode.inputs.length > i; i++) {
      final connectedBus = oldNode.inputs[i].connectedBus;
      if (connectedBus != null) {
        graphNode.disconnect(connectedBus);
        graphNode.connect(connectedBus, newNode.inputs[i]);
      }
    }

    // Swap output busses
    for (var i = 0; oldNode.outputs.length > i; i++) {
      final outputBus = oldNode.outputs[i];
      final connectedBus = outputBus.connectedBus;
      if (connectedBus != null) {
        graphNode.disconnect(outputBus);
        graphNode.connect(newNode.outputs[i], connectedBus);
      }
    }

    _nodes[identifier] = newNode;

    return oldNode;
  }

  @override
  bool get isDisposing => _disposableBag.isDisposing;

  @override
  bool get isDisposed => _disposableBag.isDisposed;

  @override
  Future<void> dispose() {
    for (final node in _nodes.values) {
      for (final outputBus in node.outputs) {
        graphNode.disconnect(outputBus);
      }
    }
    return _disposableBag.dispose();
  }
}
