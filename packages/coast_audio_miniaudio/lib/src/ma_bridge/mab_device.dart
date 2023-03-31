import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';

/// A base class for [MabCaptureDevice] and [MabPlaybackDevice].
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
    DeviceInfo<dynamic>? device,
    bool noFixedSizedCallback = true,
    MabChannelMixMode channelMixMode = MabChannelMixMode.rectangular,
    MabPerformanceProfile performanceProfile = MabPerformanceProfile.lowLatency,
    required Memory? memory,
  }) : super(memory: memory) {
    // Initialize the ReceivePort to receive notifications from miniaudio.
    _notificationPort.listen(
      (dynamic message) {
        // We need to ensure the device is not disposed since this callback maybe invoked asynchronously.
        if (isDisposed) {
          return;
        }

        switch (state) {
          case MabDeviceState.started:
            _isStarted = true;
            break;
          case MabDeviceState.stopping:
          case MabDeviceState.stopped:
          case MabDeviceState.starting:
          case MabDeviceState.uninitialized:
            _isStarted = false;
            break;
        }
        _notificationStreamController.add(MabDeviceNotification.fromValues(
          type: message as int,
        ));
      },
    );

    final config = library.mab_device_config_init(
      rawType,
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
      bufferFrameSize,
      _notificationPort.sendPort.nativePort,
    );
    config.noFixedSizedCallback = noFixedSizedCallback.toMabBool();
    config.channelMixMode = channelMixMode.value;
    config.performanceProfile = performanceProfile.value;

    final rawDevice = device?.allocateMabDeviceInfo(memory: memory);
    final pDeviceId = rawDevice?.id.pDeviceId;
    library.mab_device_init(_pDevice, config, context.pDeviceContext, pDeviceId ?? nullptr).throwMaResultIfNeeded();
    rawDevice?.dispose();
  }

  /// Current device context of the device.
  final MabDeviceContext context;

  /// The device's format.
  /// If the device supports format natively, no conversion will occurs.
  /// Otherwise, miniaudio will try to convert the format.
  final AudioFormat format;

  late final _pDevice = allocate<mab_device>(sizeOf<mab_device>());

  final _notificationPort = ReceivePort();

  final _notificationStreamController = StreamController<MabDeviceNotification>.broadcast();

  /// The device's notification stream.
  /// Use this stream to detecting route and lifecycle changes.
  Stream<MabDeviceNotification> get notificationStream => _notificationStreamController.stream;

  var _isStarted = false;

  /// A flag indicates the device is started or not.
  bool get isStarted => _isStarted;

  /// Available buffered frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableReadFrames => library.mab_device_available_read(_pDevice);

  /// Available writable frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableWriteFrames => library.mab_device_available_write(_pDevice);

  MabDeviceType get type;

  MabDeviceState get state {
    final state = library.mab_device_get_state(_pDevice);
    return MabDeviceState.values.firstWhere((s) => s.value == state);
  }

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  DeviceInfo? getDeviceInfo() {
    final info = MabDeviceInfo(
      backend: context.activeBackend,
      memory: memory,
    );

    try {
      final result = library.mab_device_get_device_info(_pDevice, info.pDeviceInfo).toMaResult();

      // MEMO: AAudio returns MA_INVALID_OPERATION when getting device info.
      if (result.code == MaResultName.invalidOperation.code) {
        return null;
      }

      if (result.code != MaResultName.success.code) {
        throw MaResultException(result);
      }

      final deviceInfo = info.getDeviceInfo(type);
      return deviceInfo;
    } finally {
      info.dispose();
    }
  }

  /// Start the audio device.
  void start() {
    library.mab_device_start(_pDevice).throwMaResultIfNeeded();
  }

  /// Stop the audio device.
  /// When [clearBuffer] is set to true, internal buffer will be cleared automatically (true by default).
  void stop({bool clearBuffer = true}) {
    library.mab_device_stop(_pDevice).throwMaResultIfNeeded();
    if (clearBuffer) {
      this.clearBuffer();
    }
  }

  /// Clear the internal buffer.
  void clearBuffer() {
    library.mab_device_clear_buffer(_pDevice);
  }

  @override
  void uninit() {
    _notificationPort.close();
    _notificationStreamController.close();
    library.mab_device_uninit(_pDevice);
  }
}

class MabPlaybackDevice extends MabDevice {
  MabPlaybackDevice({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.device,
    super.memory,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_playback);

  late final _pFramesWrite = allocate<Int>(sizeOf<Int>());

  @override
  MabDeviceType get type => MabDeviceType.playback;

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  MabDeviceWriteResult write(AudioBuffer buffer) {
    final result = library.mab_device_playback_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return MabDeviceWriteResult(result, _pFramesWrite.value);
  }
}

class MabDeviceWriteResult {
  const MabDeviceWriteResult(this.maResult, this.framesWrite);
  final MaResult maResult;
  final int framesWrite;
}

class MabCaptureDevice extends MabDevice {
  MabCaptureDevice({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.device,
    super.memory,
    super.noFixedSizedCallback = false,
  }) : super(rawType: mab_device_type.mab_device_type_capture);

  late final _pFramesRead = allocate<Int>(sizeOf<Int>());

  @override
  MabDeviceType get type => MabDeviceType.capture;

  /// Read device's internal buffer into [buffer].
  MabDeviceReadResult read(AudioBuffer buffer) {
    final result = library.mab_device_capture_read(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
      result.throwIfNeeded();
    }
    return MabDeviceReadResult(result, _pFramesRead.value);
  }
}

class MabDeviceReadResult {
  const MabDeviceReadResult(this.maResult, this.framesRead);
  final MaResult maResult;
  final int framesRead;
}
