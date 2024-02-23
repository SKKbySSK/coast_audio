import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/generated/bindings.dart';
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

  List<AudioDeviceInfo> getDevices(AudioDeviceType type) {
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
}
