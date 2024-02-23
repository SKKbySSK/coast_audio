import 'dart:ffi';

import 'package:coast_audio/ca_device/bindings.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ca_device_interop.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

class AudioDeviceContext extends CaDeviceInterop {
  AudioDeviceContext({
    required List<AudioDeviceBackend> backends,
    super.memory,
  }) {
    allocateTemporary<Int32>(sizeOf<Int32>() * backends.length, (pBackends) {
      final list = pBackends.asTypedList(backends.length);
      for (var i = 0; i < backends.length; i++) {
        list[i] = backends[i].caValue;
      }
      bindings.ca_device_context_init(_pContext, pBackends, backends.length).throwMaResultIfNeeded();
    });
  }

  late final _pContext = allocateManaged<ca_device_context>(sizeOf<ca_device_context>());

  Pointer<ca_device_context> get handle => _pContext;

  AudioDeviceBackend get activeBackend {
    return AudioDeviceBackend.values.firstWhere(
      (v) => _pContext.ref.backend == v.caValue,
    );
  }

  List<AudioDeviceInfo<dynamic>> getDevices(AudioDeviceType type) {
    final devices = <AudioDeviceInfo>[];
    allocateTemporary<Int>(sizeOf<Int>(), (pCount) {
      bindings.ca_device_context_get_device_count(_pContext, type.caValue, pCount).throwMaResultIfNeeded();
      for (var i = 0; pCount.value > i; i++) {
        final info = _CaDeviceInfoRetriever(pContext: _pContext, index: i, type: type, backend: activeBackend);
        devices.add(info.getDeviceInfo(type));
      }
    });
    return devices;
  }
}

class _CaDeviceInfoRetriever extends CaDeviceInterop {
  _CaDeviceInfoRetriever({
    required Pointer<ca_device_context> pContext,
    required int index,
    required AudioDeviceType type,
    required this.backend,
  }) {
    _configure = (handle) {
      bindings.ca_device_context_get_device_info(pContext, type.caValue, index, handle).throwMaResultIfNeeded();
    };
  }
  final AudioDeviceBackend backend;
  late final AudioDeviceInfoConfigureCallback _configure;

  AudioDeviceInfo<dynamic> getDeviceInfo(AudioDeviceType type) {
    switch (backend) {
      case AudioDeviceBackend.coreAudio:
        return CoreAudioDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.aaudio:
        return AAudioDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.openSLES:
        return OpenSLESDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.wasapi:
        return WasapiDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.alsa:
        return AlsaDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.pulseAudio:
        return PulseAudioDeviceInfo(type: type, memory: memory, configure: _configure);
      case AudioDeviceBackend.jack:
        return JackDeviceInfo(type: type, memory: memory, configure: _configure);
    }
  }
}
