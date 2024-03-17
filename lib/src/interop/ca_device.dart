import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';

class CaDeviceContext {
  CaDeviceContext({required List<AudioDeviceBackend> backends}) {
    _interop.allocateTemporary<Int32, void>(sizeOf<Int32>() * backends.length, (pBackends) {
      final list = pBackends.asTypedList(backends.length);
      for (var i = 0; i < backends.length; i++) {
        list[i] = backends[i].maValue;
      }
      _interop.bindings.ca_device_context_init(_pContext, pBackends, backends.length).throwMaResultIfNeeded();
    });

    _interop.onDispose = () {
      for (final device in _associatedDevices) {
        device.dispose();
      }
      _associatedDevices.clear();
      _interop.bindings.ca_device_context_uninit(_pContext).throwMaResultIfNeeded();
    };

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();

  final _associatedDevices = <CaDevice>[];

  late final _pContext = _interop.allocateManaged<ca_device_context>(sizeOf<ca_device_context>());

  AudioDeviceBackend get activeBackend {
    _interop.throwIfDisposed();
    return AudioDeviceBackend.values.firstWhere(
      (v) => _pContext.ref.backend == v.maValue,
    );
  }

  List<AudioDeviceInfo> getDevices(AudioDeviceType type) {
    _interop.throwIfDisposed();
    final devices = <AudioDeviceInfo>[];
    _interop.allocateTemporary<Int, void>(sizeOf<Int>(), (pCount) {
      _interop.bindings.ca_device_context_get_device_count(_pContext, type.maValue, pCount).throwMaResultIfNeeded();
      for (var i = 0; pCount.value > i; i++) {
        final info = AudioDeviceInfo(
          type: type,
          backend: activeBackend,
          configure: (handle) {
            _interop.bindings.ca_device_context_get_device_info(_pContext, type.maValue, i, handle).throwMaResultIfNeeded();
          },
        );
        devices.add(info);
      }
    });
    return devices;
  }

  CaDevice createDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    required AudioDeviceType type,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
  }) {
    _interop.throwIfDisposed();
    final device = CaDevice(
      context: this,
      format: format,
      type: type,
      bufferFrameSize: bufferFrameSize,
      deviceId: deviceId,
      noFixedSizedProcess: noFixedSizedProcess,
      channelMixMode: channelMixMode,
      performanceProfile: performanceProfile,
    );
    _associatedDevices.add(device);
    return device;
  }

  void dispose() {
    _interop.dispose();
  }
}

class CaDevice {
  CaDevice({
    required this.type,
    required this.context,
    required this.format,
    required this.bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioChannelMixMode channelMixMode = AudioChannelMixMode.rectangular,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
  }) : _initialDeviceId = deviceId {
    final config = _interop.bindings.ca_device_config_init(
      type.maValue,
      format.sampleFormat.maFormat,
      format.sampleRate,
      format.channels,
      bufferFrameSize,
      _notificationPort.sendPort.nativePort,
    );
    config.noFixedSizedCallback = noFixedSizedProcess.toMaBool();
    config.channelMixMode = channelMixMode.maValue;
    config.performanceProfile = performanceProfile.maValue;

    final pDeviceId = _pDeviceId;
    if (pDeviceId != null) {
      final deviceIdData = pDeviceId.cast<Uint8>().asTypedList(sizeOf<ca_device_id>());
      deviceIdData.setAll(0, _initialDeviceId!.data);
      _interop.bindings.ca_device_init(_pDevice, config, context._pContext, pDeviceId).throwMaResultIfNeeded();
    } else {
      _interop.bindings.ca_device_init(_pDevice, config, context._pContext, nullptr).throwMaResultIfNeeded();
    }

    notification.listen((notification) {
      _isStarted = switch (notification.state) {
        AudioDeviceState.starting => true,
        AudioDeviceState.started => true,
        AudioDeviceState.stopping => false,
        AudioDeviceState.stopped => false,
        AudioDeviceState.uninitialized => false,
      };
    });

    _interop.onDispose = () {
      _interop.bindings.ca_device_uninit(_pDevice);
      _notificationPort.close();
    };

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();

  final CaDeviceContext context;

  final AudioDeviceType type;

  final int bufferFrameSize;

  final AudioFormat format;

  final AudioDeviceId? _initialDeviceId;

  late final _pDevice = _interop.allocateManaged<ca_device>(sizeOf<ca_device>());

  late final _pVolume = _interop.allocateManaged<Float>(sizeOf<Float>());

  late final _pDeviceId = _initialDeviceId == null ? null : _interop.allocateManaged<ca_device_id>(sizeOf<ca_device_id>());

  late final _pFramesRead = _interop.allocateManaged<Int>(sizeOf<Int>());

  late final _pFramesWrite = _interop.allocateManaged<Int>(sizeOf<Int>());

  final _notificationPort = ReceivePort();

  /// The device's notification stream.
  /// Use this stream to detecting route and lifecycle changes.
  late final notification = _notificationPort
      .cast<int>()
      .map(Pointer<ca_device_notification>.fromAddress)
      .map((pNotification) => AudioDeviceNotification.fromPointer(pNotification))
      .asBroadcastStream();

  var _isStarted = false;

  /// A flag indicates the device is started or not.
  bool get isStarted => _isStarted;

  /// Available buffered frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableReadFrames {
    return _interop.bindings.ca_device_available_read(_pDevice);
  }

  /// Available writable frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableWriteFrames {
    return _interop.bindings.ca_device_available_write(_pDevice);
  }

  /// The current volume of the device.
  double get volume {
    _interop.bindings.ca_device_get_volume(_pDevice, _pVolume).throwMaResultIfNeeded();
    return _pVolume.value;
  }

  /// Set the volume of the device.
  set volume(double value) {
    _interop.bindings.ca_device_set_volume(_pDevice, value).throwMaResultIfNeeded();
  }

  AudioDeviceState get state {
    if (_interop.isDisposed) {
      return AudioDeviceState.uninitialized;
    }

    final state = _interop.bindings.ca_device_get_state(_pDevice);
    return AudioDeviceState.values.firstWhere((s) => s.maValue == state);
  }

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  AudioDeviceInfo? get deviceInfo {
    return _interop.allocateTemporary<ca_device_info, AudioDeviceInfo?>(sizeOf<ca_device_info>(), (pInfo) {
      final result = _interop.bindings.ca_device_get_device_info(_pDevice, pInfo).asMaResult();

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
          _interop.memory.copyMemory(handle.cast(), pInfo.cast(), sizeOf<ca_device_info>());
        },
        backend: context.activeBackend,
      );
    });
  }

  /// Start the audio device.
  void start() {
    _interop.bindings.ca_device_start(_pDevice).throwMaResultIfNeeded();
    _isStarted = true;
  }

  /// Stop the audio device.
  /// When [clearBuffer] is set to true, internal buffer will be cleared automatically (true by default).
  void stop({bool clearBuffer = true}) {
    _interop.bindings.ca_device_stop(_pDevice).throwMaResultIfNeeded();
    if (clearBuffer) {
      this.clearBuffer();
    }
    _isStarted = false;
  }

  /// Clear the internal buffer.
  void clearBuffer() {
    _interop.bindings.ca_device_clear_buffer(_pDevice);
  }

  /// Read device's internal buffer into [buffer].
  CaptureDeviceReadResult read(AudioBuffer buffer) {
    final result = _interop.bindings.ca_device_capture_read(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).asMaResult();
    if (!result.isSuccess && result != MaResult.atEnd) {
      result.throwIfNeeded();
    }
    return CaptureDeviceReadResult(result, _pFramesRead.value);
  }

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  PlaybackDeviceWriteResult write(AudioBuffer buffer) {
    final result = _interop.bindings.ca_device_playback_write(_pDevice, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).asMaResult();
    if (!result.isSuccess && result != MaResult.atEnd) {
      result.throwIfNeeded();
    }
    return PlaybackDeviceWriteResult(result, _pFramesWrite.value);
  }

  void dispose() {
    _interop.dispose();
  }
}
