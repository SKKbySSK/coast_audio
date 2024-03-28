import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'playback_node_test.mocks.dart';

@GenerateMocks([PlaybackDevice])
void main() {
  const format = AudioFormat(sampleRate: 48000, channels: 2);
  final device = MockPlaybackDevice();

  group('PlaybackNode', () {
    test('read should return number of frames read into the device when availableWriteFrames is too short', () {
      when(device.availableWriteFrames).thenReturn(100);
      when(device.format).thenReturn(format);
      when(device.write(any)).thenReturn(PlaybackDeviceWriteResult(MaResult.success, 100));

      final source = FunctionNode(function: SineFunction(), format: format, frequency: 440);
      final node = PlaybackNode(device: device);

      source.outputBus.connect(node.inputBus);

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        final result = node.read(node.outputBus, buffer);

        expect(result.frameCount, 100);
        expect(result.isEnd, isFalse);
      });
    });

    test('read should return length of buffer when availableWriteFrames is enough', () {
      when(device.availableWriteFrames).thenReturn(2048);
      when(device.format).thenReturn(format);
      when(device.write(any)).thenReturn(PlaybackDeviceWriteResult(MaResult.success, 1024));

      final source = FunctionNode(function: SineFunction(), format: format, frequency: 440);
      final node = PlaybackNode(device: device);

      source.outputBus.connect(node.inputBus);

      AllocatedAudioFrames(length: 1024, format: format).acquireBuffer((buffer) {
        final result = node.read(node.outputBus, buffer);

        expect(result.frameCount, 1024);
        expect(result.isEnd, isFalse);
      });
    });
  });
}
