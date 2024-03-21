import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

void main() {
  group('AudioMemoryDataSource', () {
    test('read should fill the buffer and advance position', () {
      final dataSource = AudioMemoryDataSource(buffer: [1, 2, 3, 4, 5, 6, 7, 8, 9]);

      final buffer = Uint8List(9);
      expect(dataSource.readBytes(buffer), 9);
      expect(buffer, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(dataSource.position, 9);

      dataSource.position = 5;
      expect(dataSource.readBytes(buffer), 4);
      expect(buffer.sublist(0, 4), [6, 7, 8, 9]);
    });

    test('write should output the buffer and advance position', () {
      final dataSource = AudioMemoryDataSource(buffer: []);
      expect(dataSource.length, 0);

      final writeBuffer = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(dataSource.writeBytes(writeBuffer), 9);
      expect(dataSource.position, 9);
      expect(dataSource.length, 9);

      dataSource.position = 0;

      final readBuffer = Uint8List(9);
      expect(dataSource.readBytes(readBuffer), 9);
      expect(readBuffer, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(dataSource.position, 9);
      expect(dataSource.length, 9);
    });
  });
}
