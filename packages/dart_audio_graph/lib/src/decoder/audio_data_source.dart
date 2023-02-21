import 'dart:io';

enum SeekOrigin {
  begin,
  current,
  end;

  int getPosition({required int position, required int length, required int count}) {
    switch (this) {
      case SeekOrigin.begin:
        return count;
      case SeekOrigin.current:
        return position + count;
      case SeekOrigin.end:
        return length + count;
    }
  }
}

abstract class AudioDataSource {
  const AudioDataSource();

  int get position;
  int get length;

  void seekSync(int count, [SeekOrigin origin = SeekOrigin.current]);
  int readBytesSync(List<int> buffer, int offset, int count);

  Future<void> seek(int count, [SeekOrigin origin = SeekOrigin.current]) async => seekSync(count, origin);
  Future<int> readBytes(List<int> buffer, int offset, int count) async => readBytesSync(buffer, offset, count);
}

class AudioFileSource extends AudioDataSource {
  AudioFileSource({required this.file});
  AudioFileSource.fromFile({required File file}) : file = file.openSync();
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
