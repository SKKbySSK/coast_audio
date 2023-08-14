import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_recorder/recorder/interceptor_node.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

class AudioRecorder extends MabAudioRecorder {
  static const _delayNodeId = 'DELAY_NODE';
  static const _interceptorNodeId = 'INTERCEPTOR_NODE';

  AudioRecorder({
    super.bufferFrameSize,
    super.captureFormat,
    super.onInput,
  });

  final _rmsStreamController = StreamController<double>.broadcast();

  late final _playbackDevice = MabPlaybackDevice(
    context: MabDeviceContext.sharedInstance,
    format: captureFormat,
    bufferFrameSize: 2048,
  );

  Stream<double> get rmsStream => _rmsStreamController.stream;

  double _echo = 0.5;
  double get echo => _echo;
  set echo(double value) {
    _echo = value;
    graph?.findNode<DelayNode>(_delayNodeId)!.decay = value;
  }

  bool _loopback = false;
  bool get loopback => _loopback;
  set loopback(bool value) {
    _loopback = value;
    if (value) {
      _playbackDevice.start();
    } else {
      _playbackDevice.stop();
    }
  }

  @override
  void connectVolumeToConverter(
    AudioGraphBuilder builder, {
    required String volumeNodeId,
    required int volumeNodeBusIndex,
    required String converterNodeId,
    required int converterNodeBusIndex,
  }) {
    builder
      ..addNode(
        id: _delayNodeId,
        node: DelayNode(
          delayFrames: const AudioTime(0.18).computeFrames(captureFormat),
          delayStart: false,
          format: captureFormat,
          decay: echo * 0.8,
          dry: 0.95,
        ),
      )
      ..addNode(
        id: _interceptorNodeId,
        node: InterceptorNode(
          frames: 256,
          format: captureFormat,
          onRead: (buffer) {
            _playbackDevice.write(buffer);
            _rmsStreamController.add(_calcRms(buffer.asFloat32ListView()));
          },
        ),
      )
      ..connect(outputNodeId: volumeNodeId, outputBusIndex: volumeNodeBusIndex, inputNodeId: _delayNodeId, inputBusIndex: 0)
      ..connect(outputNodeId: _delayNodeId, outputBusIndex: 0, inputNodeId: _interceptorNodeId, inputBusIndex: 0)
      ..connect(outputNodeId: _interceptorNodeId, outputBusIndex: 0, inputNodeId: converterNodeId, inputBusIndex: converterNodeBusIndex);
  }

  @override
  void start() {
    super.start();
    if (loopback) {
      _playbackDevice.start();
    }
  }

  @override
  void pause() {
    _playbackDevice.stop();
    super.pause();
  }

  @override
  Future<void> stop() {
    _playbackDevice.stop();
    return super.stop();
  }

  double _calcRms(Float32List audioData) {
    final absData = Float32List(audioData.length);
    for (var i = 0; audioData.length > i; i++) {
      absData[i] = pow(audioData[i], 2.0).toDouble();
    }

    return sqrt(absData.reduce((a, b) => a + b) / absData.length);
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    _playbackDevice.dispose();
    await _rmsStreamController.close();
  }
}
