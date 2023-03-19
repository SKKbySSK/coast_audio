import 'dart:async';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

enum MabAudioPlayerState {
  stopped,
  playing,
  paused,
}

class MabAudioPlayer extends AsyncDisposable {
  static const _decoderNodeId = 'DECODER_NODE';
  static const _volumeNodeId = 'VOLUME_NODE';
  static const _playbackNodeId = 'PLAYBACK_NODE';

  MabAudioPlayer({
    MabDeviceContext? context,
    this.format = const AudioFormat(sampleRate: 48000, channels: 2),
    this.limitMaxPosition = true,
    this.noFixedSizeCallback = true,
    this.bufferFrameSize = 2048,
    this.clockInterval = const Duration(milliseconds: 10),
    this.isLoop = false,
    DeviceInfo<dynamic>? device,
    this.onOutput,
  })  : context = context ?? MabDeviceContext.sharedInstance,
        _device = MabPlaybackDevice(
          context: context ?? MabDeviceContext.sharedInstance,
          format: format,
          bufferFrameSize: bufferFrameSize,
          noFixedSizedCallback: noFixedSizeCallback,
          device: device,
        );

  final AudioFormat format;
  final MabDeviceContext context;

  final bool limitMaxPosition;
  final bool noFixedSizeCallback;
  final int bufferFrameSize;
  final Duration clockInterval;
  final bool isLoop;

  MabPlaybackDevice _device;

  void Function(AudioTime time, RawFrameBuffer buffer, bool isEnd)? onOutput;

  final _positionStreamController = StreamController<AudioTime>.broadcast();

  final _stateStreamController = StreamController<MabAudioPlayerState>.broadcast();

  Stream<AudioTime> get positionStream => _positionStreamController.stream.distinct();

  Stream<MabAudioPlayerState> get stateStream => _stateStreamController.stream.distinct();

  Stream<MabDeviceNotification> get notificationStream => _device.notificationStream;

  AudioGraph? _graph;

  DeviceInfo<dynamic>? get device => _device.getDeviceInfo();

  set device(DeviceInfo<dynamic>? deviceInfo) {
    _device = MabPlaybackDevice(
      context: context,
      format: format,
      bufferFrameSize: bufferFrameSize,
      noFixedSizedCallback: noFixedSizeCallback,
      device: deviceInfo,
    );

    final isPlaying = state == MabAudioPlayerState.playing;
    final oldNode = _graph?.replaceNode(_playbackNodeId, MabPlaybackDeviceNode(device: _device));
    if (isPlaying) {
      play();
    }
    oldNode?.device.dispose();
  }

  double _volume = 1;
  double get volume => _volume;
  set volume(double value) {
    _volume = value;
    _graph?.findNode<VolumeNode>(_volumeNodeId)!.volume = value;
  }

  AudioTime get position {
    final decoderNode = _graph?.findNode<DecoderNode>(_decoderNodeId)?.decoder;
    if (decoderNode == null) {
      return AudioTime.zero;
    }

    final pos = AudioTime.fromFrames(frames: decoderNode.cursor, format: decoderNode.format);
    if (limitMaxPosition && pos.seconds > duration.seconds) {
      return duration;
    }

    return pos;
  }

  set position(AudioTime value) {
    final decoderNode = _graph?.findNode<DecoderNode>(_decoderNodeId)?.decoder;
    if (decoderNode == null) {
      return;
    }

    final cursor = value.computeFrames(decoderNode.format);
    decoderNode.cursor = limitMaxPosition ? min(cursor, decoderNode.length) : cursor;
    _positionStreamController.add(position);
  }

  AudioTime get duration {
    final decoderNode = _graph?.findNode<DecoderNode>(_decoderNodeId)?.decoder;
    if (decoderNode == null) {
      return AudioTime.zero;
    }
    return AudioTime.fromFrames(frames: decoderNode.length, format: decoderNode.format);
  }

  MabAudioPlayerState get state {
    final graph = _graph;
    if (graph == null) {
      return MabAudioPlayerState.stopped;
    }

    if (graph.task.isStarted) {
      return MabAudioPlayerState.playing;
    }

    return MabAudioPlayerState.paused;
  }

  Future<void> open(AudioInputDataSource dataSource, {bool autoDisposeDataSource = true}) async {
    await stop();

    final decoder = MabAudioDecoder(dataSource: dataSource, format: format);
    final graphBuilder = AudioGraphBuilder(format: format, clock: IntervalAudioClock(clockInterval))
      ..addDisposable(decoder)
      ..addNode(id: _decoderNodeId, node: DecoderNode(decoder: decoder))
      ..addNode(id: _volumeNodeId, node: VolumeNode(volume: volume))
      ..addNode(id: _playbackNodeId, node: MabPlaybackDeviceNode(device: _device))
      ..setReadCallback(_onRead);

    connectDecoderToVolume(
      graphBuilder,
      decoderNodeId: _decoderNodeId,
      decoderNodeBusIndex: 0,
      volumeNodeId: _volumeNodeId,
      volumeNodeBusIndex: 0,
    );

    connectVolumeToPlayback(
      graphBuilder,
      volumeNodeId: _volumeNodeId,
      volumeNodeBusIndex: 0,
      playbackNodeId: _playbackNodeId,
      playbackNodeBusIndex: 0,
    );

    connectPlaybackToEndpoint(
      graphBuilder,
      playbackNodeId: _playbackNodeId,
      playbackNodeBusIndex: 0,
    );

    if (autoDisposeDataSource && dataSource is Disposable) {
      graphBuilder.addDisposable(dataSource as Disposable);
    }

    _graph = graphBuilder.build();
    _stateStreamController.add(state);
  }

  void connectDecoderToVolume(
    AudioGraphBuilder builder, {
    required String decoderNodeId,
    required int decoderNodeBusIndex,
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    builder.connect(
      outputNodeId: decoderNodeId,
      outputBusIndex: decoderNodeBusIndex,
      inputNodeId: volumeNodeId,
      inputBusIndex: volumeNodeBusIndex,
    );
  }

  void connectVolumeToPlayback(
    AudioGraphBuilder builder, {
    required String volumeNodeId,
    required int volumeNodeBusIndex,
    required String playbackNodeId,
    required int playbackNodeBusIndex,
  }) {
    builder.connect(
      outputNodeId: volumeNodeId,
      outputBusIndex: volumeNodeBusIndex,
      inputNodeId: playbackNodeId,
      inputBusIndex: playbackNodeBusIndex,
    );
  }

  void connectPlaybackToEndpoint(
    AudioGraphBuilder builder, {
    required String playbackNodeId,
    required int playbackNodeBusIndex,
  }) {
    builder.connectEndpoint(
      outputNodeId: playbackNodeId,
      outputBusIndex: playbackNodeBusIndex,
    );
  }

  void play() {
    _graph?.findNode<MabPlaybackDeviceNode>(_playbackNodeId)!.device.start();
    _graph?.task.start();
    _stateStreamController.add(state);
  }

  void pause() {
    _graph?.task.stop();
    _graph?.findNode<MabPlaybackDeviceNode>(_playbackNodeId)!.device.stop();
    _stateStreamController.add(state);
  }

  Future<void> stop() async {
    await _graph?.dispose();
    _graph = null;
    _stateStreamController.add(state);
  }

  void _onRead(RawFrameBuffer buffer) {
    final position = this.position;

    _positionStreamController.add(position);
    final isEnd = position >= duration;
    onOutput?.call(position, buffer, isEnd);

    if (!isEnd) {
      return;
    }

    if (isLoop) {
      _graph?.findNode<DecoderNode>(_decoderNodeId)?.decoder.cursor = 0;
    } else {
      pause();
      stop();
    }
  }

  var _isDisposing = false;
  var _isDisposed = false;

  @override
  bool get isDisposing => _isDisposing;

  @override
  bool get isDisposed => _isDisposed;

  @override
  Future<void> dispose() async {
    _isDisposing = true;
    if (_isDisposing || _isDisposed) {
      return;
    }
    _isDisposed = true;
    await stop();
    _device.dispose();
    await _positionStreamController.close();
    await _stateStreamController.close();
    _isDisposing = false;
  }
}
