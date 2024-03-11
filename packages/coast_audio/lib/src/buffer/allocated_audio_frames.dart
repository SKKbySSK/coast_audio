import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

/// [AllocatedAudioFrames] allocates requested frames of buffer.
///
/// If you want to fill the buffer with zero, set [fillZero] to `true`.
class AllocatedAudioFrames extends AudioFrames with AudioResourceMixin {
  factory AllocatedAudioFrames({
    required int length,
    required AudioFormat format,
    bool fillZero = false,
    Memory? memory,
    Mutex? mutex,
  }) {
    final mem = memory ?? Memory();
    final sizeInBytes = format.bytesPerFrame * length;
    final pBuffer = mem.allocator.allocate<Uint8>(sizeInBytes);

    return AllocatedAudioFrames._init(
      pBuffer: pBuffer,
      mutex: mutex ?? Mutex(),
      sizeInBytes: sizeInBytes,
      sizeInFrames: length,
      format: format,
      memory: mem,
    );
  }

  AllocatedAudioFrames._init({
    required Pointer<Uint8> pBuffer,
    required Mutex mutex,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  })  : _pBuffer = pBuffer,
        _mutex = mutex {
    attachToFinalizer(() => memory.allocator.free(pBuffer));
  }

  final Mutex _mutex;

  @override
  final AudioFormat format;

  @override
  final int sizeInBytes;

  @override
  final int sizeInFrames;

  /// internal buffer pointer.
  final Pointer<Uint8> _pBuffer;

  /// internal buffer memory allocator.
  final Memory memory;

  @override
  AudioBuffer lock() {
    _mutex.lock();
    return AudioBuffer(
      root: this,
      pBuffer: _pBuffer,
      sizeInBytes: sizeInBytes,
      sizeInFrames: sizeInFrames,
      format: format,
      memory: memory,
    );
  }

  @override
  void unlock() {
    _mutex.unlock();
  }
}
