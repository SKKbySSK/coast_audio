import 'dart:ffi';

import 'package:meta/meta.dart';

final _finalizer = Finalizer<int>((id) {
  final holder = _resourceHolders.remove(id);
  holder?.dispose();
});

final _resourceHolders = <int, _AudioResourceHolder>{};

class _AudioResource {
  const _AudioResource(this.id, this.name);
  final int id;
  final String name;
}

class _AudioResourceHolder {
  _AudioResourceHolder(
    this.resource,
    this.finalizer,
  );
  final _AudioResource resource;
  final void Function() finalizer;

  void dispose() {
    finalizer();
    if (AudioResourceManager.isDisposeLogEnabled) {
      print('[coast_audio/AudioResource] Disposed `${resource.name}` (id: ${resource.id})');
    }
  }
}

/// A manager that provides a way to dispose audio resources.
///
/// You can use this class to dispose audio resources manually.
final class AudioResourceManager {
  const AudioResourceManager._();

  static var isDisposeLogEnabled = false;

  /// Disposes the audio resource with the given [resourceId].
  ///
  /// Returns `true` if the resource is successfully disposed.
  /// Otherwise, returns `false`.
  static bool dispose(int resourceId) {
    final holder = _resourceHolders.remove(resourceId);
    if (holder == null) {
      return false;
    }

    holder.dispose();
    _finalizer.detach(holder.resource);
    return true;
  }

  /// Disposes all audio resources.
  ///
  /// This method should be called when the isolate is shutting down.
  static void disposeAll() {
    final holders = _resourceHolders.entries.toList();
    for (final holder in holders) {
      holder.value.dispose();
      _finalizer.detach(holder.value.resource);
      _resourceHolders.remove(holder.key);
    }
  }
}

/// A mixin that provides a finalizer for audio resources.
///
/// Implement this mixin and call [setResourceFinalizer] to automatically dispose.
mixin AudioResourceMixin implements Finalizable {
  var _hasFinalizer = false;

  /// Whether this resource is already disposed.
  bool get isDisposed => _hasFinalizer && !_resourceHolders.containsKey(resourceId);

  /// The unique identifier of this resource.
  late final resourceId = identityHashCode(this);

  /// Throws an [AudioResourceDisposedException] if this resource is already disposed.
  void throwIfDisposed() {
    if (isDisposed) {
      throw AudioResourceDisposedException(resourceId, runtimeType.toString());
    }
  }

  /// Sets a finalizer for this resource.
  ///
  /// The [onFinalize] function will be called when this resource is garbage collected.
  /// Please note that the [onFinalize] function should not reference instance members directly.
  /// Otherwise, it will prevent the object from being garbage collected.
  @protected
  void setResourceFinalizer<T>(void Function() onFinalize) {
    final resource = _AudioResource(resourceId, runtimeType.toString());
    final holder = _AudioResourceHolder(resource, onFinalize);
    _resourceHolders[resourceId] = holder;
    _hasFinalizer = true;

    _finalizer.attach(this, resourceId, detach: resource);
  }

  /// Clears the finalizer for this resource.
  @protected
  void clearResourceFinalizer() {
    final holder = _resourceHolders.remove(resourceId);
    if (holder != null) {
      _finalizer.detach(holder.resource);
      _hasFinalizer = false;
    }
  }
}

/// An exception that is thrown when an audio resource is already disposed.
class AudioResourceDisposedException implements Exception {
  const AudioResourceDisposedException(this.id, this.name);

  final int id;
  final String name;

  @override
  String toString() => 'The audio resource $name(id: $id) is already disposed';
}
