import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

/// [AudioFrameBuffer] is a [AudioFrame]'s internal audio buffer data.
/// [pBuffer] contains pointer to a raw pcm audio.
class AudioFrameBuffer {
  /// Constructs the [AudioFrameBuffer] from pointer.
  AudioFrameBuffer({
    required this.pBuffer,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  /// Pointer to the raw audio data.
  final Pointer<Uint8> pBuffer;

  /// size of [pBuffer] in bytes.
  final int sizeInBytes;

  /// size of [pBuffer] in frames.
  final int sizeInFrames;

  /// format of [pBuffer].
  final AudioFormat format;

  /// [pBuffer]'s memory allocator.
  final Memory memory;

  /// move the [pBuffer] forward by requested [frames] and returns a view of [AudioFrameBuffer].
  AudioFrameBuffer offset(int frames) {
    return AudioFrameBuffer(
      pBuffer: pBuffer.elementAt(format.bytesPerFrame * frames),
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      memory: memory,
    );
  }

  /// limit the [pBuffer] to requested [frames] and returns a view of [AudioFrameBuffer].
  AudioFrameBuffer limit(int frames) {
    return AudioFrameBuffer(
      pBuffer: pBuffer,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      memory: memory,
    );
  }
}
