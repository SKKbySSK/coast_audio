import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AllocatedAudioFrames', () {
    test('add offset', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedAudioFrames(length: 10, format: format).lock();
      var subBuffer = buffer.offset(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      expect(subBuffer.pBuffer.address, buffer.pBuffer.address + 5 * 8);
    });

    test('set limit', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      var buffer = AllocatedAudioFrames(length: 10, format: format).lock();
      var subBuffer = buffer.limit(5);
      expect(subBuffer.sizeInFrames, 5);
      expect(subBuffer.sizeInBytes, 5 * 8);
      expect(subBuffer.pBuffer.address, buffer.pBuffer.address);
    });

    test('copyTo', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final src = AllocatedAudioFrames(length: 10, format: format);
      src.acquireBuffer((buffer) {
        final list = buffer.asFloat32ListView();
        list.fillRange(0, list.length, 1);

        final dst = AllocatedAudioFrames(length: 10, format: format);
        dst.acquireBuffer((dstBuffer) {
          buffer.copyTo(dstBuffer);

          final dstList = dstBuffer.asFloat32ListView();
          expect(dstList.every((element) => element == 1), isTrue);
        });
      });
    });

    test('copyFloat32List', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final src = AllocatedAudioFrames(length: 10, format: format);
      src.acquireBuffer((buffer) {
        final list = buffer.asFloat32ListView();
        list.fillRange(0, list.length, 1);

        final copied = buffer.copyFloat32List(deinterleave: false);
        expect(copied.every((element) => element == 1), isTrue);
      });
    });

    test('copyFloat32List (deinterleaved)', () {
      final format = AudioFormat(sampleRate: 48000, channels: 2);
      final src = AllocatedAudioFrames(length: 10, format: format);
      src.acquireBuffer((buffer) {
        final list = buffer.asFloat32ListView();
        for (var i = 0; list.length > i; i++) {
          list[i] = i.isEven ? 1 : -1;
        }

        final copied = buffer.copyFloat32List(deinterleave: true);
        final leftCh = copied.sublist(0, copied.length ~/ 2);
        final rightCh = copied.sublist(copied.length ~/ 2);
        expect(leftCh.every((element) => element == 1), isTrue);
        expect(rightCh.every((element) => element == -1), isTrue);
      });
    });
  });
}
