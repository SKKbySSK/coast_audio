import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

/// [AudioBuffer] is a [AudioFrames]'s internal audio buffer data.
/// [pBuffer] contains pointer to a raw pcm audio.
class AudioBuffer {
  /// Constructs the [AudioBuffer] from pointer.
  AudioBuffer({
    required this.root,
    required this.pBuffer,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  /// The root [AudioFrames] of this [AudioBuffer].
  final AudioFrames root;

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

  /// move the [pBuffer] forward by requested [frames] and returns a view of [AudioBuffer].
  AudioBuffer offset(int frames) {
    assert(frames <= sizeInFrames);
    return AudioBuffer(
      root: root,
      pBuffer: Pointer.fromAddress(pBuffer.address + (format.bytesPerFrame * frames)),
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      memory: memory,
    );
  }

  /// limit the [pBuffer] to requested [frames] and returns a view of [AudioBuffer].
  AudioBuffer limit(int frames) {
    assert(frames <= sizeInFrames);
    return AudioBuffer(
      root: root,
      pBuffer: pBuffer,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      memory: memory,
    );
  }
}
