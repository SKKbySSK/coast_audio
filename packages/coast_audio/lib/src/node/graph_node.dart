import 'package:coast_audio/coast_audio.dart';

class GraphNode extends DataSourceNode with AutoFormatNodeMixin {
  GraphNode() {
    setOutputs([outputBus]);
  }

  @override
  AudioFormat? get currentOutputFormat => _inputBus.connectedBus?.resolveFormat();

  late final _inputBus = AudioInputBus.autoFormat(node: this);

  late final outputBus = AudioOutputBus.autoFormat(node: this);

  bool canConnect(AudioOutputBus outputBus, AudioInputBus inputBus) {
    final outputFormat = outputBus.resolveFormat();
    final inputFormat = inputBus.resolveFormat();

    if (outputFormat == null || inputFormat == null) {
      return outputBus.node.supportedSampleFormats.any((f) => inputBus.node.supportedSampleFormats.contains(f));
    }

    return outputFormat.isSameFormat(inputFormat);
  }

  void connect(AudioOutputBus outputBus, AudioInputBus inputBus) {
    if (outputBus.node == inputBus.node) {
      throw const GraphConnectionException.sameNode();
    }

    if (outputBus.connectedBus != null) {
      throw const GraphConnectionException.alreadyConnectedOutput();
    }

    if (inputBus.connectedBus != null) {
      throw const GraphConnectionException.alreadyConnectedInput();
    }

    if (!canConnect(outputBus, inputBus)) {
      throw const GraphConnectionException.incompatibleFormat();
    }

    inputBus.onConnect(outputBus);
    outputBus.onConnect(inputBus);
  }

  void connectEndpoint(AudioOutputBus outputBus) {
    connect(outputBus, _inputBus);
  }

  bool disconnect(AudioOutputBus outputBus) {
    final inputBus = outputBus.connectedBus;
    if (inputBus == null) {
      return false;
    }

    inputBus.onDisconnect();
    outputBus.onDisconnect();
    return true;
  }

  @override
  List<SampleFormat> get supportedSampleFormats => const [
        SampleFormat.int16,
        SampleFormat.uint8,
        SampleFormat.int32,
        SampleFormat.float32,
      ];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
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
