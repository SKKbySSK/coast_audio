import 'package:coast_audio/coast_audio.dart';

/// [AudioFrames] is a base class of audio buffers.
/// You can call [lock] to request internal lock and retrieve the [AudioBuffer].
/// When you call [lock], you must call [unlock] when the raw buffer operations is not necessary.
/// [Memory] will be used internal buffer allocations.
abstract class AudioFrames {
  const AudioFrames();

  /// size of [pBuffer] in bytes.
  int get sizeInBytes;

  /// size of [pBuffer] in frames.
  int get sizeInFrames;

  /// format of [pBuffer].
  AudioFormat get format;

  /// lock the internal buffer and returns [AudioBuffer].
  /// You are responsible for calling [unlock] when you don't need it.
  /// You can use the [acquireBuffer] method to safely acquiring [AudioBuffer] instead.
  AudioBuffer lock();

  /// [unlock] the internal buffer.
  void unlock();
}
