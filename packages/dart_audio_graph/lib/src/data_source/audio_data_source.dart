abstract class AudioDataSource {
  const AudioDataSource();

  int get position;
  int get length;

  void seekSync(int count, [SeekOrigin origin = SeekOrigin.current]);
  int readBytesSync(List<int> buffer, int offset, int count);

  Future<void> seek(int count, [SeekOrigin origin = SeekOrigin.current]) async => seekSync(count, origin);
  Future<int> readBytes(List<int> buffer, int offset, int count) async => readBytesSync(buffer, offset, count);
}

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
