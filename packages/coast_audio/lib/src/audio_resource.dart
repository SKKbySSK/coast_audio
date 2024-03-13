import 'package:meta/meta.dart';

final _finalizer = Finalizer<int>((id) {
  final holder = _resourceHolders.remove(id);
  holder?.dispose();
});

final _resourceHolders = <int, _AudioResourceHolder>{};

final class AudioResourceManager {
  const AudioResourceManager._();

  static var isDisposeLogEnabled = false;

  static bool dispose(int resourceId) {
    final holder = _resourceHolders.remove(resourceId);
    if (holder == null) {
      return false;
    }

    holder.dispose();
    _finalizer.detach(holder.resource);
    return true;
  }

  static void disposeAll() {
    final holders = _resourceHolders.entries.toList();
    for (final holder in holders) {
      holder.value.dispose();
      _finalizer.detach(holder.value.resource);
      _resourceHolders.remove(holder.key);
    }
  }
}

/// A mixin that provides a method to attach to finalizer.
///
/// Implement this mixin to run a callback when the object is finalized.
mixin AudioResourceMixin {
  var _hasFinalizer = false;
  bool get isDisposed => _hasFinalizer && !_resourceHolders.containsKey(resourceId);

  late final resourceId = identityHashCode(this);

  void throwIfDisposed() {
    if (isDisposed) {
      throw AudioResourceDisposedException(runtimeType.toString());
    }
  }

  @protected
  void setResourceFinalizer<T>(void Function() onFinalize) {
    final resource = _AudioResource(resourceId, runtimeType.toString());
    final holder = _AudioResourceHolder(resource, onFinalize);
    _resourceHolders[resourceId] = holder;
    _hasFinalizer = true;

    _finalizer.attach(this, resourceId, detach: resource);
  }
}

class AudioResourceDisposedException implements Exception {
  const AudioResourceDisposedException(this.resource);
  final String resource;

  @override
  String toString() => 'The audio resource $resource is already disposed';
}

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
