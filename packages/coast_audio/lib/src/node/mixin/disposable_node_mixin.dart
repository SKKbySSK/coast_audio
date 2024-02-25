import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

mixin SyncDisposableNodeMixin on AudioNode implements SyncDisposable {
  var _isDispose = false;

  @override
  bool get isDisposed => _isDispose;

  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _isDispose = true;
  }
}
