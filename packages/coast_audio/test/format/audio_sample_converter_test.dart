import 'dart:ffi';

import 'package:coast_audio/experimental.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

void main() {
  group('AudioSampleConverterInt24ToInt32', () {
    test('convert positive value', () {
      final converter = AudioSampleConverterInt24ToInt32();

      final pInSample = malloc.allocate<Int32>(sizeOf<Int32>());
      final pOutSample = malloc.allocate<Int32>(sizeOf<Int32>());
      pOutSample.value = 0;

      final inputBuffer = pInSample.cast<Uint8>().asTypedList(3);
      final outputBuffer = pOutSample.cast<Uint8>().asTypedList(4);

      // 703710 -> 0x0ABCDE(LittleEndian)
      inputBuffer[0] = 0xDE;
      inputBuffer[1] = 0xBC;
      inputBuffer[2] = 0x0A;

      converter.convertSample(inputBuffer, outputBuffer);
      expect(pOutSample.value, 703710 * 256);
    });

    test('convert negative value', () {
      final converter = AudioSampleConverterInt24ToInt32();

      final pInSample = malloc.allocate<Int32>(sizeOf<Int32>());
      final pOutSample = malloc.allocate<Int32>(sizeOf<Int32>());
      pOutSample.value = 0;

      final inputBuffer = pInSample.cast<Uint8>().asTypedList(3);
      final outputBuffer = pOutSample.cast<Uint8>().asTypedList(4);

      // -703710
      inputBuffer[0] = ~0xDE + 1;
      inputBuffer[1] = ~0xBC;
      inputBuffer[2] = ~0x0A;

      converter.convertSample(inputBuffer, outputBuffer);
      expect(pOutSample.value, -703710 * 256);
    });

    test('convert all samples', () {
      final converter = AudioSampleConverterInt24ToInt32();

      final pInSample = malloc.allocate<Int32>(sizeOf<Int32>() * 2);
      final pOutSample = malloc.allocate<Int32>(sizeOf<Int32>() * 2);
      pOutSample.value = 0;

      final inputBuffer = pInSample.cast<Uint8>().asTypedList(3 * 2);
      final outputBuffer = pOutSample.cast<Uint8>().asTypedList(4 * 2);

      // 703710 -> 0x0ABCDE(LittleEndian)
      inputBuffer[0] = 0xDE;
      inputBuffer[1] = 0xBC;
      inputBuffer[2] = 0x0A;

      // -703710
      inputBuffer[3] = ~0xDE + 1;
      inputBuffer[4] = ~0xBC;
      inputBuffer[5] = ~0x0A;

      converter.convertSamples(inputBuffer, outputBuffer);
      expect(pOutSample.value, 703710 * 256);
      expect(Pointer<Int32>.fromAddress(pOutSample.address + sizeOf<Int32>()).value, -703710 * 256);
    });
  });
}
