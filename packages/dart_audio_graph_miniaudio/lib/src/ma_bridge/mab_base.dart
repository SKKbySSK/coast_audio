import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';

/// An abstract class for implementing mabridge's functionality
abstract class MabBase extends SyncDisposable {
  MabBase({required Memory? memory}) : memory = memory ?? Memory();

  final Memory memory;

  MaBridge get library => MabLibrary.library;

  final _disposableBag = SyncDisposableBag();

  /// Allocates the memory and store it in the [SyncDisposableBag]
  /// It will be freed when the [dispose] is called.
  Pointer<T> allocate<T extends NativeType>(int size) {
    final ptr = memory.allocator.allocate<T>(size);
    addPtrToDisposableBag(ptr);
    return ptr;
  }

  void addPtrToDisposableBag<T extends NativeType>(Pointer<T> ptr) {
    final disposable = SyncCallbackDisposable(() => memory.allocator.free(ptr));
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

  /// An abstract method to uninit all internal resources.
  /// Do not call this method directly because this will be called inside the [dispose] method.
  void uninit();
}
