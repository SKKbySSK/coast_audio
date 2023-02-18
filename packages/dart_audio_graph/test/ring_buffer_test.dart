import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('read', () {
    final capacity = 1024;
    final pBuffer = malloc.allocate<Uint8>(capacity);
    late RingBuffer ringBuffer;

    setUp(() {
      ringBuffer = RingBuffer(
        capacity: capacity,
        pBuffer: pBuffer,
      );
    });

    test('read all bytes', () {
      final pOneFilledBuffer = malloc.allocate<Uint8>(capacity);
      for (var i = 0; capacity > i; i++) {
        pOneFilledBuffer.elementAt(i).value = 1;
      }

      final writtenBytes = ringBuffer.write(pOneFilledBuffer, 0, capacity);
      expect(writtenBytes, capacity);

      final readBytes = ringBuffer.read(pOneFilledBuffer, 0, capacity);
      expect(readBytes, capacity);

      for (var i = 0; capacity > i; i++) {
        expect(1, ringBuffer.pBuffer.elementAt(i).value);
      }

      malloc.free(pOneFilledBuffer);
    });

    test('read all bytes three times', () {
      for (var iteration = 0; 3 > iteration; iteration++) {
        final pInputBuffer = malloc.allocate<Uint8>(capacity);
        for (var i = 0; capacity > i; i++) {
          pInputBuffer.elementAt(i).value = iteration;
        }

        final writtenBytes = ringBuffer.write(pInputBuffer, 0, capacity);
        expect(writtenBytes, capacity);

        final readBytes = ringBuffer.read(pInputBuffer, 0, capacity);
        expect(readBytes, capacity);

        for (var i = 0; capacity > i; i++) {
          expect(ringBuffer.pBuffer.elementAt(i).value, iteration);
        }

        malloc.free(pInputBuffer);
      }
    });

    test('read 100 bytes 11 times', () {
      var totalWrittenBytes = 0;
      for (var iteration = 0; 11 > iteration; iteration++) {
        final pInputBuffer = malloc.allocate<Uint8>(100);
        for (var i = 0; 100 > i; i++) {
          pInputBuffer.elementAt(i).value = iteration;
        }

        final writtenBytes = ringBuffer.write(pInputBuffer, 0, 100);
        if (iteration == 10) {
          expect(24, writtenBytes);
        } else {
          expect(100, writtenBytes);
        }
        totalWrittenBytes += writtenBytes;

        malloc.free(pInputBuffer);
      }

      expect(totalWrittenBytes, capacity);

      var totalReadBytes = 0;
      final pOutput = malloc.allocate<Uint8>(100);
      for (var iteration = 0; 11 > iteration; iteration++) {
        final readBytes = ringBuffer.read(pOutput, 0, 100);
        for (var i = 0; (iteration == 10 ? 24 : 100) > i; i++) {
          expect(pOutput.elementAt(i).value, iteration);
        }
        totalReadBytes += readBytes;
      }

      expect(totalReadBytes, capacity);
    });
  });

  group('write and read', () {
    final capacity = 1024;
    final pBuffer = malloc.allocate<Uint8>(capacity);
    final ringBuffer = RingBuffer(
      capacity: capacity,
      pBuffer: pBuffer,
    );

    test('write and read 100 bytes 11 times', () {
      final size = 100;
      for (var iteration = 0; 11 > iteration; iteration++) {
        final pInputBuffer = malloc.allocate<Uint8>(size);
        for (var i = 0; size > i; i++) {
          pInputBuffer.elementAt(i).value = iteration;
        }

        final writtenBytes = ringBuffer.write(pInputBuffer, 0, 100);
        expect(100, writtenBytes);

        final pOutputBuffer = malloc.allocate<Uint8>(size);
        final readBytes = ringBuffer.read(pOutputBuffer, 0, size);
        expect(100, readBytes);

        malloc.free(pInputBuffer);
        malloc.free(pOutputBuffer);
      }
    });
  });
}
