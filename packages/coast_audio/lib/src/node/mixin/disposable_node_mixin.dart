import 'package:coast_audio/coast_audio.dart';

mixin SyncDisposableNodeMixin on AudioNode implements SyncDisposable {
  @override
  void throwIfNotAvailable([String? target]) {
    if (isDisposed) {
      throw DisposedException(this, target);
    }
  }
}
