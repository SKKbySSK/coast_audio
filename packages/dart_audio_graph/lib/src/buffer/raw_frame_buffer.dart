import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';

/// [RawFrameBuffer] is a [FrameBuffer]'s internal audio buffer data.
/// [pBuffer] contains pointer to a raw pcm audio.
class RawFrameBuffer {
  /// Constructs the [RawFrameBuffer] from pointer.
  RawFrameBuffer({
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

  /// move the [pBuffer] forward by requested [frames] and returns a view of [RawFrameBuffer].
  RawFrameBuffer offset(int frames) {
    return RawFrameBuffer(
      pBuffer: pBuffer.elementAt(format.bytesPerFrame * frames),
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      memory: memory,
    );
  }

  /// limit the [pBuffer] to requested [frames] and returns a view of [RawFrameBuffer].
  RawFrameBuffer limit(int frames) {
    return RawFrameBuffer(
      pBuffer: pBuffer,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      memory: memory,
    );
  }
}
