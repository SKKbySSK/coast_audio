import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';

class MaSpatializerListener {
  MaSpatializerListener({
    required ma_spatializer_listener_config config,
  }) {
    _interop.allocateTemporary<ma_spatializer_listener_config, void>(
      sizeOf<ma_spatializer_listener_config>(),
      (pConfig) {
        pConfig.ref = config;
        _interop.bindings.ma_spatializer_listener_init(pConfig, nullptr, _pListener);
      },
    );

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();
  late final _pListener = _interop.allocateManaged<ma_spatializer_listener>(sizeOf<ma_spatializer_listener>());
  late final _pFloatProp = _interop.allocateManaged<Float>(sizeOf<Float>());

  Pointer<ma_spatializer_listener> get handle => _pListener;

  double get coneInnerAngleInRadians {
    _interop.bindings.ma_spatializer_listener_get_cone(_pListener, _pFloatProp, nullptr, nullptr);
    return _pFloatProp.value;
  }

  double get coneOuterAngleInRadians {
    _interop.bindings.ma_spatializer_listener_get_cone(_pListener, nullptr, _pFloatProp, nullptr);
    return _pFloatProp.value;
  }

  double get coneOuterGain {
    _interop.bindings.ma_spatializer_listener_get_cone(_pListener, nullptr, nullptr, _pFloatProp);
    return _pFloatProp.value;
  }

  AudioVector3 get position {
    final vec3 = _interop.bindings.ma_spatializer_listener_get_position(_pListener);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  AudioVector3 get direction {
    final vec3 = _interop.bindings.ma_spatializer_listener_get_direction(_pListener);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  AudioVector3 get velocity {
    final vec3 = _interop.bindings.ma_spatializer_listener_get_velocity(_pListener);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  double get speedOfSound => _interop.bindings.ma_spatializer_listener_get_speed_of_sound(_pListener);

  AudioVector3 get worldUp {
    final vec3 = _interop.bindings.ma_spatializer_listener_get_world_up(_pListener);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  bool get isEnabled => _interop.bindings.ma_spatializer_listener_is_enabled(_pListener).asMaBool();

  set position(AudioVector3 value) => _interop.bindings.ma_spatializer_listener_set_position(_pListener, value.x, value.y, value.z);
  set direction(AudioVector3 value) => _interop.bindings.ma_spatializer_listener_set_direction(_pListener, value.x, value.y, value.z);
  set velocity(AudioVector3 value) => _interop.bindings.ma_spatializer_listener_set_velocity(_pListener, value.x, value.y, value.z);
  set speedOfSound(double value) => _interop.bindings.ma_spatializer_listener_set_speed_of_sound(_pListener, value);
  set worldUp(AudioVector3 value) => _interop.bindings.ma_spatializer_listener_set_world_up(_pListener, value.x, value.y, value.z);
  set isEnabled(bool value) => _interop.bindings.ma_spatializer_listener_set_enabled(_pListener, value.toMaBool());

  void setCone(double innerAngleInRadians, double outerAngleInRadians, double outerGain) {
    _interop.bindings.ma_spatializer_listener_set_cone(_pListener, innerAngleInRadians, outerAngleInRadians, outerGain);
  }

  void dispose() {
    _interop.bindings.ma_spatializer_listener_uninit(_pListener, nullptr);
    _interop.dispose();
  }
}
