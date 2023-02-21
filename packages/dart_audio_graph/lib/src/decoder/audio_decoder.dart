import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioDecoder {
  AudioDecoder();

  bool get isReady;

  AudioFormat? get format;

  int? get length;

  int? get position;

  Future<void> open({required AudioDataSource dataSource});

  Future<void> close();

  Future<bool> verify({required AudioDataSource dataSource}) async {
    try {
      await open(dataSource: dataSource);
      await close();
      return true;
    } on Exception {
      return false;
    }
  }

  int decode(RawFrameBuffer buffer);
}
