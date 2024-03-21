import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

import '../interop/internal/coast_audio_native_library.dart';

void main() {
  CoastAudioNative.initialize(library: resolveNativeLib());

  group('AudioFormatConverter', () {
    test('convert should return number of frames converted', () {
      final converter = AudioFormatConverter(
        inputFormat: AudioFormat(
          sampleRate: 48000,
          channels: 1,
          sampleFormat: SampleFormat.uint8,
        ),
        outputFormat: AudioFormat(
          sampleRate: 96000,
          channels: 2,
          sampleFormat: SampleFormat.float32,
        ),
      );

      final inputBuffer = AllocatedAudioFrames(length: 48000, format: converter.inputFormat);
      final outputBuffer = AllocatedAudioFrames(
        length: converter.getExpectedOutputFrameCount(inputFrameCount: inputBuffer.sizeInFrames),
        format: converter.outputFormat,
      );

      inputBuffer.acquireBuffer((buffer) {
        FunctionNode(
          format: converter.inputFormat,
          function: SineFunction(),
          frequency: 440,
        ).outputBus.read(buffer);
      });

      inputBuffer.acquireBuffer((bufferIn) {
        outputBuffer.acquireBuffer((bufferOut) {
          final result = converter.convert(input: bufferIn, output: bufferOut);
          expect(result.inputFrameCount, 48000);
          expect(result.outputFrameCount, 96000);
        });
      });
    });

    test('getRequiredInputFrameCount should return frame count', () {
      final converter = AudioFormatConverter(
        inputFormat: AudioFormat(
          sampleRate: 48000,
          channels: 1,
          sampleFormat: SampleFormat.uint8,
        ),
        outputFormat: AudioFormat(
          sampleRate: 96000,
          channels: 2,
          sampleFormat: SampleFormat.float32,
        ),
      );

      expect(converter.getRequiredInputFrameCount(outputFrameCount: 96000), 48000);
    });
  });
}
