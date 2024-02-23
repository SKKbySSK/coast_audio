import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/ca_device/bindings.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ca_device_interop.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

sealed class AudioDevice extends CaDeviceInterop {
  /// Initialize the [Device] instance.
  /// [noFixedSizedProcess] flag indicates that miniaudio to read or write audio buffer to device in a fixed size buffer.
  /// Latency will be reduced when set to true, but you have to perform audio processing low latency too.
  /// Otherwise, sound may be distorted.
  AudioDevice({
    required int rawType,
    required this.context,
    required this.format,
    required int bufferFrameSize,
    AudioDeviceInfo<dynamic>? device,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
    Memory? memory,
  }) : super(memory: memory) {
    final config = bindings.ca_device_config_init(
      rawType,
      format.sampleFormat.caFormat,
      format.sampleRate,
      format.channels,
      bufferFrameSize,
      _notificationPort.sendPort.nativePort,
    );
    config.noFixedSizedCallback = noFixedSizedProcess.toCaBool();
    config.channelMixMode = channelMixMode.caValue;
    config.performanceProfile = performanceProfile.caValue;

    bindings.ca_device_init(_pDevice, config, context.handle, nullptr).throwMaResultIfNeeded();

    addDisposable(SyncCallbackDisposable(() => _notificationPort.close()));
    addDisposable(SyncCallbackDisposable(() => bindings.ca_device_uninit(_pDevice)));
  }

  /// Current device context for this instance.
  final AudioDeviceContext context;

  /// The device's format.
  /// If the device supports format natively, no conversion will occurs.
  /// Otherwise, miniaudio will try to convert the format.
  final AudioFormat format;

  late final _pDevice = allocateManaged<ca_device>(sizeOf<ca_device>());

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

  AudioDeviceType get type;

  AudioDeviceState get state {
    final state = bindings.ca_device_get_state(_pDevice);
    return AudioDeviceState.values.firstWhere((s) => s.caValue == state);
  }

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  AudioDeviceInfo get deviceInfo {
    final pInfo = memory.allocator.allocate<ca_device_info>(sizeOf<ca_device_info>());
    try {
      final result = bindings.ca_device_get_device_info(_pDevice, pInfo).toMaResult();

      // MEMO: AAudio returns MA_INVALID_OPERATION when getting device info.
      if (result.code == MaResultName.invalidOperation.code) {
        return UnknownDeviceInfo(
          backend: context.activeBackend,
          type: type,
          memory: memory,
          configure: (_) {},
        );
      }

      if (result.code != MaResultName.success.code) {
        throw MaException(result);
      }

      configure(Pointer<ca_device_info> handle) {
        memory.copyMemory(handle.cast(), pInfo.cast(), sizeOf<ca_device_info>());
      }

      switch (context.activeBackend) {
        case AudioDeviceBackend.coreAudio:
          return CoreAudioDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.aaudio:
          return AAudioDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.openSLES:
          return OpenSLESDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.wasapi:
          return WasapiDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.alsa:
          return AlsaDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.pulseAudio:
          return PulseAudioDeviceInfo(type: type, memory: memory, configure: configure);
        case AudioDeviceBackend.jack:
          return JackDeviceInfo(type: type, memory: memory, configure: configure);
      }
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
    super.device,
    super.memory,
    super.noFixedSizedProcess = false,
  }) : super(rawType: ca_device_type.ca_device_type_playback);

  late final _pFramesWrite = allocateManaged<Int>(sizeOf<Int>());

  @override
  AudioDeviceType get type => AudioDeviceType.playback;

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  PlaybackDeviceWriteResult write(AudioBuffer buffer) {
    final result = bindings.ca_device_playback_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
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
    super.device,
    super.memory,
    super.noFixedSizedProcess = false,
  }) : super(rawType: ca_device_type.ca_device_type_capture);

  late final _pFramesRead = allocateManaged<Int>(sizeOf<Int>());

  @override
  AudioDeviceType get type => AudioDeviceType.capture;

  /// Read device's internal buffer into [buffer].
  CaptureDeviceReadResult read(AudioBuffer buffer) {
    final result = bindings.ca_device_capture_read(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).toMaResult();
    if (!result.isSuccess && !result.isEnd) {
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
