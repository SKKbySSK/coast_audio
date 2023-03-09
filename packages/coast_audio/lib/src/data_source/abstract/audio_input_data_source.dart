import 'package:coast_audio/coast_audio.dart';

abstract class AudioInputDataSource {
  const AudioInputDataSource();

  int get position;
  int get length;

  void seek(int count, [SeekOrigin origin = SeekOrigin.current]);
  int readBytes(List<int> buffer, int offset, int count);
}
