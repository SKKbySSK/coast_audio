import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/filters/mab_filter_base.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

/// High shelf filter. It uses ma_hishelf2 implementations.
class MabHighShelfFilter extends MabFilterBase {
  MabHighShelfFilter({
    required this.format,
    required double gainDb,
    required double shelfSlope,
    required double frequency,
    super.memory,
  })  : _gainDb = gainDb,
        _shelfSlope = shelfSlope,
        _frequency = frequency {
    final config = library.mab_high_shelf_filter_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, gainDb, shelfSlope, frequency);
    library.mab_high_shelf_filter_init(_pHPF, config).throwMaResultIfNeeded();
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

  late final _pHPF = allocate<mab_high_shelf_filter>(sizeOf<mab_high_shelf_filter>());

  @override
  void process(AudioBuffer bufferOut, AudioBuffer bufferIn) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    library.mab_high_shelf_filter_process(_pHPF, bufferOut.pBuffer.cast(), bufferIn.pBuffer.cast(), bufferIn.sizeInFrames).throwMaResultIfNeeded();
  }

  /// Reinit the filter parameters while keeping internal state.
  void update({double? gainDb, double? shelfSlope, double? frequency}) {
    final config = library.mab_high_shelf_filter_config_init(
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      gainDb ?? this.gainDb,
      shelfSlope ?? this.shelfSlope,
      frequency ?? this.frequency,
    );
    library.mab_high_shelf_filter_reinit(_pHPF, config).throwMaResultIfNeeded();
    _gainDb = gainDb ?? this.gainDb;
    _shelfSlope = shelfSlope ?? this.shelfSlope;
    _frequency = frequency ?? this.frequency;
    _updateLatency();
  }

  void _updateLatency() {
    final frameCount = library.mab_high_shelf_filter_get_latency(_pHPF);
    _latency = AudioTime.fromFrames(frames: frameCount, format: format);
  }

  @override
  void uninit() {
    library.mab_high_shelf_filter_uninit(_pHPF);
  }
}
