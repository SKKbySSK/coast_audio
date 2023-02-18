import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';

abstract class FrameBuffer {
  FrameBuffer({
    required Pointer<Uint8> pBuffer,
    required Pointer<Uint8>? pBufferOrigin,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.memory,
  })  : _pBuffer = pBuffer,
        _pBufferOrigin = pBufferOrigin ?? pBuffer {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  late final Pointer<Uint8> _pBuffer;
  late final Pointer<Uint8> _pBufferOrigin;
  final int sizeInBytes;
  final int sizeInFrames;
  final AudioFormat format;
  final Memory memory;

  FrameBuffer offset(int frames) {
    return SubFrameBuffer(
      pBuffer: _pBuffer.elementAt(format.bytesPerFrame * frames),
      pBufferOrigin: _pBufferOrigin,
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      memory: memory,
    );
  }

  FrameBuffer limit(int frames) {
    return SubFrameBuffer(
      pBuffer: _pBuffer,
      pBufferOrigin: _pBufferOrigin,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      memory: memory,
    );
  }

  T acquireBuffer<T>(T Function(Pointer<Uint8> pBuffer) callback) {
    return callback(_pBuffer);
  }

  T acquireBufferOrigin<T>(T Function(Pointer<Uint8> pBufferOrigin) callback) {
    return callback(_pBufferOrigin);
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
  }) : super(pBufferOrigin: pBuffer);

  bool _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    acquireBuffer((_) {
      malloc.free(_pBufferOrigin);
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
    required super.pBufferOrigin,
    required super.sizeInBytes,
    required super.sizeInFrames,
    required super.format,
    required super.memory,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }
}
