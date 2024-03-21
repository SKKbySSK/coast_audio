import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import 'coast_audio_native_library.dart';

void main() {
  group('CoastAudioNative', () {
    test('initialize should return the native bindings for the native coast_audio library', () {
      expect(() => CoastAudioNative.initialize(library: resolveNativeLib()), returnsNormally);
    });
  });
}
