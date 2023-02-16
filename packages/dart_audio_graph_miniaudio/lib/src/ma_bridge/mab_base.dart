import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:ffi/ffi.dart';

final _maBridgeLib = DynamicLibrary.process();

abstract class MabBase extends SyncDisposable {
  late final library = MaBridge(_maBridgeLib);

  final _disposableBag = SyncDisposableBag();

  Pointer<T> allocate<T extends NativeType>(int size) {
    final ptr = malloc.allocate<T>(size);
    addPtrToDisposableBag(ptr);
    return ptr;
  }

  void addPtrToDisposableBag<T extends NativeType>(Pointer<T> ptr) {
    final disposable = SyncCallbackDisposable(() => malloc.free(ptr));
    _disposableBag.add(disposable);
  }

  @override
  bool get isDisposed => _disposableBag.isDisposed;

  @override
  void dispose() {
    if (_disposableBag.isDisposed) {
      return;
    }
    try {
      uninit();
    } finally {
      _disposableBag.dispose();
    }
  }

  /// Call uninit func on all internal resources but not free memory.
  /// Do not call this method directly.
  /// Use `dispose` instead.
  void uninit();
}
