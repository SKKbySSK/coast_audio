import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';

/// [Memory] class handles pointer related operations.
/// You can customize the behavior by extending this class and provide it to memory related instances such as [AllocatedAudioFrames].
/// By default, [FfiMemory] will be used.
abstract class Memory {
  factory Memory() {
    return FfiMemory();
  }

  /// memory allocator that allocates and free memory.
  Allocator get allocator;

  /// Copies memory from [pSrc] to [pDst] with [size].
  Pointer<Void> copyMemory(Pointer<Void> pDst, Pointer<Void> pSrc, int size);

  /// Sets memory of [p] with [data] with [size].
  Pointer<Void> setMemory(Pointer<Void> p, int data, int size);

  /// Zeros memory of [p] with [size].
  Pointer<Void> zeroMemory(Pointer<Void> p, int size);
}

/// [FfiMemory] uses native functions to interact with memory operations.
/// For example, [setMemory] will use the `memset` function.
class FfiMemory implements Memory {
  factory FfiMemory() {
    return _instance;
  }

  FfiMemory._init();

  static final _instance = FfiMemory._init();

  final _lib = DynamicLibrary.process();

  late final _memcpyPtr = _lib.lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>, Pointer<Void>, Size)>>('memcpy');
  late final _memcpy = _memcpyPtr.asFunction<Pointer<Void> Function(Pointer<Void>, Pointer<Void>, int)>(isLeaf: true);

  late final _memsetPtr = _lib.lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>, Int, Size)>>('memset');
  late final _memset = _memsetPtr.asFunction<Pointer<Void> Function(Pointer<Void>, int, int)>(isLeaf: true);

  @override
  Allocator get allocator => malloc;

  @override
  Pointer<Void> copyMemory(Pointer<Void> pDst, Pointer<Void> pSrc, int size) {
    return _memcpy(pDst, pSrc, size);
  }

  @override
  Pointer<Void> setMemory(Pointer<Void> p, int data, int size) {
    return _memset(p, data, size);
  }

  @override
  Pointer<Void> zeroMemory(Pointer<Void> p, int size) => setMemory(p, 0, size);
}
