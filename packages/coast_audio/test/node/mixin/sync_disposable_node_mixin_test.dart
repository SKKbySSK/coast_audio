import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class MockSyncDisposableNode extends AudioNode with SyncDisposableNodeMixin {
  @override
  List<AudioInputBus> get inputs => const [];

  @override
  List<AudioOutputBus> get outputs => const [];

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    throw UnimplementedError();
  }
}

void main() {
  group('SyncDisposableNodeMixin', () {
    final node = MockSyncDisposableNode();

    test('dispose should change isDisposed flag to true', () {
      expect(node.isDisposed, isFalse);
      node.dispose();
      expect(node.isDisposed, isTrue);
    });

    test('throwIfNotAvailable throws DisposedException', () {
      node.dispose();
      expect(() => node.throwIfNotAvailable(), throwsA(isA<DisposedException>()));
    });
  });
}
