import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_bridge/mab_device_context.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_extension.dart';

class MabDevice extends MabBase {
  MabDevice({
    required int rawType,
    required this.context,
    required this.format,
    required int bufferFrameSize,
    bool noFixedSizedCallback = false,
  }) {
    final config = library.mab_device_config_init(rawType, format.sampleRate, format.channels, bufferFrameSize);
    config.noFixedSizedCallback = noFixedSizedCallback.toMabBool();
    library.mab_device_init(pDevice, config, context.pDeviceContext).throwMaResultIfNeeded();
  }

  final MabDeviceContext context;
  final AudioFormat format;

  MabBackend get backend => MabBackend.fromRawValue(pDevice.ref.backend);

  late final pDevice = allocate<mab_device>(sizeOf<mab_device>());

  var _isStarted = false;
  bool get isStarted => _isStarted;

  int get availableReadFrames => library.mab_device_available_read(pDevice);

  int get availableWriteFrames => library.mab_device_available_write(pDevice);

  void start() {
    library.mab_device_start(pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  void stop() {
    library.mab_device_stop(pDevice).throwMaResultIfNeeded();
    _isStarted = false;
  }

  @override
  void uninit() {
    library.mab_device_uninit(pDevice);
  }
}

class MabDeviceOutput extends MabDevice {
  MabDeviceOutput({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_playback);

  MaResult write(FrameBuffer buffer) {
    final result = library.mab_device_playback_write(pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return result;
  }
}

class MabDeviceInput extends MabDevice {
  MabDeviceInput({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_capture);

  late final _pFramesRead = allocate<Int>(sizeOf<Int>());

  MabDeviceInputReadResult read(FrameBuffer buffer) {
    final result = library.mab_device_capture_read(pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return MabDeviceInputReadResult(result, _pFramesRead.value);
  }
}

class MabDeviceInputReadResult {
  const MabDeviceInputReadResult(this.maResult, this.framesRead);
  final MaResult maResult;
  final int framesRead;
}
