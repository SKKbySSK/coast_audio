import 'package:coast_audio/coast_audio.dart';

/// [AudioFrame] is a base class of audio buffers.
/// You can call [lock] to request internal lock and retrieve the [AudioFrameBuffer].
/// When you call [lock], you must call [unlock] when the raw buffer operations is not necessary.
/// [Memory] will be used internal buffer allocations.
abstract class AudioFrame {
  const AudioFrame();

  /// size of [pBuffer] in bytes.
  int get sizeInBytes;

  /// size of [pBuffer] in frames.
  int get sizeInFrames;

  /// format of [pBuffer].
  AudioFormat get format;

  /// lock the internal buffer and returns [AudioFrameBuffer].
  /// You are responsible for calling [unlock] when you don't need it.
  /// You can use the [acquireBuffer] method to safely acquiring [AudioFrameBuffer] instead.
  AudioFrameBuffer lock();

  /// [unlock] the internal buffer.
  void unlock();
}
