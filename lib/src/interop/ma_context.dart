import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ca_device.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';

class MaContext {
  MaContext({
    required List<AudioDeviceBackend> backends,
    Pointer<ma_log>? pLog,
  }) {
    _interop.allocateTemporary<Int32, void>(sizeOf<Int32>() * backends.length, (pBackends) {
      final list = pBackends.asTypedList(backends.length);
      for (var i = 0; i < backends.length; i++) {
        list[i] = backends[i].maValue;
      }

      _interop.allocateTemporary<ma_context_config, void>(
        sizeOf<ma_context_config>(),
        (pConfig) {
          pConfig.ref = _interop.bindings.ma_context_config_init();
          pConfig.ref.coreaudio.noAudioSessionActivate = true.toMaBool();
          pConfig.ref.coreaudio.noAudioSessionDeactivate = true.toMaBool();
          pConfig.ref.pLog = pLog ?? nullptr;

          _interop.bindings.ma_context_init(pBackends, backends.length, pConfig, _pContext).throwMaResultIfNeeded();
        },
      );
    });

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();

  final _associatedDevices = <CaDevice>[];

  late final _pContext = _interop.allocateManaged<ma_context>(sizeOf<ma_context>());

  Pointer<ma_context> get handle => _pContext;

  AudioDeviceBackend get activeBackend {
    _interop.throwIfDisposed();
    return AudioDeviceBackend.values.firstWhere(
      (v) => _pContext.ref.backend == v.maValue,
    );
  }

  List<AudioDeviceInfo> getDevices(AudioDeviceType type) {
    _interop.throwIfDisposed();
    final devices = <AudioDeviceInfo>[];
    _interop.allocateTemporary<UnsignedInt, void>(sizeOf<UnsignedInt>(), (pCount) {
      _interop.allocateTemporary<IntPtr, void>(
        sizeOf<IntPtr>(),
        (ppDevices) {
          switch (type) {
            case AudioDeviceType.capture:
              _interop.bindings.ma_context_get_devices(_pContext, nullptr, nullptr, ppDevices.cast(), pCount).throwMaResultIfNeeded();
            case AudioDeviceType.playback:
              _interop.bindings.ma_context_get_devices(_pContext, ppDevices.cast(), pCount, nullptr, nullptr).throwMaResultIfNeeded();
          }
          final pDevices = Pointer.fromAddress(ppDevices.value).cast<ma_device_info>();
          for (var i = 0; pCount.value > i; i++) {
            final info = AudioDeviceInfo(
              type: type,
              backend: activeBackend,
              configure: (handle) {
                final pDevice = Pointer<ma_device_info>.fromAddress(pDevices.address + i * sizeOf<ma_device_info>());
                handle.ref = pDevice.ref;
              },
            );
            devices.add(info);
          }
        },
      );
    });
    return devices;
  }

  CaDevice createDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    required AudioDeviceType type,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
    AudioFormatConverterConfig converter = const AudioFormatConverterConfig(),
  }) {
    _interop.throwIfDisposed();
    final device = CaDevice(
      context: this,
      format: format,
      type: type,
      bufferFrameSize: bufferFrameSize,
      deviceId: deviceId,
      noFixedSizedProcess: noFixedSizedProcess,
      performanceProfile: performanceProfile,
      converter: converter,
    );
    _associatedDevices.add(device);
    return device;
  }

  void dispose() {
    for (final device in _associatedDevices) {
      device.dispose();
    }
    _associatedDevices.clear();
    _interop.bindings.ma_context_uninit(_pContext).throwMaResultIfNeeded();
    _interop.dispose();
  }
}
