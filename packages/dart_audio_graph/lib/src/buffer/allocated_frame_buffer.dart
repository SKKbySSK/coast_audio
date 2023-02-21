import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';

/// [AllocatedFrameBuffer] allocates requested frames of buffer.
/// If you want to fill out the buffer, set [fillZero] to true.
class AllocatedFrameBuffer extends FrameBuffer implements SyncDisposable {
  factory AllocatedFrameBuffer({
    required int frames,
    required AudioFormat format,
    bool fillZero = false,
    Memory? memory,
    Mutex? mutex,
  }) {
    final mem = memory ?? Memory();
    final sizeInBytes = format.bytesPerFrame * frames;
    final pBuffer = mem.allocator.allocate<Uint8>(sizeInBytes);
    return AllocatedFrameBuffer._init(
      pBuffer: pBuffer,
      mutex: mutex ?? Mutex(),
      sizeInBytes: sizeInBytes,
      sizeInFrames: frames,
      format: format,
      memory: mem,
    );
  }

  AllocatedFrameBuffer._init({
    required Pointer<Uint8> pBuffer,
    required Mutex mutex,
    required super.sizeInBytes,
    required super.sizeInFrames,
    required super.format,
    required super.memory,
  })  : _pBuffer = pBuffer,
        _mutex = mutex;

  final Mutex _mutex;

  /// internal buffer pointer.
  final Pointer<Uint8> _pBuffer;

  bool _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

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

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }

  @override
  RawFrameBuffer lock() {
    _mutex.lock();
    return RawFrameBuffer(
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
