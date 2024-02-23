import 'dart:ffi';

import 'package:coast_audio/ca_device/bindings.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio/src/interop/ca_device_interop.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

typedef AudioDeviceInfoConfigureCallback = void Function(Pointer<ca_device_info> handle);

sealed class AudioDeviceInfo<T> extends CaDeviceInterop {
  AudioDeviceInfo({
    required this.type,
    required this.backend,
    required AudioDeviceInfoConfigureCallback configure,
    super.memory,
  }) {
    configure(_pInfo);
  }

  late final _pInfo = allocateManaged<ca_device_info>(sizeOf<ca_device_info>());

  T get id;

  String get name => _pInfo.ref.name.getString(256);

  bool get isDefault => _pInfo.ref.isDefault.toBool();

  final AudioDeviceType type;
  final AudioDeviceBackend backend;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! AudioDeviceInfo<T> || other.backend != backend) {
      return false;
    }

    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CoreAudioDeviceInfo extends AudioDeviceInfo<String> {
  CoreAudioDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.coreAudio);

  @override
  String get id => _pInfo.ref.id.coreaudio.getString(256);
}

class AAudioDeviceInfo extends AudioDeviceInfo<int> {
  AAudioDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.aaudio);

  @override
  int get id => _pInfo.ref.id.aaudio;
}

class OpenSLESDeviceInfo extends AudioDeviceInfo<int> {
  OpenSLESDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.openSLES);

  @override
  int get id => _pInfo.ref.id.opensl;
}

class WasapiDeviceInfo extends AudioDeviceInfo<Array<WChar>> {
  WasapiDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.wasapi);

  @override
  Array<WChar> get id => _pInfo.ref.id.wasapi;
}

class PulseAudioDeviceInfo extends AudioDeviceInfo<String> {
  PulseAudioDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.pulseAudio);

  @override
  String get id => _pInfo.ref.id.pulse.getString(256);
}

class AlsaDeviceInfo extends AudioDeviceInfo<String> {
  AlsaDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.alsa);

  @override
  String get id => _pInfo.ref.id.alsa.getString(256);
}

class JackDeviceInfo extends AudioDeviceInfo<int> {
  JackDeviceInfo({
    required super.type,
    required super.configure,
    super.memory,
  }) : super(backend: AudioDeviceBackend.jack);

  @override
  int get id => _pInfo.ref.id.jack;
}

class UnknownDeviceInfo extends AudioDeviceInfo<void> {
  UnknownDeviceInfo({
    required super.type,
    required super.configure,
    required super.backend,
    super.memory,
  });

  @override
  void get id => ();
}
