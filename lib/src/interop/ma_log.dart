import 'dart:ffi';

import 'package:coast_audio/src/interop/helper/coast_audio_interop.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';
import 'package:ffi/ffi.dart';

typedef MaLogCallback = void Function(MaLogLevel level, String message);

enum MaLogLevel {
  debug(ma_log_level.MA_LOG_LEVEL_DEBUG),
  info(ma_log_level.MA_LOG_LEVEL_INFO),
  warning(ma_log_level.MA_LOG_LEVEL_WARNING),
  error(ma_log_level.MA_LOG_LEVEL_ERROR),
  ;

  const MaLogLevel(this.maValue);
  final int maValue;
}

class MaLog {
  MaLog({required this.onLog}) {
    _interop.bindings.ma_log_init(nullptr, _pLog).throwMaResultIfNeeded();
    callback = _interop.bindings.ma_log_callback_init(_MaLogCallback.onLog, _MaLogCallback.register(this));
    _interop.bindings.ma_log_register_callback(_pLog, callback).throwMaResultIfNeeded();

    _interop.onInitialized();
  }

  final _interop = CoastAudioInterop();

  MaLogCallback? onLog;

  late final ma_log_callback callback;

  late final _pLog = _interop.allocateManaged<ma_log>(sizeOf<ma_log>());

  Pointer<ma_log> get handle => _pLog;

  void _onLog(MaLogLevel level, String message) {
    onLog?.call(level, message);
  }

  void dispose() {
    _interop.bindings.ma_log_unregister_callback(_pLog, callback);
    _MaLogCallback.unregister(callback.pUserData);
    _interop.bindings.ma_log_uninit(_pLog);
    _interop.dispose();
  }
}

class _MaLogCallback {
  static final onLog = Pointer.fromFunction<ma_log_callback_procFunction>(_onLog);

  static final _instances = <Pointer<Void>, MaLog>{};

  static Pointer<Void> register(MaLog instance) {
    final pUserData = instance._interop.memory.allocator.allocate<Void>(1);
    _instances[pUserData] = instance;
    return pUserData;
  }

  static void unregister(Pointer<Void> pUserData) {
    final instance = _instances.remove(pUserData);
    instance!._interop.memory.allocator.free(pUserData);
  }

  static void _onLog(Pointer<Void> pUserData, int level, Pointer<Char> pMessage) {
    final instance = _instances[pUserData];

    final logLevel = MaLogLevel.values.firstWhere((v) => v.maValue == level);
    final message = pMessage.cast<Utf8>().toDartString();
    instance?._onLog(logLevel, message);
  }
}
