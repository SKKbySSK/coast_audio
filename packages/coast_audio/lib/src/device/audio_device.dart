import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';

import '../interop/coast_audio_interop.dart';
import '../interop/generated/bindings.dart';
import '../interop/ma_extension.dart';

class AudioDeviceContext extends CoastAudioInterop {
  AudioDeviceContext({required List<AudioDeviceBackend> backends}) {
    final pContext = memory.allocator.allocate<ca_device_context>(sizeOf<ca_device_context>());
    allocateTemporary<Int32>(sizeOf<Int32>() * backends.length, (pBackends) {
      final list = pBackends.asTypedList(backends.length);
      for (var i = 0; i < backends.length; i++) {
        list[i] = backends[i].maValue;
      }
      bindings.ca_device_context_init(pContext, pBackends, backends.length).throwMaResultIfNeeded();
    });

    _pContext = pContext;
  }

  late final Pointer<ca_device_context> _pContext;

  var _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _deviceResourceIds = <int>{};

  AudioDeviceBackend get activeBackend {
    throwIfDisposed();

    return AudioDeviceBackend.values.firstWhere(
      (v) => _pContext.ref.backend == v.maValue,
    );
  }

  List<AudioDeviceInfo> getDevices(AudioDeviceType type) {
    throwIfDisposed();

    final devices = <AudioDeviceInfo>[];
    allocateTemporary<Int>(sizeOf<Int>(), (pCount) {
      bindings.ca_device_context_get_device_count(_pContext, type.caValue, pCount).throwMaResultIfNeeded();
      for (var i = 0; pCount.value > i; i++) {
        final info = AudioDeviceInfo(
          type: type,
          backend: activeBackend,
          configure: (handle) {
            bindings.ca_device_context_get_device_info(_pContext, type.caValue, i, handle).throwMaResultIfNeeded();
          },
        );
        devices.add(info);
      }
    });
    return devices;
  }

  PlaybackDevice createPlaybackDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
  }) {
    final device = PlaybackDevice._initWithContext(
      context: this,
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: deviceId,
      noFixedSizedProcess: noFixedSizedProcess,
      channelMixMode: channelMixMode,
      performanceProfile: performanceProfile,
    );
    _deviceResourceIds.add(device.resourceId);
    return device;
  }

  CaptureDevice createCaptureDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
  }) {
    final device = CaptureDevice._initWithContext(
      context: this,
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: deviceId,
      noFixedSizedProcess: noFixedSizedProcess,
      channelMixMode: channelMixMode,
      performanceProfile: performanceProfile,
    );
    _deviceResourceIds.add(device.resourceId);
    return device;
  }

  void throwIfDisposed() {
    if (isDisposed) {
      throw AudioResourceDisposedException(runtimeType.toString());
    }
  }

  void dispose() {
    if (isDisposed) {
      return;
    }
    for (final id in _deviceResourceIds) {
      AudioResourceManager.dispose(id);
    }
    bindings.ca_device_context_uninit(_pContext);
    memory.allocator.free(_pContext);
    _isDisposed = true;
  }
}

abstract class AudioDevice extends CoastAudioInterop with AudioResourceMixin {
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
  }) : _initialDeviceId = deviceId {
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

    final pDeviceId = _pDeviceId;
    if (pDeviceId != null) {
      final deviceIdData = pDeviceId.cast<Uint8>().asTypedList(sizeOf<ca_device_id>());
      deviceIdData.setAll(0, _initialDeviceId!.data);
      bindings.ca_device_init(_pDevice, config, context._pContext, pDeviceId).throwMaResultIfNeeded();
    } else {
      bindings.ca_device_init(_pDevice, config, context._pContext, nullptr).throwMaResultIfNeeded();
    }
  }

  /// Current device context for this instance.
  final AudioDeviceContext context;

  final AudioDeviceType type;

  final int bufferFrameSize;

  /// The device's format.
  /// If the device supports format natively, no conversion will occurs.
  /// Otherwise, miniaudio will try to convert the format.
  final AudioFormat format;

  final AudioDeviceId? _initialDeviceId;

  late final _pDevice = memory.allocator.allocate<ca_device>(sizeOf<ca_device>());

  late final _pVolume = memory.allocator.allocate<Float>(sizeOf<Float>());

  late final _pDeviceId = _initialDeviceId == null ? null : memory.allocator.allocate<ca_device_id>(sizeOf<ca_device_id>());

  final _notificationPort = ReceivePort();

  /// The device's notification stream.
  /// Use this stream to detecting route and lifecycle changes.
  late final notification =
      _notificationPort.cast<int>().map((type) => AudioDeviceNotification.values.firstWhere((n) => n.caValue == type)).asBroadcastStream();

  var _isStarted = false;

  /// A flag indicates the device is started or not.
  bool get isStarted => _isStarted;

  /// Available buffered frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableReadFrames {
    throwIfDisposed();
    return bindings.ca_device_available_read(_pDevice);
  }

  /// Available writable frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableWriteFrames {
    throwIfDisposed();
    return bindings.ca_device_available_write(_pDevice);
  }

  /// The current volume of the device.
  double get volume {
    throwIfDisposed();
    bindings.ca_device_get_volume(_pDevice, _pVolume).throwMaResultIfNeeded();
    return _pVolume.value;
  }

  /// Set the volume of the device.
  set volume(double value) {
    throwIfDisposed();
    bindings.ca_device_set_volume(_pDevice, value).throwMaResultIfNeeded();
  }

  AudioDeviceState get state {
    throwIfDisposed();
    final state = bindings.ca_device_get_state(_pDevice);
    return AudioDeviceState.values.firstWhere((s) => s.caValue == state);
  }

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  AudioDeviceInfo? get deviceInfo {
    throwIfDisposed();

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
    throwIfDisposed();
    bindings.ca_device_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  /// Stop the audio device.
  /// When [clearBuffer] is set to true, internal buffer will be cleared automatically (true by default).
  void stop({bool clearBuffer = true}) {
    throwIfDisposed();
    bindings.ca_device_stop(_pDevice).throwMaResultIfNeeded();
    if (clearBuffer) {
      this.clearBuffer();
    }
    _isStarted = false;
  }

  /// Clear the internal buffer.
  void clearBuffer() {
    throwIfDisposed();
    bindings.ca_device_clear_buffer(_pDevice);
  }

  @override
  void setResourceFinalizer<T>(void Function() onFinalize) {
    final captured = (bindings, memory, _pDevice, _pVolume, _pDeviceId, _notificationPort);
    super.setResourceFinalizer(() {
      onFinalize();

      final (bindings, memory, pDevice, pVolume, pDeviceId, notificationPort) = captured;
      bindings.ca_device_uninit(pDevice);
      notificationPort.close();
      memory.allocator.free(pDevice);
      if (pDeviceId != null) {
        memory.allocator.free(pDeviceId);
      }
      memory.allocator.free(pVolume);
    });
  }
}

class PlaybackDevice extends AudioDevice {
  PlaybackDevice._initWithContext({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.deviceId,
    super.noFixedSizedProcess = false,
    super.channelMixMode,
    super.performanceProfile,
  }) : super(type: AudioDeviceType.playback) {
    final captured = (memory, _pFramesWrite);
    setResourceFinalizer(() {
      captured.$1.allocator.free(captured.$2);
    });
  }

  late final _pFramesWrite = memory.allocator.allocate<Int>(sizeOf<Int>());

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  PlaybackDeviceWriteResult write(AudioBuffer buffer) {
    throwIfDisposed();

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
  CaptureDevice._initWithContext({
    required super.context,
    required super.format,
    required super.bufferFrameSize,
    super.deviceId,
    super.noFixedSizedProcess = false,
    super.channelMixMode,
    super.performanceProfile,
  }) : super(type: AudioDeviceType.capture) {
    final captured = (memory, _pFramesRead);
    setResourceFinalizer(() {
      captured.$1.allocator.free(captured.$2);
    });
  }

  late final _pFramesRead = memory.allocator.allocate<Int>(sizeOf<Int>());

  /// Read device's internal buffer into [buffer].
  CaptureDeviceReadResult read(AudioBuffer buffer) {
    throwIfDisposed();

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
