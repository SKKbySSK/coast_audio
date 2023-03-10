import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class PlayerNode extends DataSourceNode implements SyncDisposable {
  PlayerNode({
    required this.filePath,
    required this.format,
  }) {
    _graphNode.connect(_audioDecoderNode.outputBus, _volumeNode.inputBus);
    _graphNode.connect(_volumeNode.outputBus, _controlNode.inputBus);
    _graphNode.connectEndpoint(_controlNode.outputBus);
    setOutputs([outputBus]);

    _audioDecoderNode.addListener((result) {
      if (result.isEnd && isLoop) {
        _audioDecoderNode.decoder.cursor = 0;
      }
    });
  }

  final String filePath;
  final AudioFormat format;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => format);

  late final decoder = MabAudioDecoder.file(filePath: filePath, format: format);

  double get volume => _volumeNode.volume;
  set volume(double v) => _volumeNode.volume = v;

  bool isLoop = false;

  bool get isPlaying => _controlNode.isPlaying;

  void play() => _controlNode.play();

  void pause() => _controlNode.pause();

  final _graphNode = GraphNode();
  late final _volumeNode = VolumeNode(volume: 1);
  late final _controlNode = ControlNode(isPlaying: false);
  late final _audioDecoderNode = DecoderNode(decoder: decoder);

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
    return _graphNode.outputBus.read(buffer);
  }

  @override
  bool get isDisposed => decoder.isDisposed;

  @override
  void throwIfNotAvailable([String? target]) => decoder.throwIfNotAvailable(target);

  @override
  void dispose() => decoder.dispose();
}
