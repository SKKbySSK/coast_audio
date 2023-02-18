import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';

class FrameBuffer extends SyncDisposable {
  FrameBuffer({
    required this.pBuffer,
    required this.pBufferOrigin,
    required this.sizeInBytes,
    required this.sizeInFrames,
    required this.format,
    required this.isManaged,
    required this.memory,
  }) {
    assert(sizeInBytes == (sizeInFrames * format.bytesPerFrame));
  }

  FrameBuffer.allocate({
    required int frames,
    required this.format,
    bool fillZero = false,
    Memory? memory,
  })  : sizeInBytes = frames * format.bytesPerFrame,
        sizeInFrames = frames,
        isManaged = true,
        memory = memory ?? Memory() {
    pBuffer = this.memory.allocator.allocate(frames * format.bytesPerFrame);
    pBufferOrigin = pBuffer;
    if (fillZero) {
      fill(0);
    }
  }

  late final Pointer<Uint8> pBuffer;
  late final Pointer<Uint8> pBufferOrigin;
  final int sizeInBytes;
  final int sizeInFrames;
  final AudioFormat format;
  final bool isManaged;
  final Memory memory;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  FrameBuffer offset(int frames) {
    return FrameBuffer(
      pBuffer: pBuffer.elementAt(format.bytesPerFrame * frames),
      pBufferOrigin: pBufferOrigin,
      sizeInBytes: sizeInBytes - (frames * format.bytesPerFrame),
      sizeInFrames: sizeInFrames - frames,
      format: format,
      isManaged: false,
      memory: memory,
    );
  }

  FrameBuffer limit(int frames) {
    return FrameBuffer(
      pBuffer: pBuffer,
      pBufferOrigin: pBufferOrigin,
      sizeInBytes: frames * format.bytesPerFrame,
      sizeInFrames: frames,
      format: format,
      isManaged: false,
      memory: memory,
    );
  }

  void fill(int data) {
    memory.setMemory(pBuffer.cast(), data, sizeInBytes);
  }

  void copy(FrameBuffer other, int sizeInFrames) {
    memory.copyMemory(other.pBuffer.cast(), pBuffer.cast(), sizeInFrames * format.bytesPerFrame);
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    if (isManaged) {
      malloc.free(pBufferOrigin);
    }
  }
}
