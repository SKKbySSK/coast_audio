final _finalizer = Finalizer<void Function()>((d) => d());

/// A mixin that provides a method to attach to finalizer.
///
/// Implement this mixin to run a callback when the object is finalized.
mixin AudioResourceMixin {
  void attachToFinalizer(void Function() onFinalize) {
    _finalizer.attach(this, onFinalize, detach: this);
  }
}
