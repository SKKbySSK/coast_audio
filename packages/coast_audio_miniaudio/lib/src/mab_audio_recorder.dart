import 'dart:async';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

enum MabAudioRecorderState {
  stopped,
  recording,
  paused,
}

class MabAudioRecorder extends AsyncDisposable {
  static const _captureNodeId = 'CAPTURE_NODE';
  static const _volumeNodeId = 'VOLUME_NODE';

  MabAudioRecorder({
    required this.onInput,
    MabDeviceContext? context,
    this.format = const AudioFormat(sampleRate: 48000, channels: 1),
    this.noFixedSizeCallback = true,
    this.bufferFrameSize = 2048,
    this.clockInterval = const Duration(milliseconds: 10),
    this.maxDuration,
    DeviceInfo<dynamic>? device,
  })  : context = context ?? MabDeviceContext.sharedInstance,
        _device = MabCaptureDevice(
          context: context ?? MabDeviceContext.sharedInstance,
          format: format,
          bufferFrameSize: bufferFrameSize,
          noFixedSizedCallback: noFixedSizeCallback,
          device: device,
        );

  final AudioFormat format;
  final MabDeviceContext context;

  final bool noFixedSizeCallback;
  final int bufferFrameSize;
  final Duration clockInterval;

  MabCaptureDevice _device;

  void Function(AudioTime time, AudioFrameBuffer buffer, bool isEnd)? onInput;

  AudioGraph? _graph;

  double _volume = 1;
  double get volume => _volume;
  set volume(double value) {
    _volume = volume;
    _graph?.findNode<VolumeNode>(_volumeNodeId)!.volume = value;
  }

  var _duration = AudioTime.zero;
  AudioTime get duration => _duration;

  AudioTime? maxDuration;

  DeviceInfo<dynamic>? get device => _device.getDeviceInfo();

  set device(DeviceInfo<dynamic>? deviceInfo) {
    _device.dispose();
    _device = MabCaptureDevice(
      context: context,
      format: format,
      bufferFrameSize: bufferFrameSize,
      noFixedSizedCallback: noFixedSizeCallback,
      device: deviceInfo,
    );
    final isRecording = state == MabAudioRecorderState.recording;
    _graph?.replaceNode(_captureNodeId, MabCaptureDeviceNode(device: _device));
    if (isRecording) {
      start();
    }
  }

  final _positionStreamController = StreamController<AudioTime>.broadcast();

  final _stateStreamController = StreamController<MabAudioRecorderState>.broadcast();

  Stream<AudioTime> get positionStream => _positionStreamController.stream.distinct();

  Stream<MabAudioRecorderState> get stateStream => _stateStreamController.stream.distinct();

  Stream<MabDeviceNotification> get notificationStream => _device.notificationStream;

  MabAudioRecorderState get state {
    final graph = _graph;
    if (graph == null) {
      return MabAudioRecorderState.stopped;
    }

    if (graph.task.isStarted) {
      return MabAudioRecorderState.recording;
    }

    return MabAudioRecorderState.paused;
  }

  Future<void> prepare() async {
    await stop();

    final graphBuilder = AudioGraphBuilder(format: format, clock: IntervalAudioClock(clockInterval))
      ..addNode(id: _captureNodeId, node: MabCaptureDeviceNode(device: _device))
      ..addNode(id: _volumeNodeId, node: VolumeNode(volume: volume))
      ..setReadCallback(_onRead);

    connectCaptureToVolume(
      graphBuilder,
      captureNodeId: _captureNodeId,
      captureNodeBusIndex: 0,
      volumeNodeId: _volumeNodeId,
      volumeNodeBusIndex: 0,
    );

    connectVolumeToEndpoint(
      graphBuilder,
      volumeNodeId: _volumeNodeId,
      volumeNodeBusIndex: 0,
    );

    _graph = graphBuilder.build();
    _stateStreamController.add(state);
  }

  void connectCaptureToVolume(
    AudioGraphBuilder builder, {
    required String captureNodeId,
    required int captureNodeBusIndex,
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    builder.connect(
      outputNodeId: captureNodeId,
      outputBusIndex: captureNodeBusIndex,
      inputNodeId: volumeNodeId,
      inputBusIndex: volumeNodeBusIndex,
    );
  }

  void connectVolumeToEndpoint(
    AudioGraphBuilder builder, {
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    builder.connectEndpoint(
      outputNodeId: volumeNodeId,
      outputBusIndex: volumeNodeBusIndex,
    );
  }

  void start() {
    _graph?.findNode<MabCaptureDeviceNode>(_captureNodeId)!.device.start();
    _graph?.task.start();
    _stateStreamController.add(state);
  }

  void pause() {
    _graph?.task.stop();
    _graph?.findNode<MabPlaybackDeviceNode>(_captureNodeId)!.device.stop();
    _stateStreamController.add(state);
  }

  Future<void> stop() async {
    await _graph?.dispose();
    _graph = null;
    _duration = AudioTime.zero;
    _stateStreamController.add(state);
  }

  void _onRead(AudioFrameBuffer buffer) {
    final onInput = this.onInput;
    if (onInput == null) {
      return;
    }

    final maxDuration = this.maxDuration;
    var limitedBuffer = buffer;
    var isEnd = false;

    if (maxDuration != null) {
      final maxFrames = maxDuration.computeFrames(buffer.format) - _duration.computeFrames(buffer.format);
      limitedBuffer = limitedBuffer.limit(min(max(maxFrames, 0), limitedBuffer.sizeInFrames));
      isEnd = limitedBuffer.sizeInFrames < buffer.sizeInFrames;
    }

    final duration = AudioTime.fromFrames(frames: limitedBuffer.sizeInFrames, format: limitedBuffer.format);
    _duration += duration;
    onInput(_duration, limitedBuffer, isEnd);

    if (isEnd) {
      pause();
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
