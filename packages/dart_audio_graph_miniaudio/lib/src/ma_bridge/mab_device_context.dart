import 'dart:ffi';

import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_extension.dart';

class MabDeviceContext extends MabBase {
  static MabDeviceContext? _instance;

  static MabDeviceContext get sharedInstance {
    if (_instance == null) {
      throw Exception('MabDeviceContext.enabledSharedInstance() was not called');
    }
    return _instance!;
  }

  static void enableSharedInstance({
    required List<MabBackend> backends,
  }) {
    _instance = MabDeviceContext(backends: backends);
  }

  MabDeviceContext({
    required List<MabBackend> backends,
  }) {
    final pBackends = allocate<Int32>(sizeOf<Int32>() * backends.length);
    for (var i = 0; backends.length > i; i++) {
      pBackends.elementAt(i).value = backends[i].value;
    }
    library.mab_device_context_init(pDeviceContext, pBackends, backends.length).throwMaResultIfNeeded();
  }

  late final pDeviceContext = allocate<mab_device_context>(sizeOf<mab_device_context>());

  @override
  void uninit() {
    library.mab_device_context_uninit(pDeviceContext).throwMaResultIfNeeded();
  }
}
