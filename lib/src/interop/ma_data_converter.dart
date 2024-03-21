import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';
import 'package:coast_audio/src/interop/ma_resampler_config.dart';

class MaDataConverter {
  MaDataConverter({
    required this.inputFormat,
    required this.outputFormat,
    required AudioFormatConverterConfig config,
  }) {
    final nativeConfig = _interop.bindings.ma_data_converter_config_init(
      inputFormat.sampleFormat.maFormat,
      outputFormat.sampleFormat.maFormat,
      inputFormat.channels,
      outputFormat.channels,
      inputFormat.sampleRate,
      outputFormat.sampleRate,
    );
    nativeConfig.ditherMode = config.ditherMode.maValue;
    nativeConfig.channelMixMode = config.channelMixMode.maValue;
    nativeConfig.resampling = config.resampling.maConfig;
    _pConfig.ref = nativeConfig;

    _interop.bindings.ma_data_converter_init(_pConfig, nullptr, _pConverter).throwMaResultIfNeeded();

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();

  late final _pConfig = _interop.allocateManaged<ma_data_converter_config>(sizeOf<ma_data_converter_config>());
  late final _pConverter = _interop.allocateManaged<ma_data_converter>(sizeOf<ma_data_converter>());
  late final _pFramesIn = _interop.allocateManaged<UnsignedLongLong>(sizeOf<UnsignedLongLong>());
  late final _pFramesOut = _interop.allocateManaged<UnsignedLongLong>(sizeOf<UnsignedLongLong>());

  final AudioFormat inputFormat;
  final AudioFormat outputFormat;

  int get inputLatencyFrameCount => _interop.bindings.ma_data_converter_get_input_latency(_pConverter);

  int get outputLatencyFrameCount => _interop.bindings.ma_data_converter_get_output_latency(_pConverter);

  int getRequiredInputFrameCount({required int outputFrameCount}) {
    _pFramesIn.value = 0;
    _interop.bindings.ma_data_converter_get_required_input_frame_count(_pConverter, outputFrameCount, _pFramesIn).throwMaResultIfNeeded();
    return _pFramesIn.value;
  }

  int getExpectedOutputFrameCount({required int inputFrameCount}) {
    _pFramesOut.value = 0;
    _interop.bindings.ma_data_converter_get_expected_output_frame_count(_pConverter, inputFrameCount, _pFramesOut).throwMaResultIfNeeded();
    return _pFramesOut.value;
  }

  void reset() {
    _interop.bindings.ma_data_converter_reset(_pConverter).throwMaResultIfNeeded();
  }

  AudioFormatConverterResult process(AudioBuffer bufferIn, AudioBuffer bufferOut) {
    _pFramesIn.value = bufferIn.sizeInFrames;
    _pFramesOut.value = bufferOut.sizeInFrames;

    _interop.bindings.ma_data_converter_process_pcm_frames(_pConverter, bufferIn.pBuffer.cast(), _pFramesIn, bufferOut.pBuffer.cast(), _pFramesOut).throwMaResultIfNeeded();

    return AudioFormatConverterResult(
      inputFrameCount: _pFramesIn.value,
      outputFrameCount: _pFramesOut.value,
    );
  }

  void dispose() {
    _interop.bindings.ma_data_converter_uninit(_pConverter, nullptr);
    _interop.dispose();
  }
}
