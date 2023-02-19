import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';

abstract class FrameBuffer {
  FrameBuffer({
    required Pointer<Uint8> pBuffer,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  }) : _pBuffer = pBuffer {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  late final Pointer<Uint8> _pBuffer;
  final int sizeInBytes;
  final int sizeInFrames;
  final AudioFormat format;
  final Memory memory;

  T acquireBuffer<T>(T Function(AcquiredFrameBuffer buffer) callback) {
    final result = callback(lock());
    unlock();
    return result;
  }

  AcquiredFrameBuffer lock() {
    return AcquiredFrameBuffer(
      pBuffer: _pBuffer,
      sizeInBytes: sizeInBytes,
      sizeInFrames: sizeInFrames,
      format: format,
      memory: memory,
    );
  }

  void unlock() {}
}

class AcquiredFrameBuffer {
  AcquiredFrameBuffer({
    required this.pBuffer,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  final Pointer<Uint8> pBuffer;
  final int sizeInBytes;
  final int sizeInFrames;
  final AudioFormat format;
  final Memory memory;

  AcquiredFrameBuffer offset(int frames) {
    return AcquiredFrameBuffer(
      pBuffer: pBuffer.elementAt(format.bytesPerFrame * frames),
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      memory: memory,
    );
  }

  AcquiredFrameBuffer limit(int frames) {
    return AcquiredFrameBuffer(
      pBuffer: pBuffer,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      memory: memory,
    );
  }
}

class AllocatedFrameBuffer extends FrameBuffer implements SyncDisposable {
  factory AllocatedFrameBuffer({
    required int frames,
    required AudioFormat format,
    bool fillZero = false,
    Memory? memory,
  }) {
    final mem = memory ?? Memory();
    final sizeInBytes = format.bytesPerFrame * frames;
    final pBuffer = mem.allocator.allocate<Uint8>(sizeInBytes);
    return AllocatedFrameBuffer._init(
      pBuffer: pBuffer,
      sizeInBytes: sizeInBytes,
      sizeInFrames: frames,
      format: format,
      memory: mem,
    );
  }

  AllocatedFrameBuffer._init({
    required super.pBuffer,
    required super.sizeInBytes,
    required super.sizeInFrames,
    required super.format,
    required super.memory,
  });

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
      malloc.free(buffer.pBuffer);
    });
  }

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }
}

class SubFrameBuffer extends FrameBuffer {
  SubFrameBuffer({
    required super.pBuffer,
    required super.sizeInBytes,
    required super.sizeInFrames,
    required super.format,
    required super.memory,
  });
}
