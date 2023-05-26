import 'dart:io';

import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/player/flat_top_window.dart';

class MusicPlayer extends MabAudioPlayer {
  static const _fftNodeId = 'FFT_NODE';

  MusicPlayer({
    super.format,
    super.bufferFrameSize = 4096,
    this.fftSize = 512,
    this.onFftCompleted,
    this.onRerouted,
  }) {
    notificationStream.listen((notification) {
      if (notification.type == MabDeviceNotificationType.rerouted) {
        onRerouted?.call();
      }
    });
  }

  final int fftSize;

  FftCompletedCallback? onFftCompleted;

  VoidCallback? onRerouted;

  Future<void> openFile(File file) async {
    final disposableBag = DisposableBag();
    final dataSource = AudioFileDataSource(file: file, mode: FileMode.read)..disposeOn(disposableBag);
    final decoder = MabAudioDecoder(
      dataSource: dataSource,
      outputFormat: format,
    );

    await open(decoder, disposableBag);
    _filePath = file.path;
    _metadata = await MetadataRetriever.fromFile(file);
  }

  @override
  void connectDecoderToVolume(
    AudioGraphBuilder builder, {
    required String decoderNodeId,
    required int decoderNodeBusIndex,
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    final fftNode = FftNode(
      format: format,
      fftSize: fftSize,
      window: getFlatTopWindow(fftSize),
      onFftCompleted: (result) {
        _lastFftResult = result;
        onFftCompleted?.call(result);
      },
    );

    builder
      ..addNode(id: _fftNodeId, node: fftNode)
      ..connect(outputNodeId: decoderNodeId, outputBusIndex: decoderNodeBusIndex, inputNodeId: _fftNodeId, inputBusIndex: 0)
      ..connect(outputNodeId: _fftNodeId, outputBusIndex: 0, inputNodeId: volumeNodeId, inputBusIndex: 0);
  }

  String? _filePath;
  String? get filePath => _filePath;

  Metadata? _metadata;
  Metadata? get metadata => _metadata;

  FftResult? _lastFftResult;
  FftResult? get lastFftResult => _lastFftResult;
}
