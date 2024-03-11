import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('RingBuffer', () {
    test('output == input', () {
      final ringBuffer = RingBuffer(capacity: 10);

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

      malloc
        ..free(pInput)
        ..free(pOutput);
    });

    test('length should return correct length (no-overflow, no-underflow)', () {
      final ringBuffer = RingBuffer(capacity: 300);

      final pInput = malloc.allocate(100);
      final pOutput = malloc.allocate(100);

      // Write 100 bytes
      expect(ringBuffer.write(pInput.cast(), 0, 100), 100);
      expect(ringBuffer.length, 100);

      // Read 100 bytes (length won't change)
      expect(ringBuffer.read(pOutput.cast(), 0, 100, advance: false), 100);
      expect(ringBuffer.length, 100);

      // Read 100 bytes (length will change)
      expect(ringBuffer.read(pOutput.cast(), 0, 100, advance: true), 100);
      expect(ringBuffer.length, 0);

      malloc
        ..free(pInput)
        ..free(pOutput);
    });

    test('length should return correct length (overflow)', () {
      final ringBuffer = RingBuffer(capacity: 300);

      final pInput = malloc.allocate(100);
      final pOutput = malloc.allocate(500);

      // Write 400 bytes to the buffer but only 300 bytes should be written
      expect(ringBuffer.write(pInput.cast(), 0, 100), 100);
      expect(ringBuffer.write(pInput.cast(), 0, 100), 100);
      expect(ringBuffer.write(pInput.cast(), 0, 100), 100);
      expect(ringBuffer.write(pInput.cast(), 0, 100), 0);
      expect(ringBuffer.length, 300);

      // Read 300 bytes
      expect(ringBuffer.read(pOutput.cast(), 0, 300), 300);
      expect(ringBuffer.length, 0);

      malloc
        ..free(pInput)
        ..free(pOutput);
    });

    test('length should return correct length (underflow)', () {
      final ringBuffer = RingBuffer(capacity: 300);

      final pInput = malloc.allocate(100);
      final pOutput = malloc.allocate(500);

      // Write 100 bytes
      expect(ringBuffer.write(pInput.cast(), 0, 100), 100);
      expect(ringBuffer.length, 100);

      // Read 300 bytes from the buffer but only 100 bytes should be read
      expect(ringBuffer.read(pOutput.cast(), 0, 300), 100);
      expect(ringBuffer.length, 0);

      malloc
        ..free(pInput)
        ..free(pOutput);
    });

    test('copyTo should copy ring buffer as much as possible (no-overflow)', () {
      final ringBuffer1 = RingBuffer(capacity: 300);
      final ringBuffer2 = RingBuffer(capacity: 300);

      final pInput = malloc.allocate(100);
      ringBuffer1.write(pInput.cast(), 0, 100);

      // Copy 100 bytes from ringBuffer1 to ringBuffer2 (ringBuffer1 length won't change)
      expect(ringBuffer1.copyTo(ringBuffer2, advance: false), 100);
      expect(ringBuffer1.length, 100);
      expect(ringBuffer2.length, 100);

      ringBuffer2.clear();

      // Copy 100 bytes from ringBuffer1 to ringBuffer2 (ringBuffer1 length will change)
      expect(ringBuffer1.copyTo(ringBuffer2, advance: true), 100);
      expect(ringBuffer1.length, 0);
      expect(ringBuffer2.length, 100);

      malloc.free(pInput);
    });

    test('copyTo should copy ring buffer as much as possible (overflow)', () {
      final ringBuffer1 = RingBuffer(capacity: 300);
      final ringBuffer2 = RingBuffer(capacity: 50);

      final pInput = malloc.allocate(100);
      ringBuffer1.write(pInput.cast(), 0, 100);

      // Copy 100 bytes but only 50 bytes can be copied
      expect(ringBuffer1.copyTo(ringBuffer2, advance: false), 50);
      expect(ringBuffer1.length, 100);
      expect(ringBuffer2.length, 50);

      malloc.free(pInput);
    });

    test('clear should reset length to 0', () {
      final ringBuffer = RingBuffer(capacity: 300);

      final pInput = malloc.allocate(100);

      // Write 100 bytes
      ringBuffer.write(pInput.cast(), 0, 100);
      expect(ringBuffer.length, 100);

      // Clear the buffer
      ringBuffer.clear();
      expect(ringBuffer.length, 0);

      malloc.free(pInput);
    });
  });
}
