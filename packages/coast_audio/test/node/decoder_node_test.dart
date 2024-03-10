import 'package:coast_audio/coast_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'decoder_node_test.mocks.dart';

@GenerateMocks([AudioDecoder])
void main() {
  final decoder = MockAudioDecoder();

  setUp(() => reset(decoder));

  group('DecoderNode', () {
    test('outputFormat should return decoder\'s format', () {
      const format = AudioFormat(sampleRate: 44100, channels: 2);
      when(decoder.outputFormat).thenReturn(format);

      final node = DecoderNode(decoder: decoder);
      expect(node.outputFormat, format);
    });

    test('decode should be called when reading (isEnd == false)', () {
      const format = AudioFormat(sampleRate: 44100, channels: 2);
      const decodeResult = AudioDecodeResult(frameCount: 1024, isEnd: false);
      when(decoder.decode(destination: anyNamed('destination'))).thenReturn(decodeResult);

      final node = DecoderNode(decoder: decoder);
      AllocatedAudioFrames(length: decodeResult.frameCount, format: format).acquireBuffer((buffer) {
        final result = node.outputBus.read(buffer);
        verify(decoder.decode(destination: buffer)).called(1);
        expect(result.frameCount, decodeResult.frameCount);
        expect(result.isEnd, decodeResult.isEnd);
      });
    });

    test('decode should be called when reading (isEnd == true)', () {
      const format = AudioFormat(sampleRate: 44100, channels: 2);
      const decodeResult = AudioDecodeResult(frameCount: 1024, isEnd: true);
      when(decoder.decode(destination: anyNamed('destination'))).thenReturn(decodeResult);

      final node = DecoderNode(decoder: decoder);
      AllocatedAudioFrames(length: decodeResult.frameCount, format: format).acquireBuffer((buffer) {
        final result = node.outputBus.read(buffer);
        verify(decoder.decode(destination: buffer)).called(1);
        expect(result.frameCount, decodeResult.frameCount);
        expect(result.isEnd, decodeResult.isEnd);
      });
    });
  });
}
