import 'dart:io';

import 'package:coast_audio/coast_audio.dart';

class AudioFileDataSource implements AudioInputDataSource, AudioOutputDataSource {
  AudioFileDataSource({
    required File file,
    required FileMode mode,
  }) : file = file.openSync(mode: mode);
  AudioFileDataSource.fromRandomAccessFile({required this.file});
  final RandomAccessFile file;

  @override
  int get length => file.lengthSync();

  @override
  int get position => file.positionSync();

  @override
  void seek(int count, [SeekOrigin origin = SeekOrigin.current]) {
    final newPosition = origin.getPosition(position: position, length: length, count: count);
    file.setPositionSync(newPosition);
  }

  @override
  int readBytes(List<int> buffer, int offset, int count) {
    return file.readIntoSync(buffer, offset, count);
  }

  @override
  int writeBytes(List<int> buffer, int offset, int count) {
    file.writeFromSync(buffer, offset, count);
    return count;
  }
}
