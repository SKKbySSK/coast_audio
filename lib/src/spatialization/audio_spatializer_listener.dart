import 'dart:ffi';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/ma_spatializer_listener.dart';

class AudioSpatializerListener with AudioResourceMixin {
  AudioSpatializerListener({
    required this.outputFormat,
    AudioVector3 worldUp = const AudioVector3(0, 1, 0),
    double coneInnerAngleInRadians = pi * 2,
    double coneOuterAngleInRadians = 0,
    double coneOuterGain = 0,
    double speedOfSound = 343.3,
  }) {
    final memory = Memory();
    final pWorldUp = memory.allocator.allocate<ma_vec3f>(sizeOf<ma_vec3f>());
    try {
      pWorldUp.ref.x = worldUp.x;
      pWorldUp.ref.y = worldUp.y;
      pWorldUp.ref.z = worldUp.z;

      final config = CoastAudioNative.bindings.ma_spatializer_listener_config_init(outputFormat.channels);
      config.worldUp = pWorldUp.ref;
      config.coneInnerAngleInRadians = coneInnerAngleInRadians;
      config.coneOuterAngleInRadians = coneOuterAngleInRadians;
      config.coneOuterGain = coneOuterGain;
      config.speedOfSound = speedOfSound;

      _listener = MaSpatializerListener(config: config);
    } finally {
      memory.allocator.free(pWorldUp);
    }

    setResourceFinalizer(_listener.dispose);
  }

  final AudioFormat outputFormat;

  late final MaSpatializerListener _listener;

  Pointer<ma_spatializer_listener> get handle => _listener.handle;

  double get coneInnerAngleInRadians => _listener.coneInnerAngleInRadians;
  double get coneOuterAngleInRadians => _listener.coneOuterAngleInRadians;
  double get coneOuterGain => _listener.coneOuterGain;
  double get speedOfSound => _listener.speedOfSound;
  AudioVector3 get position => _listener.position;
  AudioVector3 get direction => _listener.direction;
  AudioVector3 get velocity => _listener.velocity;

  set speedOfSound(double value) => _listener.speedOfSound = value;
  set position(AudioVector3 value) => _listener.position = value;
  set direction(AudioVector3 value) => _listener.direction = value;
  set velocity(AudioVector3 value) => _listener.velocity = value;

  void setCone({
    double? innerAngleInRadians,
    double? outerAngleInRadians,
    double? outerGain,
  }) {
    _listener.setCone(
      innerAngleInRadians ?? coneInnerAngleInRadians,
      outerAngleInRadians ?? coneOuterAngleInRadians,
      outerGain ?? coneOuterGain,
    );
  }
}
