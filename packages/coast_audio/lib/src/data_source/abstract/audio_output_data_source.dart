import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

abstract class AudioOutputDataSource {
  const AudioOutputDataSource();

  int get length;
  bool get canSeek;

  void seek(int count, [SeekOrigin origin = SeekOrigin.current]);
  int writeBytes(Uint8List buffer, int offset, int count);
}
