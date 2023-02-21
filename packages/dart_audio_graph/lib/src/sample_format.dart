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

  int get maxValue {
    switch (this) {
      case SampleFormat.uint8:
        return 255;
      case SampleFormat.int16:
        return 32767;
      case SampleFormat.int32:
        return 2147483647;
      case SampleFormat.float32:
        return 1;
    }
  }

  int get midValue {
    switch (this) {
      case SampleFormat.uint8:
        return 126;
      case SampleFormat.int16:
        return 0;
      case SampleFormat.int32:
        return 0;
      case SampleFormat.float32:
        return 0;
    }
  }

  int get minValue {
    switch (this) {
      case SampleFormat.uint8:
        return 0;
      case SampleFormat.int16:
        return -32768;
      case SampleFormat.int32:
        return -2147483648;
      case SampleFormat.float32:
        return -1;
    }
  }
}
