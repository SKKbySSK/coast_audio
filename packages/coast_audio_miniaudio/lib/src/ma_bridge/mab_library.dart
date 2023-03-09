import 'dart:ffi';
import 'dart:io';

import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';

/// MabLibrary manages mabridge's [DynamicLibrary] instance
class MabLibrary {
  MabLibrary._();

  /// Initialize the library.
  /// If [library] is not null, this packages uses it to call native functions.
  /// Otherwise, [DynamicLibrary.open('libmabridge.so')] or [DynamicLibrary.process()] will be used to resolve the library.
  static void initialize([DynamicLibrary? library]) {
    if (library != null) {
      _library = MaBridge(library);
      return;
    }

    if (Platform.isAndroid) {
      _library = MaBridge(DynamicLibrary.open('libmabridge.so'));
    } else {
      _library = MaBridge(DynamicLibrary.process());
    }
  }

  static MaBridge? _library;

  /// Retrieve the library instance.
  /// You have to call [MabLibrary.initialize] in order to use this property.
  static MaBridge get library {
    if (_library == null) {
      throw Exception('MabLibrary.initialize was not called');
    }
    return _library!;
  }
}
