import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

abstract class NativeInterop {
  static final _finalizer = Finalizer<SyncDisposableBag>((disposables) => disposables.dispose());

  NativeInterop({
    Memory? memory,
  }) : memory = memory ?? Memory() {
    _finalizer.attach(this, _disposables, detach: this);
  }

  final _disposables = SyncDisposableBag();
  final Memory memory;
}

extension NativeInteropExtension on NativeInterop {
  Pointer<T> allocateManaged<T extends NativeType>(int byteCount) {
    final ptr = memory.allocator.allocate<Void>(byteCount);
    _disposables.add(SyncCallbackDisposable(() => memory.allocator.free(ptr)));
    return ptr.cast();
  }

  void allocateTemporary<T extends NativeType>(
    int byteCount,
    void Function(Pointer<T>) action,
  ) {
    final ptr = memory.allocator.allocate<Void>(byteCount);
    try {
      action(ptr.cast());
    } finally {
      memory.allocator.free(ptr);
    }
  }

  void addDisposable(SyncDisposable disposable) {
    _disposables.add(disposable);
  }
}
