/// Mutex provides a simple mutual exclusion lock.
class Mutex {
  Mutex();

  var _isLocked = false;

  /// Returns true if the mutex is locked.
  bool get isLocked => _isLocked;

  /// Locks the mutex.
  ///
  /// If the mutex is already locked, this method throws [MutexAlreadyLockedException].
  void lock() {
    if (_isLocked) {
      throw const MutexAlreadyLockedException();
    }
    _isLocked = true;
  }

  /// Unlocks the mutex.
  void unlock() {
    _isLocked = false;
  }
}

class MutexAlreadyLockedException implements Exception {
  const MutexAlreadyLockedException();

  @override
  String toString() {
    return 'mutex is already locked';
  }
}
