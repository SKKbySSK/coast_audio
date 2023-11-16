import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('output == input', () {
    final pBuffer = malloc.allocate(10);
    final ringBuffer = RingBuffer(capacity: 10, pBuffer: pBuffer.cast());

    final pInput = malloc.allocate(100);
    final pOutput = malloc.allocate(100);

    final inputListView = pInput.cast<Uint8>().asTypedList(100);
    final outputListView = pOutput.cast<Uint8>().asTypedList(100);

    for (var i = 0; 100 > i; i++) {
      inputListView[i] = i;
    }

    for (var i = 0; 10 > i; i++) {
      final offset = i * 10;
      ringBuffer.write(pInput.cast(), offset, 3); // length: 3, read: 0
      ringBuffer.read(pOutput.cast(), offset, 5); // length: 0, read: 3
      ringBuffer.write(pInput.cast(), offset + 3, 6); // length: 6, read: 3
      ringBuffer.read(pOutput.cast(), offset + 3, 5); // length: 1, read: 8
      ringBuffer.write(pInput.cast(), offset + 9, 1); // length: 2, read: 8
      ringBuffer.read(pOutput.cast(), offset + 8, 2); // length: 0, read: 10
    }

    expect(outputListView, List.generate(100, (i) => i));
  });
}
