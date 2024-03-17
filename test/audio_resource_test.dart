import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class MockAudioResource with AudioResourceMixin {
  MockAudioResource.noFinalizer();
  MockAudioResource.setFinalizer() {
    setResourceFinalizer(() {
      isFinalizerCalled = true;
    });
  }

  var isFinalizerCalled = false;
}

void main() {
  group('AudioResourceManager', () {
    test('dispose should return true when the resource has finalizer', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      expect(AudioResourceManager.dispose(id), isTrue);
    });

    test('dispose should return false when the resource has no finalizer', () {
      final resource = MockAudioResource.noFinalizer();
      final id = resource.resourceId;
      expect(AudioResourceManager.dispose(id), isFalse);
    });

    test('disposeAll should dispose all of resources', () {
      final resource1 = MockAudioResource.setFinalizer();
      final resource2 = MockAudioResource.noFinalizer();
      AudioResourceManager.disposeAll();

      expect(resource1.isDisposed, isTrue);
      expect(resource2.isDisposed, isFalse);
    });
  });

  group('AudioResourceMixin', () {
    test('isDisposed returns true when the resource is disposed', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(resource.isDisposed, isTrue);
    });

    test('isDisposed returns false when the resource is not disposed', () {
      final resourceWithFinalizer = MockAudioResource.setFinalizer();
      expect(resourceWithFinalizer.isDisposed, isFalse);

      final resourceWithNoFinalizer = MockAudioResource.noFinalizer();
      expect(resourceWithNoFinalizer.isDisposed, isFalse);
    });

    test('dispose should call the finalizer', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(resource.isFinalizerCalled, isTrue);
    });

    test('dispose should not call the finalizer when cleared', () {
      final resource = MockAudioResource.setFinalizer();
      // ignore: invalid_use_of_protected_member
      resource.clearResourceFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(resource.isFinalizerCalled, isFalse);
    });

    test('throwIfDisposed should throw an AudioResourceDisposedException when the resource is disposed', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(() => resource.throwIfDisposed(), throwsA(isA<AudioResourceDisposedException>()));
    });

    test('throwIfDisposed should not throw an AudioResourceDisposedException when the resource is not disposed', () {
      final resourceWithFinalizer = MockAudioResource.setFinalizer();
      expect(() => resourceWithFinalizer.throwIfDisposed(), returnsNormally);

      final resourceWithNoFinalizer = MockAudioResource.noFinalizer();
      expect(() => resourceWithNoFinalizer.throwIfDisposed(), returnsNormally);
    });
  });
}
