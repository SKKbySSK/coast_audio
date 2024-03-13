/// Sample format which represents the format of the audio data.
enum SampleFormat {
  /// Unsigned 8bit interger format.
  uint8(1, 255, 0, 128),

  /// Signed 16bit integer format.
  int16(2, 32767, -32768, 0),

  /// Signed 32bit integer format.
  int32(4, 2147483647, -2147483648, 0),

  /// 32bit floating point. Most of nodes supports this format only.
  float32(4, 1.0, -1.0, 0);

  const SampleFormat(this.size, this.max, this.min, this.mid);

  /// Number of bytes of the sample.
  final int size;

  /// Maximum value of the sample.
  final num max;

  /// Minimum value of the sample.
  final num min;

  /// Middle value of the sample.
  final num mid;
}
