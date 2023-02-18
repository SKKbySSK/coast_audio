import 'package:dart_audio_graph/dart_audio_graph.dart';

class GraphNode extends DataSourceNode with AutoFormatNodeMixin {
  GraphNode() {
    setOutputs([outputBus]);
  }

  @override
  AudioFormat? get currentInputFormat => _inputBus.connectedBus?.resolveFormat();

  late final _inputBus = AudioInputBus.autoFormat(node: this);

  late final outputBus = AudioOutputBus.autoFormat(node: this);

  final _connections = <AudioOutputBus, AudioInputBus>{};

  bool canConnect(AudioOutputBus outputBus, AudioInputBus inputBus) {
    final outputFormat = outputBus.resolveFormat();
    final inputFormat = inputBus.resolveFormat();

    if (outputFormat == null || inputFormat == null) {
      return true;
    }

    return outputFormat.isSameFormat(inputFormat);
  }

  void connect(AudioOutputBus outputBus, AudioInputBus inputBus) {
    if (outputBus.node == inputBus.node) {
      throw const GraphConnectionException.sameNode();
    }

    if (_connections.keys.contains(outputBus)) {
      throw const GraphConnectionException.alreadyConnectedOutput();
    }

    if (_connections.values.contains(inputBus)) {
      throw const GraphConnectionException.alreadyConnectedInput();
    }

    if (!canConnect(outputBus, inputBus)) {
      throw const GraphConnectionException.incompatibleFormat();
    }

    inputBus.onConnect(outputBus);
    outputBus.onConnect(inputBus);
    _connections[outputBus] = inputBus;
  }

  void connectEndpoint(AudioOutputBus outputBus) {
    connect(outputBus, _inputBus);
  }

  bool disconnect(AudioOutputBus outputBus) {
    final inputBus = _connections.remove(outputBus);
    if (inputBus == null) {
      return false;
    }

    inputBus.onDisconnect();
    outputBus.onDisconnect();
    return true;
  }

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    return _inputBus.connectedBus!.read(buffer);
  }
}

class GraphConnectionException implements Exception {
  const GraphConnectionException(this.message, this.code);

  const GraphConnectionException.alreadyConnectedInput()
      : message = 'input bus has already connected',
        code = -1;

  const GraphConnectionException.alreadyConnectedOutput()
      : message = 'output bus has already connected',
        code = -2;

  const GraphConnectionException.sameNode()
      : message = 'input bus and output bus have same node reference',
        code = -3;

  const GraphConnectionException.incompatibleFormat()
      : message = 'input bus and output bus have incompatible format',
        code = -4;

  final String message;
  final int code;

  @override
  String toString() {
    return message;
  }
}
