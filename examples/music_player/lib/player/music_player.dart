import 'dart:io';
import 'dart:math';

import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/player/flat_top_window.dart';

class MusicPlayer extends ChangeNotifier {
  MusicPlayer({
    this.format = const AudioFormat(sampleRate: 48000, channels: 2),
    this.bufferSize = 4096,
    this.fftBufferSize = 512,
    this.onFftCompleted,
    this.onRerouted,
  }) {
    _graph.connect(_fftNode.outputBus, _volumeNode.inputBus);
    _graph.connect(_volumeNode.outputBus, _outputNode.inputBus);
    _graph.connectEndpoint(_outputNode.outputBus);
    _outputNode.device.notificationStream.listen(_onNotificationReceived);
  }

  final AudioFormat format;
  final int bufferSize;
  final int fftBufferSize;

  MabAudioDecoder? _decoder;
  DecoderNode? _decoderNode;

  late final _graph = GraphNode();
  late final _outputNode = MabPlaybackDeviceNode(
    device: MabPlaybackDevice(
      context: MabDeviceContext.sharedInstance,
      format: format,
      bufferFrameSize: bufferSize,
      noFixedSizedCallback: true,
    ),
  );
  late final _volumeNode = VolumeNode(volume: 1);
  late final _fftNode = FftNode(
    fftBuffer: FftBuffer(format, fftBufferSize),
    window: getFlatTopWindow(fftBufferSize),
    onFftCompleted: (result) {
      _lastFftResult = result;
      notifyListeners();
      onFftCompleted?.call(result);
    },
  );
  late final _outputTask = AudioTask(
    clock: IntervalAudioClock(const Duration(milliseconds: 16)),
    format: format,
    framesRead: bufferSize,
    endpoint: _graph.outputBus,
  );

  Future<void> open(String filePath) async {
    stop();

    final decoder = MabAudioDecoder.file(filePath: filePath, format: format);
    final decoderNode = DecoderNode(decoder: decoder)..addListener(_onDecode);

    _graph.connect(decoderNode.outputBus, _fftNode.inputBus);

    _decoderNode?.removeListener(_onDecode);
    _decoderNode = decoderNode;
    _decoder = decoder;

    _metadata = await MetadataRetriever.fromFile(File(filePath));

    notifyListeners();
  }

  void _onDecode(AudioDecodeResult result) {
    if (result.isEnd) {
      pause();
    }
  }

  void play() async {
    if (!isReady) {
      return;
    }

    if (position >= duration) {
      return;
    }

    _outputTask.start();
    _outputNode.device.start();
    notifyListeners();
  }

  void pause() {
    _outputTask.stop();
    _outputNode.device.stop();
    notifyListeners();
  }

  void stop() {
    pause();

    final decoderNode = _decoderNode;
    if (decoderNode != null) {
      _graph.disconnect(decoderNode.outputBus);
    }

    _decoder?.dispose();

    _decoderNode = null;
    _decoder = null;
    _metadata = null;
    _lastFftResult = null;
    notifyListeners();
  }

  FftCompletedCallback? onFftCompleted;

  VoidCallback? onRerouted;

  bool get isReady => _decoderNode != null;

  bool get isPlaying => _outputTask.isStarted;

  double get volume => _volumeNode.volume;

  set volume(double value) {
    _volumeNode.volume = value;
    notifyListeners();
  }

  String? get filePath => _decoder?.filePath;

  AudioTime get duration {
    if (!isReady) {
      return AudioTime.zero;
    }

    return AudioTime.fromFrames(frames: _decoder!.length, format: format);
  }

  AudioTime get position {
    if (!isReady) {
      return AudioTime.zero;
    }

    return AudioTime.fromFrames(frames: min(_decoder!.cursor, _decoder!.length), format: format);
  }

  set position(AudioTime time) {
    if (!isReady) {
      return;
    }

    _decoder!.cursor = min(time.computeFrames(format), _decoder!.length);
    notifyListeners();
  }

  Metadata? _metadata;
  Metadata? get metadata => _metadata;

  FftResult? _lastFftResult;
  FftResult? get lastFftResult => _lastFftResult;

  DeviceInfo<dynamic>? get device => _outputNode.device.getDeviceInfo();

  set device(DeviceInfo<dynamic>? device) {
    final oldDevice = _outputNode.device;
    _outputNode.device = MabPlaybackDevice(
      context: MabDeviceContext.sharedInstance,
      format: format,
      bufferFrameSize: bufferSize,
      noFixedSizedCallback: true,
      device: device,
    )..notificationStream.listen(_onNotificationReceived);

    if (_outputTask.isStarted) {
      _outputNode.device.start();
    }

    oldDevice
      ..stop()
      ..dispose();
    notifyListeners();
  }

  void _onNotificationReceived(MabDeviceNotification notification) async {
    // Notify device & interruption state changes.
    notifyListeners();

    if (notification.type == MabDeviceNotificationType.rerouted) {
      onRerouted?.call();
    }
  }

  @override
  void dispose() {
    super.dispose();
    stop();
    _fftNode.fftBuffer.dispose();
    _outputNode.device.dispose();
    _outputTask.dispose();
  }
}
