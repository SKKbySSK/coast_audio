import 'dart:io';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioFileDataSource', () {
    void sharedTest({required bool useCache}) {
      test('read should fill the buffer and advance position (useCache=$useCache)', () {
        final dataSource = AudioFileDataSource(
          file: File('${Directory.current.path}/test/asset/number.bin'),
          mode: FileMode.read,
          cacheLength: useCache,
          cachePosition: useCache,
        );

        final buffer = Uint8List(9);
        expect(dataSource.readBytes(buffer), 9);
        expect(buffer, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(dataSource.position, 9);

        dataSource.position = 5;
        expect(dataSource.readBytes(buffer), 4);
        expect(buffer.sublist(0, 4), [6, 7, 8, 9]);
      });

      test('write should output the buffer and advance position (useCache=$useCache)', () {
        final path = '${Directory.current.path}/test/asset/output.bin';
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }

        final dataSource = AudioFileDataSource(
          file: file,
          mode: FileMode.write,
          cacheLength: useCache,
          cachePosition: useCache,
        );

        expect(dataSource.length, 0);

        final buffer = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(dataSource.writeBytes(buffer), 9);
        expect(dataSource.position, 9);
        expect(dataSource.length, 9);

        dataSource.position = 0;

        final readBuffer = Uint8List(9);
        expect(dataSource.readBytes(readBuffer), 9);
        expect(readBuffer, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(dataSource.position, 9);
        expect(dataSource.length, 9);
      });
    }

    sharedTest(useCache: true);
    sharedTest(useCache: false);
  });
}
