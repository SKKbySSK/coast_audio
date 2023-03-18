import 'package:coast_audio/coast_audio.dart';

/// [FrameBuffer] is a base class of audio buffers.
/// You can call [lock] to request internal lock and retrieve the [RawFrameBuffer].
/// When you call [lock], you must call [unlock] when the raw buffer operations is not necessary.
/// [Memory] will be used internal buffer allocations.
abstract class FrameBuffer {
  FrameBuffer({
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  /// size of [pBuffer] in bytes.
  final int sizeInBytes;

  /// size of [pBuffer] in frames.
  final int sizeInFrames;

  /// format of [pBuffer].
  final AudioFormat format;

  /// lock the internal buffer and returns [RawFrameBuffer].
  /// You are responsible for calling [unlock] when you don't need it.
  /// You can use the [acquireBuffer] method to safely acquiring [RawFrameBuffer] instead.
  RawFrameBuffer lock();

  /// [unlock] the internal buffer.
  void unlock();
}
