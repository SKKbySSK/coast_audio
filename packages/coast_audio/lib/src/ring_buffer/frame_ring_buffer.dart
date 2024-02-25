import 'package:coast_audio/coast_audio.dart';

class FrameRingBuffer extends SyncDisposable {
  static final _finalizer = Finalizer<SyncDisposable>((d) => d.dispose());

  FrameRingBuffer({
    required this.capacity,
    required this.format,
    Memory? memory,
  }) : _ringBuffer = RingBuffer(
          capacity: format.bytesPerFrame * capacity,
          memory: memory,
        ) {
    _finalizer.attach(this, _ringBuffer, detach: this);
  }

  late final RingBuffer _ringBuffer;

  final AudioFormat format;

  final int capacity;

  int get length => _ringBuffer.length ~/ format.bytesPerFrame;

  @override
  bool get isDisposed => _ringBuffer.isDisposed;

  int write(AudioBuffer buffer) {
    throwIfNotAvailable();
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.write(buffer.pBuffer.cast(), 0, buffer.sizeInBytes) ~/ format.bytesPerFrame;
  }

  int read(AudioBuffer buffer, {bool advance = true}) {
    throwIfNotAvailable();
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.read(buffer.pBuffer.cast(), 0, buffer.sizeInBytes, advance: advance) ~/ format.bytesPerFrame;
  }

  int copyTo(FrameRingBuffer buffer, {required bool advance}) {
    throwIfNotAvailable();
    assert(buffer.format.isSameFormat(format));
    return _ringBuffer.copyTo(buffer._ringBuffer, advance: advance) ~/ format.bytesPerFrame;
  }

  void clear() {
    throwIfNotAvailable();
    _ringBuffer.clear();
  }

  @override
  void dispose() {
    _ringBuffer.dispose();
    _finalizer.detach(this);
  }
}
