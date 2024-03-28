import 'dart:ffi';
import 'dart:isolate';

import 'package:coast_audio/src/interop/helper/coast_audio_interop.dart';
import 'package:coast_audio/src/interop/internal/generated/bindings.dart';
import 'package:coast_audio/src/interop/internal/ma_extension.dart';
import 'package:ffi/ffi.dart';

enum MaLogLevel {
  debug(ma_log_level.MA_LOG_LEVEL_DEBUG),
  info(ma_log_level.MA_LOG_LEVEL_INFO),
  warning(ma_log_level.MA_LOG_LEVEL_WARNING),
  error(ma_log_level.MA_LOG_LEVEL_ERROR),
  ;

  const MaLogLevel(this.maValue);
  final int maValue;
}

class MaLogData {
  const MaLogData({
    required this.level,
    required this.message,
  });
  final MaLogLevel level;
  final String message;
}

class CaLog {
  CaLog() {
    _interop.bindings.ca_log_init(_pLog).throwMaResultIfNeeded();
    _interop.bindings.ca_log_set_notification(_pLog, _receivePort.sendPort.nativePort);

    _interop.onInitialized();

    _receivePort.cast<int>().listen((messageCount) {
      final logs = _getLogs(count: messageCount);
      for (final log in logs) {
        onLog?.call(log.level, log.message);
      }
    });
  }

  final _interop = CoastAudioInterop();

  late final _pLog = _interop.allocateManaged<ca_log>(sizeOf<ca_log>());

  final _receivePort = ReceivePort();

  Pointer<ma_log> get ref => _interop.bindings.ca_log_get_ref(_pLog);

  void Function(MaLogLevel level, String message)? onLog;

  List<MaLogData> _getLogs({int count = 256}) {
    return _interop.allocateTemporary<UnsignedInt, List<MaLogData>>(
      sizeOf<UnsignedInt>(),
      (pCount) {
        return _interop.allocateTemporary<IntPtr, List<MaLogData>>(
          sizeOf<IntPtr>(),
          (ppMessages) {
            pCount.value = count;
            _interop.bindings.ca_log_get_messages(_pLog, ppMessages.cast(), pCount);

            final pMessages = Pointer.fromAddress(ppMessages.value);
            final logs = List.generate(
              pCount.value,
              (index) {
                final pMessage = Pointer<ca_log_message>.fromAddress(pMessages.address + index * sizeOf<ca_log_message>());
                return MaLogData(
                  level: MaLogLevel.values.firstWhere((l) => l.maValue == pMessage.ref.level),
                  message: pMessage.ref.pMessage.cast<Utf8>().toDartString(),
                );
              },
            );

            _interop.bindings.ca_log_release_messages(_pLog, pCount.value);

            return logs;
          },
        );
      },
    );
  }

  void dispose() {
    _interop.bindings.ca_log_uninit(_pLog);
    _interop.dispose();
    _receivePort.close();
  }
}
