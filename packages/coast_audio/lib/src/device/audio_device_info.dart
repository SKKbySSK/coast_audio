import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio/generated/bindings.dart';
import 'package:coast_audio/src/interop/ca_device_interop.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

typedef AudioDeviceInfoConfigureCallback = void Function(Pointer<ca_device_info> handle);

class AudioDeviceInfo extends CaDeviceInterop {
  AudioDeviceInfo({
    required this.type,
    required this.backend,
    required AudioDeviceInfoConfigureCallback configure,
    super.memory,
  }) {
    configure(_pInfo);
  }

  late final _pInfo = allocateManaged<ca_device_info>(sizeOf<ca_device_info>());

  AudioDeviceId get id {
    return switch (backend) {
      AudioDeviceBackend.coreAudio => AudioDeviceId.fromArrayChar(_pInfo.ref.id.coreaudio, 256, memory: memory),
      AudioDeviceBackend.aaudio => AudioDeviceId.fromInt(_pInfo.ref.id.aaudio, memory: memory),
      AudioDeviceBackend.openSLES => AudioDeviceId.fromInt(_pInfo.ref.id.opensl, memory: memory),
      AudioDeviceBackend.wasapi => AudioDeviceId.fromArrayWChar(_pInfo.ref.id.wasapi, 256, memory: memory),
      AudioDeviceBackend.alsa => AudioDeviceId.fromArrayChar(_pInfo.ref.id.alsa, 256, memory: memory),
      AudioDeviceBackend.pulseAudio => AudioDeviceId.fromArrayChar(_pInfo.ref.id.pulse, 256, memory: memory),
      AudioDeviceBackend.jack => AudioDeviceId.fromInt(_pInfo.ref.id.jack, memory: memory),
    };
  }

  String get name => _pInfo.ref.name.getString(256);

  bool get isDefault => _pInfo.ref.isDefault.toBool();

  final AudioDeviceType type;

  final AudioDeviceBackend backend;
}
