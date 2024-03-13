import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'package:coast_audio/src/ffi_extension.dart';

final class _MockStruct extends Union {
  @Array.multi([6])
  external Array<Char> string;

  @Array.multi([6])
  external Array<UnsignedChar> uchars;
}

Pointer<_MockStruct> _allocateStruct() {
  return malloc.allocate<_MockStruct>(sizeOf<_MockStruct>());
}

void main() {
  group('ASCII', () {
    test('getAsciiString should return correct result', () {
      final pStr = _allocateStruct();
      pStr.ref.string[0] = 72; // H
      pStr.ref.string[1] = 101; // e
      pStr.ref.string[2] = 108; // l
      pStr.ref.string[3] = 108; // l
      pStr.ref.string[4] = 111; // o
      pStr.ref.string[5] = 0; // \0
      expect(pStr.ref.string.getAsciiString(6), 'Hello');
    });

    test('setAsciiString should set correct values', () {
      final pStr = _allocateStruct();
      pStr.ref.string.setAsciiString('Hello');

      expect(pStr.ref.string[0], 72); // H
      expect(pStr.ref.string[1], 101); // e
      expect(pStr.ref.string[2], 108); // l
      expect(pStr.ref.string[3], 108); // l
      expect(pStr.ref.string[4], 111); // o
      expect(pStr.ref.string[5], 0); // \0
    });
  });

  group('UTF-8', () {
    test('getUtf8String should return correct result', () {
      final pStr = _allocateStruct();
      pStr.ref.string[0] = 72; // H
      pStr.ref.string[1] = 101; // e
      pStr.ref.string[2] = 108; // l
      pStr.ref.string[3] = 108; // l
      pStr.ref.string[4] = 111; // o
      pStr.ref.string[5] = 0; // \0
      expect(pStr.ref.string.getUtf8String(6), 'Hello');
    });

    test('setUtf8String should set correct values', () {
      final pStr = _allocateStruct();
      pStr.ref.string.setUtf8String('√©');

      expect(pStr.ref.uchars[0], 0xE2);
      expect(pStr.ref.uchars[1], 0x88);
      expect(pStr.ref.uchars[2], 0x9A); // √
      expect(pStr.ref.uchars[3], 0xC2);
      expect(pStr.ref.uchars[4], 0xA9); // ©
      expect(pStr.ref.uchars[5], 0);
    });
  });
}
