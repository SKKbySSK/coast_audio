import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

/// The result of [AudioEncoder.encode].
///
/// [frameCount] is the number of frames encoded.
class AudioEncodeResult {
  const AudioEncodeResult({
    required this.frameCount,
  });
  final int frameCount;
}

/// An abstract class for audio encoders.
abstract class AudioEncoder {
  /// Input format of the encoder.
  ///
  /// Call the [encode] method with an [AudioBuffer] in this format.
  AudioFormat get inputFormat;

  /// Whether the encoder is started or not.
  bool get isStarted;

  /// Starts encoding.
  ///
  /// Call this method before calling [encode].
  void start();

  /// Encodes the audio from [buffer].
  AudioEncodeResult encode(AudioBuffer buffer);

  /// Finishes encoding.
  void finalize();

  /// Throws a [StateError] if the encoder is not started.
  @protected
  void throwIfNotStarted() {
    if (!isStarted) {
      throw StateError('The encoder is not started.');
    }
  }
}
