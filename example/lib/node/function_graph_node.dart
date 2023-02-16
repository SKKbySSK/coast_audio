import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';

class FunctionGraphNode extends DataSourceNode {
  FunctionGraphNode({
    required this.format,
    required WaveFunction function,
    required this.onRead,
    required void Function(FftResult result) onFftCompleted,
  })  : _functionNode = FunctionNode(function: function, format: format, frequency: 440),
        _volumeNode = VolumeNode(volume: 0.4),
        _fftNode = FftNode(frames: 512, onFftCompleted: onFftCompleted),
        _graphNode = GraphNode() {
    _graphNode.connect(_functionNode.outputBus, _volumeNode.inputBus);
    _graphNode.connect(_volumeNode.outputBus, _fftNode.inputBus);
    _graphNode.connectEndpoint(_fftNode.outputBus);
    setOutputs([outputBus]);
  }

  final AudioFormat format;

  final void Function(FrameBuffer buffer) onRead;

  final FunctionNode _functionNode;
  final VolumeNode _volumeNode;
  final FftNode _fftNode;
  final GraphNode _graphNode;

  double get frequency => _functionNode.frequency;

  set frequency(double freq) => _functionNode.frequency = freq;

  double get volume => _volumeNode.volume;

  set volume(double vol) => _volumeNode.volume = vol;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final readFrames = _graphNode.outputBus.read(buffer);
    onRead(buffer.limit(readFrames));
    return readFrames;
  }
}
