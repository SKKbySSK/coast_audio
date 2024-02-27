import 'package:coast_audio/coast_audio.dart';

class AudioGraphBuilder {
  AudioGraphBuilder({
    required AudioClock clock,
    required AudioFormat format,
  })  : _clock = clock,
        _format = format;

  final Map<String, AudioNode> _nodes = {};
  final List<AudioGraphConnection> _connections = [];
  final List<Disposable> _disposables = [];
  String? _endpointNodeId;
  int? _endpointOutputBusIndex;
  int _readSize = 2048;
  void Function(AudioBuffer buffer)? _onRead;
  final AudioClock _clock;
  final AudioFormat _format;

  void addNode({
    required String id,
    required AudioNode node,
    bool autoDispose = true,
  }) {
    _nodes[id] = node;

    if (autoDispose && node is SyncDisposableNodeMixin) {
      addDisposable(node);
    }
  }

  void connect({
    required String outputNodeId,
    int outputBusIndex = 0,
    required String inputNodeId,
    int inputBusIndex = 0,
  }) {
    _connections.add(AudioGraphConnection(
      outputNodeId: outputNodeId,
      inputNodeId: inputNodeId,
      outputBusIndex: outputBusIndex,
      inputBusIndex: inputBusIndex,
    ));
  }

  void connectEndpoint({
    required String outputNodeId,
    int outputBusIndex = 0,
  }) {
    _endpointNodeId = outputNodeId;
    _endpointOutputBusIndex = outputBusIndex;
  }

  void setReadSize(int readSize) {
    _readSize = readSize;
  }

  void setReadCallback(void Function(AudioBuffer buffer) onRead) {
    _onRead = onRead;
  }

  void addDisposable(Disposable disposable) {
    _disposables.add(disposable);
  }

  AudioGraph build() {
    final disposableBag = DisposableBag();

    for (final connection in _connections) {
      final outputNode = _nodes[connection.outputNodeId]!;
      final inputNode = _nodes[connection.inputNodeId]!;

      outputNode.outputs[connection.outputBusIndex].connect(inputNode.inputs[connection.inputBusIndex]);
    }

    final endpointNode = _nodes[_endpointNodeId!]!;

    for (final disposable in _disposables) {
      disposableBag.add(disposable);
    }

    return AudioGraph(
      nodes: _nodes,
      task: AudioTask(
        clock: _clock,
        format: _format,
        readFrameSize: _readSize,
        endpoint: endpointNode.outputs[_endpointOutputBusIndex!],
        onRead: _onRead,
      )..disposeOn(disposableBag),
      disposableBag: disposableBag,
    );
  }
}

class AudioGraphConnection {
  AudioGraphConnection({
    required this.outputNodeId,
    required this.inputNodeId,
    required this.outputBusIndex,
    required this.inputBusIndex,
  });
  final String outputNodeId;
  final String inputNodeId;
  final int outputBusIndex;
  final int inputBusIndex;
}
