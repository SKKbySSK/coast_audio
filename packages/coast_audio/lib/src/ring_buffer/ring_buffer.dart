import 'dart:ffi';
import 'dart:math';

class RingBuffer {
  RingBuffer({
    required this.capacity,
    required this.pBuffer,
  });

  final int capacity;
  final Pointer<Uint8> pBuffer;

  int _writeCursor = -1;
  int _readCursor = 0;
  int _length = 0;

  int get length => _length;

  int write(Pointer<Uint8> pInput, int offset, int size) {
    final writeCount = min(capacity - _length, size);
    for (var i = 0; writeCount > i; i++) {
      _writeCursor = (_writeCursor + 1) % capacity;
      pBuffer.elementAt(_writeCursor).value = pInput[offset + i];
    }

    _length += writeCount;
    return writeCount;
  }

  int read(Pointer<Uint8> pOutput, int offset, int size) {
    final readCount = peek(pOutput, offset, size);
    _readCursor = (_readCursor + readCount) % capacity;
    _length -= readCount;
    return readCount;
  }

  int peek(Pointer<Uint8> pOutput, int offset, int size) {
    final readCount = min(_length, size);
    var readCursor = _readCursor;
    for (var i = 0; readCount > i; i++) {
      pOutput.elementAt(offset + i).value = pBuffer.elementAt(readCursor).value;
      readCursor = (readCursor + 1) % capacity;
    }

    return readCount;
  }

  void clear() {
    _readCursor = 0;
    _writeCursor = -1;
    _length = 0;
  }
}
