import 'dart:io';

import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/player/flat_top_window.dart';
import 'package:path/path.dart';

typedef DecoderFactory = AudioDecoder? Function(AudioInputDataSource dataSource);

AudioDecoder? _mabDecoderFactory(AudioInputDataSource dataSource) {
  try {
    return MabAudioDecoder(
      dataSource: dataSource,
      outputFormat: const AudioFormat(sampleRate: 48000, channels: 2),
    );
  } catch (_) {
    return null;
  }
}

AudioDecoder? _wavDecoderFactory(AudioInputDataSource dataSource) {
  try {
    return WavAudioDecoder(
      dataSource: dataSource,
    );
  } catch (_) {
    return null;
  }
}

class MusicPlayer extends MabAudioPlayer {
  static const _converterNodeId = 'CONVERTER_NODE';
  static const _fftNodeId = 'FFT_NODE';

  MusicPlayer({
    super.format,
    super.bufferFrameSize = 4096,
    this.fftSize = 512,
    this.onFftCompleted,
    this.onRerouted,
    super.onOutput,
  }) {
    notificationStream.listen((notification) {
      if (notification.type == MabDeviceNotificationType.rerouted) {
        onRerouted?.call();
      }
    });
  }

  final int fftSize;

  AudioFormat? _inputFormat;

  FftCompletedCallback? onFftCompleted;

  VoidCallback? onRerouted;

  final _decoderFactories = [
    _wavDecoderFactory,
    _mabDecoderFactory,
  ];

  AudioDecoder? _createDecoder(AudioInputDataSource dataSource) {
    for (final factory in _decoderFactories) {
      final decoder = factory(dataSource);
      if (decoder != null) {
        return decoder;
      }
    }

    return null;
  }

  Future<bool> openFile(File file) async {
    final disposableBag = DisposableBag();
    final dataSource = AudioFileDataSource(file: file, mode: FileMode.read)..disposeOn(disposableBag);

    final decoder = _createDecoder(dataSource);
    if (decoder == null) {
      return false;
    }

    _inputFormat = decoder.outputFormat;

    await open(decoder, disposableBag);

    _metadata = await MetadataRetriever.fromFile(file);
    _name = basename(file.path);
    return true;
  }

  Future<bool> openBuffer(List<int> buffer) async {
    final disposableBag = DisposableBag();
    final dataSource = AudioMemoryDataSource(buffer: buffer);

    final decoder = _createDecoder(dataSource);
    if (decoder == null) {
      return false;
    }

    _inputFormat = decoder.outputFormat;

    await open(decoder, disposableBag);

    _metadata = await MetadataRetriever.fromBytes(buffer);
    _name = 'On Memory Audio';
    return true;
  }

  Future<bool> openHttpUrl(Uri url) async {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();

    final tempDir = Directory.systemTemp.path;
    final file = File(join(tempDir, basename(url.path)));
    await file.openWrite().addStream(response);

    return openFile(file);
  }

  @override
  void connectDecoderToVolume(
    AudioGraphBuilder builder, {
    required String decoderNodeId,
    required int decoderNodeBusIndex,
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    final converterNode = MabAudioConverterNode(
      converter: MabAudioConverter(inputFormat: _inputFormat!, outputFormat: format),
    );

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
      ..addNode(id: _converterNodeId, node: converterNode)
      ..connect(outputNodeId: decoderNodeId, outputBusIndex: decoderNodeBusIndex, inputNodeId: _converterNodeId, inputBusIndex: 0)
      ..connect(outputNodeId: _converterNodeId, outputBusIndex: 0, inputNodeId: _fftNodeId, inputBusIndex: 0)
      ..connect(outputNodeId: _fftNodeId, outputBusIndex: 0, inputNodeId: volumeNodeId, inputBusIndex: 0);
  }

  Metadata? _metadata;
  Metadata? get metadata => _metadata;

  String? _name;
  String? get name => _name;

  FftResult? _lastFftResult;
  FftResult? get lastFftResult => _lastFftResult;
}
