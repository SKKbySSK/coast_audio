import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

/// A mixin that provides a [dispose] method to dispose the node's resources.
mixin SyncDisposableNodeMixin on AudioNode implements SyncDisposable {
  var _isDispose = false;

  /// Returns true if the node is disposed.
  @override
  bool get isDisposed => _isDispose;

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }

  /// Dispose the node's resources.
  ///
  /// This method should be called when the node is no longer needed.

  @override
  @mustCallSuper
  void dispose() {
    _isDispose = true;
  }
}
