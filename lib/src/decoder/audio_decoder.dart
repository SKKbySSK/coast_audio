import 'package:coast_audio/coast_audio.dart';

/// The result of [AudioDecoder.decode].
///
/// [frameCount] is the number of frames decoded.
/// [isEnd] is whether the end of the audio has been reached.
class AudioDecodeResult {
  const AudioDecodeResult({
    required this.frameCount,
    required this.isEnd,
  });
  final int frameCount;
  final bool isEnd;
}

/// An abstract class for audio decoders.
abstract class AudioDecoder {
  AudioDecoder();

  /// Output format of the decoder.
  AudioFormat get outputFormat;

  /// The length of the audio in frames.
  int? get lengthInFrames;

  /// The current position of the decoder in frames.
  int get cursorInFrames;

  /// Sets the current position of the decoder in frames.
  set cursorInFrames(int value);

  /// Whether the decoder supports seeking.
  ///
  /// If false, [cursorInFrames] cannot be set.
  bool get canSeek;

  /// Decodes the audio into [destination].
  AudioDecodeResult decode({required AudioBuffer destination});
}
