import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

abstract class MabDevice extends MabBase {
  /// Initialize the [MabDevice] instance.
  /// [noFixedSizedCallback] flag indicates that miniaduio to read or write audio buffer to device in a fixed size buffer.
  /// Latency will be reduced when set to true, but you have to perform audio processing low latency too.
  /// Otherwise, sound may be distorted.
  MabDevice({
    required int rawType,
    required this.context,
    required this.format,
    required int bufferFrameSize,
    required DeviceInfo<dynamic>? device,
    required Memory? memory,
    required bool noFixedSizedCallback,
  }) : super(memory: memory) {
    final config = library.mab_device_config_init(
      rawType,
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      bufferFrameSize,
    );
    config.noFixedSizedCallback = noFixedSizedCallback.toMabBool();

    final rawDevice = device?.allocateMabDeviceInfo(memory: memory);
    final pDeviceId = rawDevice?.id.pDeviceId;
    library.mab_device_init(_pDevice, config, context.pDeviceContext, pDeviceId ?? nullptr).throwMaResultIfNeeded();
    rawDevice?.dispose();
  }

  final MabDeviceContext context;
  final AudioFormat format;

  late final _pDevice = allocate<mab_device>(sizeOf<mab_device>());

  var _isStarted = false;
  bool get isStarted => _isStarted;

  int get availableReadFrames => library.mab_device_available_read(_pDevice);

  int get availableWriteFrames => library.mab_device_available_write(_pDevice);

  DeviceInfo? getDeviceInfo() {
    final info = MabDeviceInfo(
      backend: context.activeBackend,
      memory: memory,
    );
    final result = library.mab_device_get_device_info(_pDevice, info.pDeviceInfo).toMaResult();

    if (result.name == MaResultName.invalidOperation) {
      info.dispose();
      return null;
    }

    final deviceInfo = info.getDeviceInfo();
    info.dispose();
    return deviceInfo;
  }

  void start() {
    library.mab_device_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  void stop() {
    library.mab_device_stop(_pDevice).throwMaResultIfNeeded();
    _isStarted = false;
  }

  @override
  void uninit() {
    library.mab_device_uninit(_pDevice);
  }
}

class MabDeviceOutput extends MabDevice {
  MabDeviceOutput({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.device,
    super.memory,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_playback);

  late final _pFramesWrite = allocate<Int>(sizeOf<Int>());

  MabDeviceOutputWriteResult write(RawFrameBuffer buffer) {
    final result = library.mab_device_playback_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return MabDeviceOutputWriteResult(result, _pFramesWrite.value);
  }
}

class MabDeviceOutputWriteResult {
  const MabDeviceOutputWriteResult(this.maResult, this.framesWrite);
  final MaResult maResult;
  final int framesWrite;
}

class MabDeviceInput extends MabDevice {
  MabDeviceInput({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.device,
    super.memory,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_capture);

  late final _pFramesRead = allocate<Int>(sizeOf<Int>());

  MabDeviceInputReadResult read(RawFrameBuffer buffer) {
    final result = library.mab_device_capture_read(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).toMaResult();
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
