import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';

extension ArrayCharExtension on Array<Char> {
  String getUtf8String(int maxLength, {Memory? memory}) {
    final mem = memory ?? Memory();
    final pStr = mem.allocator.allocate<Char>(maxLength);
    try {
      for (var i = 0; maxLength > i; i++) {
        pStr[i] = this[i];
      }
      return pStr.cast<Utf8>().toDartString();
    } finally {
      mem.allocator.free(pStr);
    }
  }

  String getAsciiString(int maxLength) {
    var str = '';
    for (var i = 0; maxLength > i; i++) {
      str += String.fromCharCode(this[i]);
    }
    return str;
  }

  void setUtf8String(String value, {Memory? memory}) {
    final mem = memory ?? Memory();
    final pStr = value.toNativeUtf8(allocator: mem.allocator).cast<Char>();
    for (var i = 0; value.codeUnits.length > i; i++) {
      this[i] = pStr[i];
    }
    mem.allocator.free(pStr);
  }

  void setAsciiString(String value) {
    for (var i = 0; value.length > i; i++) {
      this[i] = value.codeUnitAt(i);
    }
  }
}
