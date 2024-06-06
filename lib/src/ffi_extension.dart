import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:ffi/ffi.dart';

extension ArrayCharExtension on Array<Char> {
  String getUtf8String(int maxLength, {bool zeroTerminated = true}) {
    final mem = Memory();
    final pStr = mem.allocator.allocate<Char>(maxLength);
    try {
      for (var i = 0; maxLength > i; i++) {
        pStr[i] = this[i];
        if (zeroTerminated && this[i] == 0) {
          break;
        }
      }
      return pStr.cast<Utf8>().toDartString();
    } finally {
      mem.allocator.free(pStr);
    }
  }

  String getAsciiString(int maxLength, {bool zeroTerminated = true}) {
    var str = '';
    for (var i = 0; maxLength > i; i++) {
      if (zeroTerminated && this[i] == 0) {
        break;
      }
      str += String.fromCharCode(this[i]);
    }
    return str;
  }

  void setUtf8String(String value) {
    final mem = Memory();
    final pStr = value.toNativeUtf8(allocator: mem.allocator).cast<Char>();
    for (var i = 0;; i++) {
      this[i] = pStr[i];
      if (pStr[i] == 0) {
        break;
      }
    }
    mem.allocator.free(pStr);
  }

  void setAsciiString(
    String value, {
    required bool nullTerminated,
  }) {
    for (var i = 0; value.length > i; i++) {
      this[i] = value.codeUnitAt(i);
    }
    if (nullTerminated) {
      this[value.length] = 0;
    }
  }
}
