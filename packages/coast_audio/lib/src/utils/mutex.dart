import 'package:coast_audio/coast_audio.dart';

class Mutex extends SyncDisposable {
  Mutex();

  var _isLocked = false;
  var _isDisposed = false;

  bool get isLocked => _isLocked;

  @override
  bool get isDisposed => _isDisposed;

  void lock() {
    throwIfNotAvailable();
    if (_isLocked) {
      throw const MutexAlreadyLockedException();
    }
    _isLocked = true;
  }

  void unlock() {
    throwIfNotAvailable();
    _isLocked = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
  }
}

class MutexAlreadyLockedException implements Exception {
  const MutexAlreadyLockedException();

  @override
  String toString() {
    return 'mutex is already locked';
  }
}
