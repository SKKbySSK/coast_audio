import 'internal/generated/bindings.dart';

/// miniaudio result codes.
enum MaResult {
  success(ma_result.MA_SUCCESS),
  error(ma_result.MA_ERROR),
  invalidArgs(ma_result.MA_INVALID_ARGS),
  invalidOperation(ma_result.MA_INVALID_OPERATION),
  outOfMemory(ma_result.MA_OUT_OF_MEMORY),
  outOfRange(ma_result.MA_OUT_OF_RANGE),
  accessDenied(ma_result.MA_ACCESS_DENIED),
  doesNotExist(ma_result.MA_DOES_NOT_EXIST),
  alreadyExists(ma_result.MA_ALREADY_EXISTS),
  tooManyOpenFiles(ma_result.MA_TOO_MANY_OPEN_FILES),
  invalidFile(ma_result.MA_INVALID_FILE),
  tooBig(ma_result.MA_TOO_BIG),
  pathTooLong(ma_result.MA_PATH_TOO_LONG),
  nameTooLong(ma_result.MA_NAME_TOO_LONG),
  notDirectory(ma_result.MA_NOT_DIRECTORY),
  isDirectory(ma_result.MA_IS_DIRECTORY),
  directoryNotEmpty(ma_result.MA_DIRECTORY_NOT_EMPTY),
  atEnd(ma_result.MA_AT_END),
  noSpace(ma_result.MA_NO_SPACE),
  busy(ma_result.MA_BUSY),
  ioError(ma_result.MA_IO_ERROR),
  interrupt(ma_result.MA_INTERRUPT),
  unavailable(ma_result.MA_UNAVAILABLE),
  alreadyInUse(ma_result.MA_ALREADY_IN_USE),
  badAddress(ma_result.MA_BAD_ADDRESS),
  badSeek(ma_result.MA_BAD_SEEK),
  badPipe(ma_result.MA_BAD_PIPE),
  deadlock(ma_result.MA_DEADLOCK),
  tooManyLinks(ma_result.MA_TOO_MANY_LINKS),
  notImplemented(ma_result.MA_NOT_IMPLEMENTED),
  noMessage(ma_result.MA_NO_MESSAGE),
  badMessage(ma_result.MA_BAD_MESSAGE),
  noDataAvailable(ma_result.MA_NO_DATA_AVAILABLE),
  invalidData(ma_result.MA_INVALID_DATA),
  timeout(ma_result.MA_TIMEOUT),
  noNetwork(ma_result.MA_NO_NETWORK),
  notUnique(ma_result.MA_NOT_UNIQUE),
  notSocket(ma_result.MA_NOT_SOCKET),
  noAddress(ma_result.MA_NO_ADDRESS),
  badProtocol(ma_result.MA_BAD_PROTOCOL),
  protocolUnavail(ma_result.MA_PROTOCOL_UNAVAILABLE),
  protocolNotSupported(ma_result.MA_PROTOCOL_NOT_SUPPORTED),
  protocolFamilyNotSupported(ma_result.MA_PROTOCOL_FAMILY_NOT_SUPPORTED),
  addressFamilyNotSupported(ma_result.MA_ADDRESS_FAMILY_NOT_SUPPORTED),
  socketNotSupported(ma_result.MA_SOCKET_NOT_SUPPORTED),
  connectionReset(ma_result.MA_CONNECTION_RESET),
  alreadyConnected(ma_result.MA_ALREADY_CONNECTED),
  notConnected(ma_result.MA_NOT_CONNECTED),
  connectionRefused(ma_result.MA_CONNECTION_REFUSED),
  noHost(ma_result.MA_NO_HOST),
  inProgress(ma_result.MA_IN_PROGRESS),
  cancelled(ma_result.MA_CANCELLED),
  memoryAlreadyMapped(ma_result.MA_MEMORY_ALREADY_MAPPED),
  crcMismatch(ma_result.MA_CRC_MISMATCH),
  formatNotSupported(ma_result.MA_FORMAT_NOT_SUPPORTED),
  deviceTypeNotSupported(ma_result.MA_DEVICE_TYPE_NOT_SUPPORTED),
  shareModeNotSupported(ma_result.MA_SHARE_MODE_NOT_SUPPORTED),
  noBackend(ma_result.MA_NO_BACKEND),
  noDevice(ma_result.MA_NO_DEVICE),
  apiNotFound(ma_result.MA_API_NOT_FOUND),
  invalidDeviceConfig(ma_result.MA_INVALID_DEVICE_CONFIG),
  loop(ma_result.MA_LOOP),
  backendNotEnabled(ma_result.MA_BACKEND_NOT_ENABLED),
  deviceNotInitialized(ma_result.MA_DEVICE_NOT_INITIALIZED),
  deviceAlreadyInitialized(ma_result.MA_DEVICE_ALREADY_INITIALIZED),
  deviceNotStarted(ma_result.MA_DEVICE_NOT_STARTED),
  deviceNotStopped(ma_result.MA_DEVICE_NOT_STOPPED),
  failedToInitBackend(ma_result.MA_FAILED_TO_INIT_BACKEND),
  failedToOpenBackendDevice(ma_result.MA_FAILED_TO_OPEN_BACKEND_DEVICE),
  failedToStartBackendDevice(ma_result.MA_FAILED_TO_START_BACKEND_DEVICE),
  failedToStopBackendDevice(ma_result.MA_FAILED_TO_STOP_BACKEND_DEVICE);

  const MaResult(this.code);
  final int code;

  /// Returns `true` if this result is [success].
  bool get isSuccess => this == success;

  /// Throws a [MaException] if this result is not [success].
  void throwIfNeeded() {
    if (!isSuccess) {
      throw MaException(this);
    }
  }
}

/// An exception thrown when a miniaudio operation fails.
class MaException implements Exception {
  MaException(this.result);

  /// The result code of the failed operation.
  final MaResult result;

  @override
  String toString() {
    return 'MaException(name: ${result.name}, code: ${result.code})';
  }
}
