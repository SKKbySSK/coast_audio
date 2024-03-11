import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';

import '../interop/coast_audio_interop.dart';
import '../interop/generated/bindings.dart';
import '../interop/ma_extension.dart';

sealed class AudioDevice extends CoastAudioInterop with AudioResourceMixin {
  /// Initialize the [Device] instance.
  /// [noFixedSizedProcess] flag indicates that miniaudio to read or write audio buffer to device in a fixed size buffer.
  /// Latency will be reduced when set to true, but you have to perform audio processing low latency too.
  /// Otherwise, sound may be distorted.
  AudioDevice({
    required this.type,
    required this.context,
    required this.format,
    required this.bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
  }) {
    final config = bindings.ca_device_config_init(
      type.caValue,
      format.sampleFormat.maFormat,
      format.sampleRate,
      format.channels,
      bufferFrameSize,
      _notificationPort.sendPort.nativePort,
    );
    config.noFixedSizedCallback = noFixedSizedProcess.toMaBool();
    config.channelMixMode = channelMixMode.maValue;
    config.performanceProfile = performanceProfile.caValue;

    bindings.ca_device_init(_pDevice, config, context.handle, deviceId?.handle ?? nullptr).throwMaResultIfNeeded();
    addFinalizer(() {
      _notificationPort.close();
      bindings.ca_device_uninit(_pDevice);
    });
  }

  /// Current device context for this instance.
  final AudioDeviceContext context;

  final AudioDeviceType type;

  final int bufferFrameSize;

  /// The device's format.
  /// If the device supports format natively, no conversion will occurs.
  /// Otherwise, miniaudio will try to convert the format.
  final AudioFormat format;

  late final _pDevice = allocateManaged<ca_device>(sizeOf<ca_device>());

  late final _pVolume = allocateManaged<Float>(sizeOf<Float>());

  final _notificationPort = ReceivePort();

  /// The device's notification stream.
  /// Use this stream to detecting route and lifecycle changes.
  late final Stream<AudioDeviceNotification> notification =
      _notificationPort.cast<int>().map((type) => AudioDeviceNotification.values.firstWhere((n) => n.caValue == type)).asBroadcastStream();

  var _isStarted = false;

  /// A flag indicates the device is started or not.
  bool get isStarted => _isStarted;

  /// Available buffered frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableReadFrames => bindings.ca_device_available_read(_pDevice);

  /// Available writable frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableWriteFrames => bindings.ca_device_available_write(_pDevice);

  /// The current volume of the device.
  double get volume {
    bindings.ca_device_get_volume(_pDevice, _pVolume).throwMaResultIfNeeded();
    return _pVolume.value;
  }

  /// Set the volume of the device.
  set volume(double value) {
    bindings.ca_device_set_volume(_pDevice, value).throwMaResultIfNeeded();
  }

  AudioDeviceState get state {
    final state = bindings.ca_device_get_state(_pDevice);
    return AudioDeviceState.values.firstWhere((s) => s.caValue == state);
  }

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  AudioDeviceInfo? get deviceInfo {
    final pInfo = memory.allocator.allocate<ca_device_info>(sizeOf<ca_device_info>());
    try {
      final result = bindings.ca_device_get_device_info(_pDevice, pInfo).asMaResult();

      // MEMO: AAudio returns MA_INVALID_OPERATION when getting device info.
      if (result.code == MaResult.invalidOperation.code) {
        return null;
      }

      if (!result.isSuccess) {
        throw MaException(result);
      }

      return AudioDeviceInfo(
        type: type,
        configure: (handle) {
          memory.copyMemory(handle.cast(), pInfo.cast(), sizeOf<ca_device_info>());
        },
        backend: context.activeBackend,
      );
    } finally {
      memory.allocator.free(pInfo);
    }
  }

  /// Start the audio device.
  void start() {
    bindings.ca_device_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  /// Stop the audio device.
  /// When [clearBuffer] is set to true, internal buffer will be cleared automatically (true by default).
  void stop({bool clearBuffer = true}) {
    bindings.ca_device_stop(_pDevice).throwMaResultIfNeeded();
    if (clearBuffer) {
      this.clearBuffer();
    }
    _isStarted = false;
  }

  /// Clear the internal buffer.
  void clearBuffer() {
    bindings.ca_device_clear_buffer(_pDevice);
  }
}

class PlaybackDevice extends AudioDevice {
  PlaybackDevice({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.deviceId,
    super.noFixedSizedProcess = false,
  }) : super(type: AudioDeviceType.playback);

  late final _pFramesWrite = allocateManaged<Int>(sizeOf<Int>());

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  PlaybackDeviceWriteResult write(AudioBuffer buffer) {
    final result = bindings.ca_device_playback_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).asMaResult();
    if (!result.isSuccess && result != MaResult.atEnd) {
      result.throwIfNeeded();
    }
    return PlaybackDeviceWriteResult(result, _pFramesWrite.value);
  }
}

class PlaybackDeviceWriteResult {
  const PlaybackDeviceWriteResult(this.maResult, this.framesWrite);
  final MaResult maResult;
  final int framesWrite;
}

class CaptureDevice extends AudioDevice {
  CaptureDevice({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.deviceId,
    super.noFixedSizedProcess = false,
  }) : super(type: AudioDeviceType.capture);

  late final _pFramesRead = allocateManaged<Int>(sizeOf<Int>());

  /// Read device's internal buffer into [buffer].
  CaptureDeviceReadResult read(AudioBuffer buffer) {
    final result = bindings.ca_device_capture_read(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).asMaResult();
    if (!result.isSuccess && result != MaResult.atEnd) {
      result.throwIfNeeded();
    }
    return CaptureDeviceReadResult(result, _pFramesRead.value);
  }
}

class CaptureDeviceReadResult {
  const CaptureDeviceReadResult(this.maResult, this.framesRead);
  final MaResult maResult;
  final int framesRead;
}
