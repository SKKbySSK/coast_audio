class MaResult {
  const MaResult(this.code);
  final int code;

  bool get isSuccess => code == MaResultName.success.code;

  bool get isEnd => code == MaResultName.atEnd.code;

  MaResultName? get name {
    final values = MaResultName.values;
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }
    return null;
  }

  void throwIfNeeded() {
    if (code != 0) {
      throw MaResultException(this);
    }
  }
}

enum MaResultName {
  success(0),
  error(-1),
  invalidArgs(-2),
  atEnd(-17);

  const MaResultName(this.code);
  final int code;
}

class MaResultException implements Exception {
  MaResultException(this.result);
  final MaResult result;

  @override
  String toString() {
    return 'MaResultException(name: ${result.name?.name ?? 'unknown'}, code: ${result.code})';
  }
}
