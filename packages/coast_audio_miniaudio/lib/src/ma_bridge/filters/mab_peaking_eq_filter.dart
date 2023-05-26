import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/filters/mab_filter_base.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

/// High shelf filter. It uses ma_peak2 implementations.
class MabPeakingEqFilter extends MabFilterBase {
  MabPeakingEqFilter({
    required this.format,
    required double gainDb,
    required double q,
    required double frequency,
    super.memory,
  })  : _gainDb = gainDb,
        _q = q,
        _frequency = frequency {
    final config = library.mab_peaking_eq_filter_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, gainDb, q, frequency);
    library.mab_peaking_eq_filter_init(_pEQ, config).throwMaResultIfNeeded();
    _updateLatency();
  }

  final AudioFormat format;

  double _gainDb;
  double get gainDb => _gainDb;

  double _q;
  double get q => _q;

  double _frequency;
  double get frequency => _frequency;

  late AudioTime _latency;
  AudioTime get latency => _latency;

  late final _pEQ = allocate<mab_peaking_eq_filter>(sizeOf<mab_peaking_eq_filter>());

  @override
  void process(AudioBuffer bufferOut, AudioBuffer bufferIn) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    library.mab_peaking_eq_filter_process(_pEQ, bufferOut.pBuffer.cast(), bufferIn.pBuffer.cast(), bufferIn.sizeInFrames).throwMaResultIfNeeded();
  }

  /// Reinit the filter parameters while keeping internal state.
  void update({double? gainDb, double? q, double? frequency}) {
    final config = library.mab_peaking_eq_filter_config_init(
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      gainDb ?? this.gainDb,
      q ?? this.q,
      frequency ?? this.frequency,
    );
    library.mab_peaking_eq_filter_reinit(_pEQ, config).throwMaResultIfNeeded();
    _gainDb = gainDb ?? this.gainDb;
    _q = q ?? this.q;
    _frequency = frequency ?? this.frequency;
    _updateLatency();
  }

  void _updateLatency() {
    final frameCount = library.mab_peaking_eq_filter_get_latency(_pEQ);
    _latency = AudioTime.fromFrames(frames: frameCount, format: format);
  }

  @override
  void uninit() {
    library.mab_peaking_eq_filter_uninit(_pEQ);
  }
}
