class AudioBusConnectionException implements Exception {
  const AudioBusConnectionException.sameNode()
      : message = 'input bus and output bus have same node reference',
        code = -1;

  const AudioBusConnectionException.incompatibleFormat()
      : message = 'input bus and output bus have incompatible format',
        code = -2;

  final String message;
  final int code;

  @override
  String toString() {
    return 'AudioBusConnectionException(code: $code, message: $message)';
  }
}
