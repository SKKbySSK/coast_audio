import 'dart:io';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioFileDataSource extends AudioDataSource {
  AudioFileDataSource({required File file}) : file = file.openSync();
  AudioFileDataSource.fromRandomAccessFile({required this.file});
  final RandomAccessFile file;

  @override
  int get length => file.lengthSync();

  @override
  int get position => file.positionSync();

  @override
  int readBytesSync(List<int> buffer, int offset, int count) {
    return file.readIntoSync(buffer, offset, count);
  }

  @override
  void seekSync(int count, [SeekOrigin origin = SeekOrigin.current]) {
    final newPosition = origin.getPosition(position: position, length: length, count: count);
    file.setPositionSync(newPosition);
  }

  @override
  Future<int> readBytes(List<int> buffer, int offset, int count) {
    return file.readInto(buffer, offset, count);
  }

  @override
  Future<void> seek(int count, [SeekOrigin origin = SeekOrigin.current]) async {
    final newPosition = origin.getPosition(position: position, length: length, count: count);
    await file.setPosition(newPosition);
  }
}
