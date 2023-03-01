import 'package:dart_audio_graph/dart_audio_graph.dart';

abstract class AudioOutputDataSource {
  const AudioOutputDataSource();

  int get length;

  void seek(int count, [SeekOrigin origin = SeekOrigin.current]);
  int writeBytes(List<int> buffer, int offset, int count);
}
