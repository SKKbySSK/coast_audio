import 'package:coast_audio/coast_audio.dart';

class AudioGraph extends AsyncDisposable {
  AudioGraph({
    required Map<String, AudioNode> nodes,
    required GraphNode graphNode,
    required AudioTask task,
    required DisposableBag disposableBag,
  })  : _nodes = nodes,
        _graphNode = graphNode,
        _task = task,
        _disposableBag = disposableBag;

  final Map<String, AudioNode> _nodes;
  final GraphNode _graphNode;
  final AudioTask _task;
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
        _graphNode.disconnect(connectedBus);
        _graphNode.connect(connectedBus, newNode.inputs[i]);
      }
    }

    // Swap output busses
    for (var i = 0; oldNode.outputs.length > i; i++) {
      final outputBus = oldNode.outputs[i];
      final connectedBus = outputBus.connectedBus;
      if (connectedBus != null) {
        _graphNode.disconnect(outputBus);
        _graphNode.connect(newNode.outputs[i], connectedBus);
      }
    }

    _nodes[identifier] = newNode;

    return oldNode;
  }

  bool get isStarted => _task.isStarted;

  void start() => _task.start();

  void stop() => _task.stop();

  @override
  bool get isDisposing => _disposableBag.isDisposing;

  @override
  bool get isDisposed => _disposableBag.isDisposed;

  @override
  Future<void> dispose() {
    for (final node in _nodes.values) {
      for (final outputBus in node.outputs) {
        _graphNode.disconnect(outputBus);
      }
    }
    return _disposableBag.dispose();
  }
}
