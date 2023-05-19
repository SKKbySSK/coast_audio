import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/filters/mab_filter_base.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

class MabLpf extends MabFilterBase {
  MabLpf({
    required this.format,
    required int order,
    required double cutoffFrequency,
    super.memory,
  })  : _order = order,
        _cutoffFrequency = cutoffFrequency {
    final config = library.mab_lpf_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, order, cutoffFrequency);
    library.mab_lpf_init(_pLPF, config).throwMaResultIfNeeded();
    _updateLatency();
  }

  final AudioFormat format;

  int _order;
  int get order => _order;

  double _cutoffFrequency;
  double get cutoffFrequency => _cutoffFrequency;

  late AudioTime _latency;
  AudioTime get latency => _latency;

  late final _pLPF = allocate<mab_lpf>(sizeOf<mab_lpf>());

  @override
  void process(AudioBuffer bufferOut, AudioBuffer bufferIn) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    library.mab_lpf_process(_pLPF, bufferOut.pBuffer.cast(), bufferIn.pBuffer.cast(), bufferIn.sizeInFrames).throwMaResultIfNeeded();
  }

  void reinit(int order, double cutoffFrequency) {
    final config = library.mab_lpf_config_init(format.sampleFormat.mabFormat.value, format.sampleRate, format.channels, order, cutoffFrequency);
    library.mab_lpf_reinit(_pLPF, config).throwMaResultIfNeeded();
    _order = order;
    _cutoffFrequency = cutoffFrequency;
    _updateLatency();
  }

  void _updateLatency() {
    final frameCount = library.mab_lpf_get_latency(_pLPF);
    _latency = AudioTime.fromFrames(frames: frameCount, format: format);
  }

  @override
  void uninit() {
    library.mab_lpf_uninit(_pLPF);
  }
}
