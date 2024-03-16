import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

import '../internal/generated/bindings.dart';

/// An interop helper for the coast_audio and miniaudio library.
final class CoastAudioInterop with AudioResourceMixin {
  CoastAudioInterop() {
    // Set the resource finalizer to free all the managed pointers if the holder instance fails to initialize.
    final captured = (memory, _managedPtrs);
    setResourceFinalizer(() {
      final (memory, managedPtrs) = captured;
      for (final ptr in managedPtrs) {
        memory.allocator.free(ptr);
      }
    });
  }

  final _memory = Memory();
  final _managedPtrs = <Pointer<Void>>[];
  var _isInitialized = false;
  var _isDisposed = false;

  /// A callback that is called when the interop is disposed.
  ///
  /// After the callback is called, all of the managed pointers are freed.
  void Function()? onDispose;

  /// A callback that is called when the holder is initialized successfully.
  void onInitialized() {
    clearResourceFinalizer();
    _isInitialized = true;
  }

  /// Native library bindings.
  NativeBindings get bindings {
    throwIfDisposed();
    return CoastAudioNative.bindings;
  }

  /// Memory allocator.
  Memory get memory {
    throwIfDisposed();
    return _memory;
  }

  @override
  bool get isDisposed {
    if (_isInitialized) {
      return _isDisposed;
    }

    return super.isDisposed;
  }

  /// Allocates a managed pointer.
  ///
  /// The allocated pointer will be freed when this interop is disposed.
  Pointer<T> allocateManaged<T extends NativeType>(int byteCount) {
    throwIfDisposed();
    final ptr = _memory.allocator.allocate<T>(byteCount);
    _managedPtrs.add(ptr.cast());
    return ptr;
  }

  /// Allocates a temporary pointer and disposes it after the action is executed.
  TResult allocateTemporary<T extends NativeType, TResult>(
    int byteCount,
    TResult Function(Pointer<T>) action,
  ) {
    throwIfDisposed();
    final ptr = _memory.allocator.allocate<Void>(byteCount);
    try {
      return action(ptr.cast());
    } finally {
      _memory.allocator.free(ptr);
    }
  }

  /// Disposes the interop and frees all the managed pointers.
  void dispose() {
    if (_isDisposed) {
      return;
    }
    onDispose?.call();
    for (final ptr in _managedPtrs) {
      _memory.allocator.free(ptr);
    }
    _managedPtrs.clear();
    _isDisposed = true;
  }
}
