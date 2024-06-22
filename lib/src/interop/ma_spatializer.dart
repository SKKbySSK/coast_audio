import 'dart:ffi';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';

class MaSpatializer {
  MaSpatializer({
    required ma_spatializer_config config,
  }) {
    _interop.allocateTemporary<ma_spatializer_config, void>(
      sizeOf<ma_spatializer_config>(),
      (pConfig) {
        pConfig.ref = config;
        _interop.bindings.ma_spatializer_init(pConfig, nullptr, _pSpatializer).throwMaResultIfNeeded();
      },
    );

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();
  late final _pSpatializer = _interop.allocateManaged<ma_spatializer>(sizeOf<ma_spatializer>());
  late final _pFloatProp = _interop.allocateManaged<Float>(sizeOf<Float>());

  double get masterVolume {
    _interop.bindings.ma_spatializer_get_master_volume(_pSpatializer, _pFloatProp).throwMaResultIfNeeded();
    return _pFloatProp.value;
  }

  AudioAttenuationModel get attenuationModel {
    final maValue = _interop.bindings.ma_spatializer_get_attenuation_model(_pSpatializer);
    return AudioAttenuationModel.values.firstWhere((e) => e.maValue == maValue);
  }

  AudioPositioning get positioning {
    final maValue = _interop.bindings.ma_spatializer_get_positioning(_pSpatializer);
    return AudioPositioning.values.firstWhere((e) => e.maValue == maValue);
  }

  double get minGain => _interop.bindings.ma_spatializer_get_min_gain(_pSpatializer);
  double get maxGain => _interop.bindings.ma_spatializer_get_max_gain(_pSpatializer);
  double get minDistance => _interop.bindings.ma_spatializer_get_min_distance(_pSpatializer);
  double get maxDistance => _interop.bindings.ma_spatializer_get_max_distance(_pSpatializer);
  double get rolloff => _interop.bindings.ma_spatializer_get_rolloff(_pSpatializer);

  double get coneInnerAngleInRadians {
    _interop.bindings.ma_spatializer_get_cone(_pSpatializer, _pFloatProp, nullptr, nullptr);
    return _pFloatProp.value;
  }

  double get coneOuterAngleInRadians {
    _interop.bindings.ma_spatializer_get_cone(_pSpatializer, nullptr, _pFloatProp, nullptr);
    return _pFloatProp.value;
  }

  double get coneOuterGain {
    _interop.bindings.ma_spatializer_get_cone(_pSpatializer, nullptr, nullptr, _pFloatProp);
    return _pFloatProp.value;
  }

  double get dopplerFactor => _interop.bindings.ma_spatializer_get_doppler_factor(_pSpatializer);
  double get directionalAttenuationFactor => _interop.bindings.ma_spatializer_get_directional_attenuation_factor(_pSpatializer);

  AudioVector3 get position {
    final vec3 = _interop.bindings.ma_spatializer_get_position(_pSpatializer);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  AudioVector3 get direction {
    final vec3 = _interop.bindings.ma_spatializer_get_direction(_pSpatializer);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  AudioVector3 get velocity {
    final vec3 = _interop.bindings.ma_spatializer_get_velocity(_pSpatializer);
    return AudioVector3(vec3.x, vec3.y, vec3.z);
  }

  set masterVolume(double value) => _interop.bindings.ma_spatializer_set_master_volume(_pSpatializer, value);

  set attenuationModel(AudioAttenuationModel value) {
    _interop.bindings.ma_spatializer_set_attenuation_model(_pSpatializer, value.maValue);
  }

  set positioning(AudioPositioning value) {
    _interop.bindings.ma_spatializer_set_positioning(_pSpatializer, value.maValue);
  }

  set minGain(double value) => _interop.bindings.ma_spatializer_set_min_gain(_pSpatializer, value);
  set maxGain(double value) => _interop.bindings.ma_spatializer_set_max_gain(_pSpatializer, value);
  set minDistance(double value) => _interop.bindings.ma_spatializer_set_min_distance(_pSpatializer, value);
  set maxDistance(double value) => _interop.bindings.ma_spatializer_set_max_distance(_pSpatializer, value);
  set rolloff(double value) => _interop.bindings.ma_spatializer_set_rolloff(_pSpatializer, value);

  void setCone(double innerAngleInRadians, double outerAngleInRadians, double outerGain) {
    _interop.bindings.ma_spatializer_set_cone(_pSpatializer, innerAngleInRadians, outerAngleInRadians, outerGain);
  }

  set dopplerFactor(double value) => _interop.bindings.ma_spatializer_set_doppler_factor(_pSpatializer, value);
  set directionalAttenuationFactor(double value) => _interop.bindings.ma_spatializer_set_directional_attenuation_factor(_pSpatializer, value);

  set position(AudioVector3 value) {
    _interop.bindings.ma_spatializer_set_position(_pSpatializer, value.x, value.y, value.z);
  }

  set direction(AudioVector3 value) {
    _interop.bindings.ma_spatializer_set_direction(_pSpatializer, value.x, value.y, value.z);
  }

  set velocity(AudioVector3 value) {
    _interop.bindings.ma_spatializer_set_velocity(_pSpatializer, value.x, value.y, value.z);
  }

  int process(AudioSpatializerListener listener, AudioBuffer input, AudioBuffer output) {
    final frameCount = min(input.sizeInFrames, output.sizeInFrames);
    _interop.bindings
        .ma_spatializer_process_pcm_frames(
          _pSpatializer,
          listener.handle,
          output.pBuffer.cast(),
          input.pBuffer.cast(),
          frameCount,
        )
        .throwMaResultIfNeeded();

    return frameCount;
  }

  void dispose() {
    _interop.bindings.ma_spatializer_uninit(_pSpatializer, nullptr);
    _interop.dispose();
  }
}
