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
  invalidOperation(-3),
  outOfMemory(-4),
  outOfRange(-5),
  accessDenied(-6),
  doesNotExist(-7),
  alreadyExists(-8),
  tooManyOpenFiles(-9),
  invalidFile(-10),
  tooBig(-11),
  pathTooLong(-12),
  nameTooLong(-13),
  notDirectory(-14),
  isDirectory(-15),
  directoryNotEmpty(-16),
  atEnd(-17),
  noSpace(-18),
  busy(-19),
  ioError(-20),
  interrupt(-21),
  unavailable(-22),
  alreadyInUse(-23),
  badAddress(-24),
  badSeek(-25),

  /* General miniaudio-specific errors. */
  formatNotSupported(-100),
  deviceTypeNotSupported(-101),
  shareModeNotSupported(-102),
  noBackend(-103),
  noDevice(-104),
  apiNotFound(-105),
  invalidDeviceConfig(-106),
  loop(-107),

  /* State errors. */
  deviceNotInitialized(-200),
  deviceAlreadyInitialized(-201),
  deviceNotStarted(-202),
  deviceNotStopped(-203),

  /* Operation errors. */
  failedToInitBackend(-300),
  failedToOpenBackendDevice(-301),
  failedToStartBackendDevice(-302),
  failedToStopBackendDevice(-303);

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
