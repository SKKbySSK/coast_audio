enum SampleFormat {
  /// Unsigned 8bit interger format.
  uint8(1, 255, 0, 128),

  /// Signed 16bit integer format.
  int16(2, 32767, -32768, 0),

  /// Signed 32bit integer format.
  int32(4, 2147483647, -2147483648, 0),

  /// 32bit floating point. Most of nodes supports this format only.
  float32(4, 1, -1, 0);

  const SampleFormat(this.size, this.max, this.min, this.mid);

  final int size;
  final int max;
  final int min;
  final int mid;
}
