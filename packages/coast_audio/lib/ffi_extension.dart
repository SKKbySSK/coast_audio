import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';

extension ArrayCharExtension on Array<Char> {
  String getString(int maxLength, {Memory? memory}) {
    final mem = memory ?? Memory();
    final pStr = mem.allocator.allocate<Char>(maxLength);
    for (var i = 0; maxLength > i; i++) {
      pStr[i] = this[i];
    }
    final str = pStr.cast<Utf8>().toDartString();
    mem.allocator.free(pStr);
    return str;
  }

  void setString(String value, {Memory? memory}) {
    final mem = memory ?? Memory();
    final pStr = value.toNativeUtf8(allocator: mem.allocator).cast<Char>();
    for (var i = 0; value.codeUnits.length > i; i++) {
      this[i] = pStr[i];
    }
    mem.allocator.free(pStr);
  }
}
