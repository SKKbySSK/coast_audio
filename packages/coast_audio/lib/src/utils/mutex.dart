import 'package:coast_audio/coast_audio.dart';

/// Mutex provides a simple mutual exclusion lock.
class Mutex extends SyncDisposable {
  Mutex();

  var _isLocked = false;
  var _isDisposed = false;

  /// Returns true if the mutex is locked.
  bool get isLocked => _isLocked;

  @override
  bool get isDisposed => _isDisposed;

  /// Locks the mutex.
  ///
  /// If the mutex is already locked, this method throws [MutexAlreadyLockedException].
  void lock() {
    throwIfNotAvailable();
    if (_isLocked) {
      throw const MutexAlreadyLockedException();
    }
    _isLocked = true;
  }

  /// Unlocks the mutex.
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
