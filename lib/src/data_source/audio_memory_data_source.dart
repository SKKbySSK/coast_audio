import 'dart:math';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

/// An audio data source for a memory buffer.
///
/// This class implements both [AudioInputDataSource] and [AudioOutputDataSource].
class AudioMemoryDataSource implements AudioInputDataSource, AudioOutputDataSource {
  /// Creates an audio data source for a memory buffer.
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
  set position(int newPosition) {
    _position = newPosition;
  }

  @override
  int readBytes(Uint8List buffer) {
    final readable = min(buffer.length, length - _position);
    for (var i = 0; readable > i; i++) {
      buffer[i] = _buffer[_position + i];
    }
    _position += readable;
    return readable;
  }

  @override
  int writeBytes(Uint8List buffer) {
    for (var i = 0; buffer.length > i; i++) {
      final index = _position + i;
      if (index >= _buffer.length) {
        _buffer.add(buffer[i]);
      } else {
        _buffer[_position + i] = buffer[i];
      }
    }
    _position += buffer.length;
    return buffer.length;
  }
}
