import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_bridge_library.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_result_extension.dart';
import 'package:ffi/ffi.dart';

class DeviceOutputNode extends ProcessorNode {
  DeviceOutputNode({
    required AudioFormat format,
    required int bufferFrameSize,
  })  : _library = MaBridge(maBridgeLib),
        super(format) {
    final config = _library.device_output_config_init(format.sampleRate, format.channels, bufferFrameSize);
    _pDevice = malloc.allocate<device_output>(sizeOf<device_output>());

    _library.device_output_init(_pDevice, config).throwMaResultIfNeeded();
  }

  final MaBridge _library;
  late final Pointer<device_output> _pDevice;

  var _isStarted = false;
  bool get isStarted => _isStarted;

  int get availableWriteFrames => _library.device_output_available_write(_pDevice);

  void start() {
    _library.device_output_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  void stop() {
    _library.device_output_stop(_pDevice).throwMaResultIfNeeded();
    _isStarted = false;
  }

  @override
  void process(FrameBuffer buffer) {
    final result = _library.device_output_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames).toMaResult();
    if (result.isError && result.code != MaResultName.atEnd.code) {
      result.throwIfNeeded();
    }
  }

  void dispose() {
    try {
      _library.device_output_uninit(_pDevice).throwMaResultIfNeeded();
      _isStarted = false;
    } finally {
      malloc.free(_pDevice);
    }
  }
}
