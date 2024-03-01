import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'node/helper/duration_node.dart';
import 'audio_task_test.mocks.dart';

@GenerateMocks([AudioEncoder])
void main() {
  group('AudioTask', () {
    test('should read audio buffer until the end of stream', () async {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final node = DurationNode(
        duration: AudioTime(10),
        node: FunctionNode(function: OffsetFunction(1), format: format, frequency: 440),
      );

      final framesPerRead = AudioTime(1).computeFrames(format);

      var readCount = 0;
      final task = AudioTask(
        clock: AudioLoopClock(),
        format: format,
        readFrameSize: framesPerRead,
        endpoint: node.outputBus,
        onRead: (buffer, isEnd) {
          readCount++;
          expect(buffer.sizeInFrames, framesPerRead);
          expect(isEnd, readCount == 10);
        },
      );

      task.start();
      expect(task.isStarted, isFalse);
    });

    test('should throw StateError when the clock is started unexpectedly', () {
      const format = AudioFormat(channels: 2, sampleRate: 44100);
      final node = FunctionNode(function: OffsetFunction(1), format: format, frequency: 440);

      final clock = AudioLoopClock();
      AudioTask(
        clock: clock,
        format: AudioFormat(channels: 2, sampleRate: 44100),
        readFrameSize: 100,
        endpoint: node.outputBus,
      );

      expect(() => clock.start(), throwsStateError);
    });
  });

  group('AudioEncodeTask', () {
    test('should encode correctly', () {
      const format = AudioFormat(channels: 1, sampleRate: 44100, sampleFormat: SampleFormat.uint8);
      final node = FunctionNode(function: OffsetFunction(1), format: format, frequency: 440);

      final encoder = MockAudioEncoder();
      when(encoder.encode(any)).thenAnswer((realInvocation) => AudioEncodeResult(frames: 4096));

      final task = AudioEncodeTask(
        format: format,
        endpoint: node.outputBus,
        encoder: encoder,
        readFrameSize: 4096,
      );

      task.onEncoded = (buffer, isEnd) {
        expect(buffer.sizeInFrames, 4096);
        task.stop();
      };

      task.start();
      expect(task.isStarted, isFalse);
      verify(encoder.start()).called(1);
      verify(encoder.encode(any)).called(1);
      verify(encoder.finalize()).called(1);
    });
  });
}
