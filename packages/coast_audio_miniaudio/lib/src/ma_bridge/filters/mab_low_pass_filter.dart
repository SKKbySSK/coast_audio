import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/filters/mab_filter_base.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

/// Low pass filter. It uses ma_lpf(Butterworth) implementations.
class MabLowPassFilter extends MabFilterBase {
  MabLowPassFilter({
    required this.format,
    required int order,
    required double cutoffFrequency,
    super.memory,
  })  : _order = order,
        _cutoffFrequency = cutoffFrequency {
    final config = library.mab_low_pass_filter_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, order, cutoffFrequency);
    library.mab_low_pass_filter_init(_pLPF, config).throwMaResultIfNeeded();
    _updateLatency();
  }

  final AudioFormat format;

  int _order;
  int get order => _order;

  double _cutoffFrequency;
  double get cutoffFrequency => _cutoffFrequency;

  late AudioTime _latency;
  AudioTime get latency => _latency;

  late final _pLPF = allocate<mab_low_pass_filter>(sizeOf<mab_low_pass_filter>());

  @override
  void process(AudioBuffer bufferOut, AudioBuffer bufferIn) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    library.mab_low_pass_filter_process(_pLPF, bufferOut.pBuffer.cast(), bufferIn.pBuffer.cast(), bufferIn.sizeInFrames).throwMaResultIfNeeded();
  }

  /// Reinit the filter parameters while keeping internal state.
  void update({int? order, double? cutoffFrequency}) {
    final config = library.mab_low_pass_filter_config_init(
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      order ?? this.order,
      cutoffFrequency ?? this.cutoffFrequency,
    );
    library.mab_low_pass_filter_reinit(_pLPF, config).throwMaResultIfNeeded();
    _order = order ?? this.order;
    _cutoffFrequency = cutoffFrequency ?? this.cutoffFrequency;
    _updateLatency();
  }

  void _updateLatency() {
    final frameCount = library.mab_low_pass_filter_get_latency(_pLPF);
    _latency = AudioTime.fromFrames(frames: frameCount, format: format);
  }

  @override
  void uninit() {
    library.mab_low_pass_filter_uninit(_pLPF);
  }
}
