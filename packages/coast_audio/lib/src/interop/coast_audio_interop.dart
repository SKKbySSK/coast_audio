import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

import 'generated/bindings.dart';

/// A base class for interop classes that use the native coast_audio library.
abstract class CoastAudioInterop {
  static final _finalizer = Finalizer<SyncDisposableBag>((disposables) => disposables.dispose());

  CoastAudioInterop() {
    _finalizer.attach(this, _disposables, detach: this);
  }

  final _disposables = SyncDisposableBag();
  final _memory = Memory();
}

extension CoastAudioInteropExtension on CoastAudioInterop {
  NativeBindings get bindings => CoastAudioNative.bindings;

  Memory get memory => _memory;

  /// Allocates a managed pointer and registers it for disposal.
  ///
  /// Do not call this method outside of the `CoastAudioInterop` class.
  @protected
  Pointer<T> allocateManaged<T extends NativeType>(int byteCount) {
    final ptr = _memory.allocator.allocate<Void>(byteCount);
    _disposables.add(SyncCallbackDisposable(() => _memory.allocator.free(ptr)));
    return ptr.cast();
  }

  /// Allocates a temporary pointer and disposes it after the action is executed.
  ///
  /// Do not call this method outside of the `CoastAudioInterop` class.
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

  /// Registers a disposable for disposal.
  ///
  /// Do not call this method outside of the `CoastAudioInterop` class.
  @protected
  void addDisposable(SyncDisposable disposable) {
    _disposables.add(disposable);
  }
}
