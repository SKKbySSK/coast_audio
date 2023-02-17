import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class AudioFileNode extends DataSourceNode {
  AudioFileNode({
    required String filePath,
    required this.format,
    required this.onRead,
    required void Function(FftResult result) onFftCompleted,
  })  : _fileDecoderNode = MabAudioDecoderNode(decoder: MabAudioDecoder.file(filePath: filePath, format: format), isLoop: true),
        _volumeNode = VolumeNode(volume: 0.4),
        _fftNode = FftNode(frames: 512, onFftCompleted: onFftCompleted),
        _graphNode = GraphNode() {
    _graphNode.connect(_fileDecoderNode.outputBus, _volumeNode.inputBus);
    _graphNode.connect(_volumeNode.outputBus, _fftNode.inputBus);
    _graphNode.connectEndpoint(_fftNode.outputBus);
    setOutputs([outputBus]);
  }

  final AudioFormat format;

  final void Function(FrameBuffer buffer) onRead;

  final MabAudioDecoderNode _fileDecoderNode;
  final VolumeNode _volumeNode;
  final FftNode _fftNode;
  final GraphNode _graphNode;

  double get volume => _volumeNode.volume;

  set volume(double vol) => _volumeNode.volume = vol;

  int get cursor => _fileDecoderNode.decoder.cursor;

  set cursor(int value) => _fileDecoderNode.decoder.cursor = value;

  int get length => _fileDecoderNode.decoder.length;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final readFrames = _graphNode.outputBus.read(buffer);
    onRead(buffer.limit(readFrames));
    return readFrames;
  }
}
