import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

class AudioMemoryDataSource implements AudioInputDataSource, AudioOutputDataSource {
  AudioMemoryDataSource({
    List<int>? buffer,
  }) : _buffer = buffer ?? [];

  final List<int> _buffer;
  var _position = 0;

  @override
  final canSeek = true;

  @override
  int get length => _buffer.length;

  @override
  int get position => _position;

  @override
  void seek(int count, [SeekOrigin origin = SeekOrigin.current]) {
    _position = origin.getPosition(position: _position, length: length, count: count);
  }

  @override
  int readBytes(Uint8List buffer, int offset, int count) {
    final readable = min(count, length - _position);
    for (var i = 0; readable > i; i++) {
      buffer[offset + i] = _buffer[_position + i];
    }
    _position += readable;
    return readable;
  }

  @override
  int writeBytes(Uint8List buffer, int offset, int count) {
    for (var i = 0; count > i; i++) {
      final index = _position + i;
      if (index >= _buffer.length) {
        _buffer.add(buffer[offset + i]);
      } else {
        _buffer[_position + i] = buffer[offset + i];
      }
    }
    _position += count;
    return count;
  }
}
