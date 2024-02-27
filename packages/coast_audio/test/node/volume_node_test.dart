import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

class SourceNode extends DataSourceNode {
  SourceNode({required this.outputFormat});

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
        final source = SourceNode(outputFormat: format);
        final volume = VolumeNode(volume: 0);
        source.outputBus.connect(volume.inputBus);

        final frames = AllocatedAudioFrames(length: 100, format: format);
        frames.acquireBuffer((buffer) {
          volume.outputBus.read(buffer);

          final list = buffer.asUint8ListViewBytes();
          expect(list.every((element) => element == sampleFormat.mid), isTrue);
        });
      });

      test('[${sampleFormat.name}] set volume to 100%', () {
        final source = SourceNode(outputFormat: format);
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
