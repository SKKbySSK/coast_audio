import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/filters/mab_filter_base.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

class MabLowShelfFilter extends MabFilterBase {
  MabLowShelfFilter({
    required this.format,
    required double gainDb,
    required double shelfSlope,
    required double frequency,
    super.memory,
  })  : _gainDb = gainDb,
        _shelfSlope = shelfSlope,
        _frequency = frequency {
    final config = library.mab_low_shelf_filter_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, gainDb, shelfSlope, frequency);
    library.mab_low_shelf_filter_init(_pLSF, config).throwMaResultIfNeeded();
    _updateLatency();
  }

  final AudioFormat format;

  double _gainDb;
  double get gainDb => _gainDb;

  double _shelfSlope;
  double get shelfSlope => _shelfSlope;

  double _frequency;
  double get frequency => _frequency;

  late AudioTime _latency;
  AudioTime get latency => _latency;

  late final _pLSF = allocate<mab_low_shelf_filter>(sizeOf<mab_low_shelf_filter>());

  @override
  void process(AudioBuffer bufferOut, AudioBuffer bufferIn) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    library.mab_low_shelf_filter_process(_pLSF, bufferOut.pBuffer.cast(), bufferIn.pBuffer.cast(), bufferIn.sizeInFrames).throwMaResultIfNeeded();
  }

  void reinit({double? gainDb, double? shelfSlope, double? frequency}) {
    final config = library.mab_low_shelf_filter_config_init(
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      gainDb ?? this.gainDb,
      shelfSlope ?? this.shelfSlope,
      frequency ?? this.frequency,
    );
    library.mab_low_shelf_filter_reinit(_pLSF, config).throwMaResultIfNeeded();
    _gainDb = gainDb ?? this.gainDb;
    _shelfSlope = shelfSlope ?? this.shelfSlope;
    _frequency = frequency ?? this.frequency;
    _updateLatency();
  }

  void _updateLatency() {
    final frameCount = library.mab_low_shelf_filter_get_latency(_pLSF);
    _latency = AudioTime.fromFrames(frames: frameCount, format: format);
  }

  @override
  void uninit() {
    library.mab_low_shelf_filter_uninit(_pLSF);
  }
}
