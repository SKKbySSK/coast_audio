import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

import 'generated/bindings.dart';

/// A base class for interop classes that use the native coast_audio library.
abstract class CoastAudioInterop with AudioResourceMixin {
  CoastAudioInterop() {
    attachToFinalizer(() {
      for (final finalizer in _finalizers) {
        finalizer();
      }
    });
  }

  final _finalizers = <void Function()>[];
  final _memory = Memory();
}

extension CoastAudioInteropExtension on CoastAudioInterop {
  NativeBindings get bindings => CoastAudioNative.bindings;

  Memory get memory => _memory;

  /// Allocates a managed pointer and registers it for finalization.
  @protected
  Pointer<T> allocateManaged<T extends NativeType>(int byteCount) {
    final ptr = _memory.allocator.allocate<Void>(byteCount);
    _finalizers.add(() => _memory.allocator.free(ptr));
    return ptr.cast();
  }

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

  /// Registers a callback for finalization.
  @protected
  void addFinalizer(void Function() onFinalize) {
    _finalizers.add(onFinalize);
  }
}
