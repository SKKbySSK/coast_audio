import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

abstract class AudioInputDataSource {
  const AudioInputDataSource();

  int get position;
  int? get length;
  bool get canSeek;

  void seek(int count, [SeekOrigin origin = SeekOrigin.current]);
  int readBytes(Uint8List buffer, int offset, int count);
}
