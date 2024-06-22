import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ma_spatializer.dart';

class AudioSpatializer with AudioResourceMixin {
  AudioSpatializer({
    required this.inputFormat,
    required this.outputFormat,
    AudioAttenuationModel attenuationModel = AudioAttenuationModel.inverseDistance,
    double minGain = 0,
    double maxGain = 1,
    double minDistance = 1,
    double maxDistance = 3.402823E+38,
    double rolloff = 1,
    double coneInnerAngleInRadians = pi * 2,
    double coneOuterAngleInRadians = 0,
    double coneOuterGain = 0,
    double dopplerFactor = 1.0,
    double directionalAttenuationFactor = 1.0,
    double minSpatializationChannelGain = 0.2,
    AudioTime gainSmoothTime = const AudioTime(0.0075),
  }) {
    if (inputFormat.sampleRate != outputFormat.sampleRate || inputFormat.sampleFormat != outputFormat.sampleFormat) {
      throw ArgumentError('Input and output formats must have the same channels and sample rate.');
    }

    if (inputFormat.sampleFormat != SampleFormat.float32) {
      throw AudioFormatError.unsupportedSampleFormat(inputFormat.sampleFormat);
    }

    final config = CoastAudioNative.bindings.ma_spatializer_config_init(inputFormat.channels, outputFormat.channels);
    config.attenuationModel = attenuationModel.maValue;
    config.positioning = AudioPositioning.absolute.maValue;
    config.minGain = minGain;
    config.maxGain = maxGain;
    config.minDistance = minDistance;
    config.maxDistance = maxDistance;
    config.rolloff = rolloff;
    config.coneInnerAngleInRadians = coneInnerAngleInRadians;
    config.coneOuterAngleInRadians = coneOuterAngleInRadians;
    config.coneOuterGain = coneOuterGain;
    config.dopplerFactor = dopplerFactor;
    config.directionalAttenuationFactor = directionalAttenuationFactor;
    config.gainSmoothTimeInFrames = gainSmoothTime.computeFrames(inputFormat);

    _spatializer = MaSpatializer(config: config);

    setResourceFinalizer(_spatializer.dispose);
  }

  late final MaSpatializer _spatializer;

  final AudioFormat inputFormat;
  final AudioFormat outputFormat;

  double get masterVolume => _spatializer.masterVolume;
  AudioAttenuationModel get attenuationModel => _spatializer.attenuationModel;
  double get minGain => _spatializer.minGain;
  double get maxGain => _spatializer.maxGain;
  double get minDistance => _spatializer.minDistance;
  double get maxDistance => _spatializer.maxDistance;
  double get rolloff => _spatializer.rolloff;
  double get coneInnerAngleInRadians => _spatializer.coneInnerAngleInRadians;
  double get coneOuterAngleInRadians => _spatializer.coneOuterAngleInRadians;
  double get coneOuterGain => _spatializer.coneOuterGain;
  double get dopplerFactor => _spatializer.dopplerFactor;
  double get directionalAttenuationFactor => _spatializer.directionalAttenuationFactor;
  AudioVector3 get position => _spatializer.position;
  AudioVector3 get direction => _spatializer.direction;
  AudioVector3 get velocity => _spatializer.velocity;

  set masterVolume(double volume) => _spatializer.masterVolume = volume;
  set attenuationModel(AudioAttenuationModel model) => _spatializer.attenuationModel = model;
  set minGain(double gain) => _spatializer.minGain = gain;
  set maxGain(double gain) => _spatializer.maxGain = gain;
  set minDistance(double distance) => _spatializer.minDistance = distance;
  set maxDistance(double distance) => _spatializer.maxDistance = distance;
  set rolloff(double value) => _spatializer.rolloff = value;
  set dopplerFactor(double value) => _spatializer.dopplerFactor = value;
  set directionalAttenuationFactor(double value) => _spatializer.directionalAttenuationFactor = value;
  set position(AudioVector3 value) => _spatializer.position = value;
  set direction(AudioVector3 value) => _spatializer.direction = value;
  set velocity(AudioVector3 value) => _spatializer.velocity = value;

  void setCone({
    double? innerAngleInRadians,
    double? outerAngleInRadians,
    double? outerGain,
  }) {
    _spatializer.setCone(
      innerAngleInRadians ?? coneInnerAngleInRadians,
      outerAngleInRadians ?? coneOuterAngleInRadians,
      outerGain ?? coneOuterGain,
    );
  }

  int process(AudioSpatializerListener listener, AudioBuffer input, AudioBuffer output) {
    return _spatializer.process(listener, input, output);
  }
}
