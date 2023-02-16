import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_result_extension.dart';

class MabDeviceOutput extends MabBase {
  MabDeviceOutput({
    required this.outputFormat,
    required int bufferFrameSize,
  }) {
    final config = library.device_output_config_init(outputFormat.sampleRate, outputFormat.channels, bufferFrameSize);
    library.device_output_init(_pDevice, config).throwMaResultIfNeeded();
  }

  final AudioFormat outputFormat;
  late final _pDevice = allocate<device_output>(sizeOf<device_output>());

  var _isStarted = false;
  bool get isStarted => _isStarted;

  int get availableWriteFrames => library.device_output_available_write(_pDevice);

  void start() {
    library.device_output_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  void stop() {
    library.device_output_stop(_pDevice).throwMaResultIfNeeded();
    _isStarted = false;
  }

  MaResult write(FrameBuffer buffer) {
    final result = library.device_output_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return result;
  }

  @override
  void uninit() {
    library.device_output_uninit(_pDevice).throwMaResultIfNeeded();
  }
}
