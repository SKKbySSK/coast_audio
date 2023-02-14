enum SampleFormat {
  /// 32bit floating point
  float(4);

  const SampleFormat(this.size);

  final int size;
}
