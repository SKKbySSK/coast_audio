class AudioReadResult {
  const AudioReadResult({
    required this.frameCount,
    required this.isEnd,
  });
  final int frameCount;
  final bool isEnd;
}
