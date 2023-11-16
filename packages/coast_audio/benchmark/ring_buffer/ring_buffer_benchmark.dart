import 'dart:ffi';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';

class RingBufferBenchmark extends BenchmarkBase {
  RingBufferBenchmark({
    required this.capacity,
    required this.writeSize,
    required this.readSize,
  }) : super('RingBuffer(cap: $capacity)');
  final int capacity;
  final int writeSize;
  final int readSize;
  late Pointer<Void> _pBuffer;
  late RingBuffer _ringBuffer;

  late Pointer<Void> _pInputBuffer;
  late Pointer<Void> _pOutputBuffer;

  @override
  void run() {
    _ringBuffer.write(_pInputBuffer, 0, writeSize);
    _ringBuffer.read(_pOutputBuffer, 0, readSize);
  }

  @override
  void setup() {
    _pBuffer = malloc.allocate(capacity);
    _ringBuffer = RingBuffer(capacity: capacity, pBuffer: _pBuffer);

    _pInputBuffer = malloc.allocate(writeSize);
    _pOutputBuffer = malloc.allocate(readSize);
  }

  @override
  void teardown() {
    malloc.free(_pBuffer);
    malloc.free(_pInputBuffer);
    malloc.free(_pOutputBuffer);
  }
}

void main() {
  RingBufferBenchmark(
    capacity: 1024 * 10,
    writeSize: 512 * 10,
    readSize: 128 * 10,
  ).report();
}
