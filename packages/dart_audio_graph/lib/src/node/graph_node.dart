import 'package:dart_audio_graph/dart_audio_graph.dart';

class GraphNode extends PassthroughNode {
  final _connections = <AudioOutputBus, AudioInputBus>{};

  bool canConnect(AudioOutputBus outputBus, AudioInputBus inputBus) {
    final outputFormat = outputBus.format;
    final inputFormat = inputBus.format;

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
    outputBus.node.onOutputConnected(inputBus.node, outputBus, inputBus);
    inputBus.node.onInputConnected(outputBus.node, outputBus, inputBus);
  }

  void connectEndpoint(AudioOutputBus outputBus) {
    connect(outputBus, inputBus);
  }

  bool disconnect(AudioOutputBus outputBus) {
    final inputBus = _connections.remove(outputBus);
    if (inputBus == null) {
      return false;
    }

    inputBus.onDisconnect();
    outputBus.onDisconnect();
    outputBus.node.onOutputDisconnected(inputBus.node, outputBus, inputBus);
    inputBus.node.onInputDisconnected(outputBus.node, outputBus, inputBus);

    return true;
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
