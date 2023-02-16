import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_bridge/mab_audio_decoder.dart';

class MabAudioFileDecoderNode extends DataSourceNode {
  MabAudioFileDecoderNode({required this.decoder}) {
    setOutputs([outputBus]);
  }

  final MabAudioDecoder decoder;

  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => decoder.format);

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    if (buffer.sizeInFrames == 0) {
      // ma_decoder returns MA_INVALID_ARGS when reading zero frame
      return 0;
    }

    final decodeResult = decoder.decode(buffer);
    if (decodeResult.isError) {
      decodeResult.maResult.throwIfNeeded();
    }
    return decodeResult.framesRead!;
  }
}
