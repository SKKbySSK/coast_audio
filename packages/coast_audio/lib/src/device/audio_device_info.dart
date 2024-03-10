import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/ffi_extension.dart';

import '../interop/coast_audio_interop.dart';
import '../interop/generated/bindings.dart';
import '../interop/ma_extension.dart';

typedef AudioDeviceInfoConfigureCallback = void Function(Pointer<ca_device_info> handle);

class AudioDeviceInfo extends CoastAudioInterop {
  AudioDeviceInfo({
    required this.type,
    required this.backend,
    required AudioDeviceInfoConfigureCallback configure,
  }) {
    configure(_pInfo);
  }

  late final _pInfo = allocateManaged<ca_device_info>(sizeOf<ca_device_info>());

  AudioDeviceId get id {
    return switch (backend) {
      AudioDeviceBackend.coreAudio => AudioDeviceId.fromArrayChar(_pInfo.ref.id.coreaudio, 256),
      AudioDeviceBackend.aaudio => AudioDeviceId.fromInt(_pInfo.ref.id.aaudio),
      AudioDeviceBackend.openSLES => AudioDeviceId.fromInt(_pInfo.ref.id.opensl),
      AudioDeviceBackend.wasapi => AudioDeviceId.fromArrayWChar(_pInfo.ref.id.wasapi, 256),
      AudioDeviceBackend.alsa => AudioDeviceId.fromArrayChar(_pInfo.ref.id.alsa, 256),
      AudioDeviceBackend.pulseAudio => AudioDeviceId.fromArrayChar(_pInfo.ref.id.pulse, 256),
      AudioDeviceBackend.jack => AudioDeviceId.fromInt(_pInfo.ref.id.jack),
    };
  }

  String get name => _pInfo.ref.name.getUtf8String(256);

  bool get isDefault => _pInfo.ref.isDefault.asMaBool();

  final AudioDeviceType type;

  final AudioDeviceBackend backend;
}
