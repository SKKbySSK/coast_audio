import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

/// [AllocatedAudioFrames] allocates requested frames of buffer.
/// If you want to fill out the buffer, set [fillZero] to true.
class AllocatedAudioFrames extends AudioFrames implements SyncDisposable {
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
        _mutex = mutex;

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

  bool _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }

  @override
  AudioBuffer lock() {
    _mutex.lock();
    return AudioBuffer(
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

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    acquireBuffer((buffer) {
      memory.allocator.free(buffer.pBuffer);
    });
    _mutex.dispose();
  }
}
