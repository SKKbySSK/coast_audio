import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class MusicPlayer extends ChangeNotifier {
  MusicPlayer({
    this.format = const AudioFormat(sampleRate: 48000, channels: 2),
    this.bufferSize = 4096,
    this.onOutput,
  }) {
    _graph.connect(_volumeNode.outputBus, _outputNode.inputBus);
    _graph.connectEndpoint(_outputNode.outputBus);

    final rawBuffer = _buffer.lock();
    _clock.callbacks.add((_) {
      var totalRead = 0;
      var read = 0;
      var buffer = rawBuffer;
      while (totalRead <= rawBuffer.sizeInFrames) {
        read = _graph.outputBus.read(buffer);

        if (read == 0) {
          break;
        }

        totalRead += read;
        buffer = rawBuffer.offset(totalRead);
      }
      onOutput?.call(rawBuffer.limit(totalRead));
    });
  }

  final AudioFormat format;
  final int bufferSize;

  MabAudioDecoder? _decoder;
  DecoderNode? _decoderNode;

  late final _buffer = AllocatedFrameBuffer(frames: bufferSize, format: format);
  late final _clock = IntervalAudioClock(const Duration(milliseconds: 10));
  late final _graph = GraphNode();
  late final _outputNode = MabDeviceOutputNode(
    device: MabDeviceOutput(
      context: MabDeviceContext.sharedInstance,
      format: format,
      bufferFrameSize: bufferSize,
      noFixedSizedCallback: true,
    ),
  );
  late final _volumeNode = VolumeNode(volume: 1);

  Future<void> open(String filePath) async {
    stop();

    final decoder = MabAudioDecoder.file(filePath: filePath, format: format);
    final decoderNode = DecoderNode(decoder: decoder);

    _graph.connect(decoderNode.outputBus, _volumeNode.inputBus);

    _decoderNode = decoderNode;
    _decoder = decoder;

    _metadata = await MetadataRetriever.fromFile(File(filePath));

    notifyListeners();
  }

  void play() async {
    if (!isReady) {
      return;
    }

    _clock.start();
    _outputNode.device.start();
    notifyListeners();
  }

  void pause() {
    _clock.stop();
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
    notifyListeners();
  }

  void Function(RawFrameBuffer buffer)? onOutput;

  bool get isReady => _decoderNode != null;

  bool get isPlaying => _clock.isStarted;

  double get volume => _volumeNode.volume;

  set volume(double value) => _volumeNode.volume = value;

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
  }

  Metadata? _metadata;
  Metadata? get metadata => _metadata;

  DeviceInfo<dynamic>? get device => _outputNode.device.getDeviceInfo();

  set device(DeviceInfo<dynamic>? device) {
    final oldDevice = _outputNode.device;
    _outputNode.device = MabDeviceOutput(
      context: MabDeviceContext.sharedInstance,
      format: format,
      bufferFrameSize: bufferSize,
      noFixedSizedCallback: true,
      device: device,
    );

    if (_clock.isStarted) {
      _outputNode.device.start();
    }

    oldDevice
      ..stop()
      ..dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    stop();
    _outputNode.device.dispose();

    _buffer.unlock();
    _buffer.dispose();
  }
}
