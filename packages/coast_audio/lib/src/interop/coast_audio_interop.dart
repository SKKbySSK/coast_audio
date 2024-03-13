import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

import 'generated/bindings.dart';

/// A base class for interop classes that use the native coast_audio library.
abstract class CoastAudioInterop {
  final _memory = Memory();
}

extension CoastAudioInteropExtension on CoastAudioInterop {
  NativeBindings get bindings => CoastAudioNative.bindings;

  Memory get memory => _memory;

  /// Allocates a temporary pointer and disposes it after the action is executed.
  @protected
  void allocateTemporary<T extends NativeType>(
    int byteCount,
    void Function(Pointer<T>) action,
  ) {
    final ptr = _memory.allocator.allocate<Void>(byteCount);
    try {
      action(ptr.cast());
    } finally {
      _memory.allocator.free(ptr);
    }
  }
}
