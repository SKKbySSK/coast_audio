enum SampleFormat {
  /// Unsigned 8bit interger format.
  uint8(1),

  /// Signed 16bit integer format.
  int16(2),

  /// Signed 32bit integer format.
  int32(4),

  /// 32bit floating point. Most of nodes supports this format only.
  float32(4);

  const SampleFormat(this.size);

  final int size;

  bool isCompatible(SampleFormat format) => size == format.size;
}
