enum AudioAttenuationModel {
  /// No attenuation model is applied.
  none(0),

  /// The inverse distance attenuation model.
  inverseDistance(1),

  /// The linear distance attenuation model.
  linearDistance(2),

  /// The exponential distance attenuation model.
  exponentialDistance(3),
  ;

  const AudioAttenuationModel(this.maValue);
  final int maValue;
}
