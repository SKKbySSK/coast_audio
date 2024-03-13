import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class _SourceNode extends DataSourceNode {
  _SourceNode({required this.outputFormat});

  @override
  final AudioFormat outputFormat;

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    Memory().setMemory(buffer.pBuffer.cast(), 1, buffer.sizeInBytes);
    return AudioReadResult(frameCount: buffer.sizeInFrames, isEnd: false);
  }
}

void main() {
  group('VolumeNode', () {
    for (final sampleFormat in SampleFormat.values) {
      final format = AudioFormat(sampleRate: 44100, channels: 2, sampleFormat: sampleFormat);

      test('[${sampleFormat.name}] set volume to 0%', () {
        final source = _SourceNode(outputFormat: format);
        final volume = VolumeNode(volume: 0);
        source.outputBus.connect(volume.inputBus);

        final frames = AllocatedAudioFrames(length: 100, format: format);
        frames.acquireBuffer((buffer) {
          volume.outputBus.read(buffer);

          final list = buffer.asUint8ListViewBytes();
          expect(list.every((element) => element == sampleFormat.mid), isTrue);
        });
      });

      test('[${sampleFormat.name}] set volume to 50%', () {
        final source = FunctionNode(function: OffsetFunction(1), format: format, frequency: 440);
        final volume = VolumeNode(volume: 0.5);
        source.outputBus.connect(volume.inputBus);

        final frames = AllocatedAudioFrames(length: 100, format: format);
        frames.acquireBuffer((buffer) {
          volume.outputBus.read(buffer);

          switch (sampleFormat) {
            case SampleFormat.float32:
              final list = buffer.asFloat32ListView();
              expect(list.every((element) => element == (SampleFormat.float32.max * 0.5).toDouble()), isTrue);
              break;
            case SampleFormat.int16:
              final list = buffer.asInt16ListView();
              expect(list.every((element) => element.toInt() == (SampleFormat.int16.max * 0.5).toInt()), isTrue);
              break;
            case SampleFormat.int32:
              final list = buffer.asInt32ListView();
              expect(list.every((element) => element.toInt() == (SampleFormat.int32.max * 0.5).toInt()), isTrue);
              break;
            case SampleFormat.uint8:
              final list = buffer.asUint8ListViewFrames();
              expect(list.every((element) => element.toInt() == (SampleFormat.uint8.max * 0.5).toInt()), isTrue);
              break;
          }
        });
      });

      test('[${sampleFormat.name}] set volume to 100%', () {
        final source = _SourceNode(outputFormat: format);
        final volume = VolumeNode(volume: 1);
        source.outputBus.connect(volume.inputBus);

        final frames = AllocatedAudioFrames(length: 100, format: format);
        frames.acquireBuffer((buffer) {
          volume.outputBus.read(buffer);

          final list = buffer.asUint8ListViewBytes();
          expect(list.every((element) => element == 1), isTrue);
        });
      });
    }
  });
}
