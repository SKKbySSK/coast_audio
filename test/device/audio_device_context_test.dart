import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../interop/internal/coast_audio_native_library.dart';

void main() {
  CoastAudioNative.initialize(library: resolveNativeLib());

  group('AudioDeviceContext Test', () {
    test('should not throw when the backend is activated', () {
      final context = AudioDeviceContext(backends: AudioDeviceBackend.values);
      expect(() => context.activeBackend, returnsNormally);
    });

    test('should throw when there is no supported backend', () {
      expect(() => AudioDeviceContext(backends: []), throwsA(isA<MaException>()));
    });

    test('getDevices should return correct devices', () {
      final context = AudioDeviceContext(backends: AudioDeviceBackend.values);

      final playbackDevices = context.getDevices(AudioDeviceType.playback);
      expect(playbackDevices.isNotEmpty, isTrue);
      expect(playbackDevices.every((d) => d.type == AudioDeviceType.playback), isTrue);

      final captureDevices = context.getDevices(AudioDeviceType.capture);
      expect(captureDevices.isNotEmpty, isTrue);
      expect(captureDevices.every((d) => d.type == AudioDeviceType.capture), isTrue);
    });
  });
}
