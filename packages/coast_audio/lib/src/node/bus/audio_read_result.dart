/// The result of reading audio data from a source.
class AudioReadResult {
  const AudioReadResult({
    required this.frameCount,
    required this.isEnd,
  });

  /// The number of frames read.
  final int frameCount;

  /// Whether the source has reached the end.
  final bool isEnd;
}
