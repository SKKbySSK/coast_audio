import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

class MabAudioConverterResult {
  const MabAudioConverterResult({required this.framesIn, required this.framesOut});
  final int framesIn;
  final int framesOut;
}

class MabAudioConverter extends MabBase {
  MabAudioConverter({
    super.memory,
    required this.inputFormat,
    required this.outputFormat,
    MabDitherMode ditherMode = MabDitherMode.none,
    MabChannelMixMode channelMixMode = MabChannelMixMode.rectangular,
  }) {
    final config = library.mab_audio_converter_config_init(
      inputFormat.sampleFormat.mabFormat.value,
      outputFormat.sampleFormat.mabFormat.value,
      inputFormat.sampleRate,
      outputFormat.sampleRate,
      inputFormat.channels,
      outputFormat.channels,
    );
    config.ditherMode = ditherMode.value;
    config.channelMixMode = channelMixMode.value;

    library.mab_audio_converter_init(_pConverter, config).throwMaResultIfNeeded();
  }

  late final _pConverter = allocate<mab_audio_converter>(sizeOf<mab_audio_converter>());
  late final _pTempFrameCount = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());
  late final _pTempFrameCount2 = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());

  final AudioFormat inputFormat;
  final AudioFormat outputFormat;

  late final inputLatency = library.mab_audio_converter_get_input_latency(_pConverter);

  late final outputLatency = library.mab_audio_converter_get_output_latency(_pConverter);

  int getRequiredInputFrameCount({required int outputFrameCount}) {
    _pTempFrameCount.value = 0;
    library.mab_audio_converter_get_required_input_frame_count(_pConverter, outputFrameCount, _pTempFrameCount).throwMaResultIfNeeded();
    return _pTempFrameCount.value;
  }

  int getExpectedOutputFrameCount({required int inputFrameCount}) {
    _pTempFrameCount.value = 0;
    library.mab_audio_converter_get_expected_output_frame_count(_pConverter, inputFrameCount, _pTempFrameCount).throwMaResultIfNeeded();
    return _pTempFrameCount.value;
  }

  void reset() {
    library.mab_audio_converter_reset(_pConverter).throwMaResultIfNeeded();
  }

  MabAudioConverterResult process(AudioBuffer bufferIn, AudioBuffer bufferOut) {
    _pTempFrameCount.value = bufferIn.sizeInFrames;
    _pTempFrameCount2.value = bufferOut.sizeInFrames;

    library
        .mab_audio_converter_process_pcm_frames(_pConverter, bufferIn.pBuffer.cast(), _pTempFrameCount, bufferOut.pBuffer.cast(), _pTempFrameCount2)
        .throwMaResultIfNeeded();

    return MabAudioConverterResult(framesIn: _pTempFrameCount.value, framesOut: _pTempFrameCount2.value);
  }

  @override
  void uninit() {
    library.mab_audio_converter_uninit(_pConverter);
  }
}
