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
