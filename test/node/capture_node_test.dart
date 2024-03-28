import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'capture_node_test.mocks.dart';

@GenerateMocks([CaptureDevice])
void main() {
  final device = MockCaptureDevice();

  setUp(() => reset(device));

  group('CaptureNode', () {
    test('read should return number of frames read', () {
      when(device.read(any)).thenReturn(CaptureDeviceReadResult(MaResult.success, 100));
      when(device.isStarted).thenReturn(true);

      AllocatedAudioFrames(length: 1024, format: AudioFormat(sampleRate: 48000, channels: 2)).acquireBuffer((buffer) {
        final node = CaptureNode(device: device, autoStart: false);
        final result = node.read(node.outputBus, buffer);

        expect(result.frameCount, 100);
        expect(result.isEnd, isFalse);
      });
    });

    test('read should start the device if autoStart == true', () {
      when(device.read(any)).thenReturn(CaptureDeviceReadResult(MaResult.success, 100));
      when(device.isStarted).thenReturn(false);

      AllocatedAudioFrames(length: 1024, format: AudioFormat(sampleRate: 48000, channels: 2)).acquireBuffer((buffer) {
        final node = CaptureNode(device: device, autoStart: true);
        node.read(node.outputBus, buffer);

        verify(device.start()).called(1);
      });
    });

    test('read should not start the device if autoStart == false', () {
      when(device.read(any)).thenReturn(CaptureDeviceReadResult(MaResult.success, 100));
      when(device.isStarted).thenReturn(false);

      AllocatedAudioFrames(length: 1024, format: AudioFormat(sampleRate: 48000, channels: 2)).acquireBuffer((buffer) {
        final node = CaptureNode(device: device, autoStart: false);
        node.read(node.outputBus, buffer);

        verifyNever(device.start());
      });
    });
  });
}
