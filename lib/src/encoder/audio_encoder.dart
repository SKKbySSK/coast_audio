import 'package:coast_audio/coast_audio.dart';

/// The result of [AudioEncoder.encode].
///
/// [frames] is the number of frames encoded.
class AudioEncodeResult {
  const AudioEncodeResult({
    required this.frames,
  });
  final int frames;
}

/// An abstract class for audio encoders.
abstract class AudioEncoder {
  /// Input format of the encoder.
  ///
  /// Call the [encode] method with an [AudioBuffer] in this format.
  AudioFormat get inputFormat;

  /// Starts encoding.
  ///
  /// Call this method before calling [encode].
  void start();

  /// Encodes the audio from [buffer].
  AudioEncodeResult encode(AudioBuffer buffer);

  /// Finishes encoding.
  void finalize();
}
