import 'dart:async';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class AudioStreamDataSource extends AudioInputDataSource {
  AudioStreamDataSource({
    required this.stream,
    int position = 0,
    this.length,
  }) : _position = position;

  final Stream<List<int>> stream;
  final List<int> _buffer = [];
  StreamSubscription<List<int>>? _streamSubscription;

  void listen() {
    if (_streamSubscription != null) {
      return;
    }

    _streamSubscription = stream.listen((buffer) {
      _buffer.addAll(buffer);
    });
  }

  Future<void> cancel() async {
    await _streamSubscription?.cancel();
  }

  @override
  bool get canSeek => true;

  @override
  final int? length;

  int _position;
  @override
  int get position => _position;

  @override
  int readBytes(List<int> buffer, int offset, int count) {
    final readCount = min(count, _buffer.length - _position);
    for (var i = 0; readCount > i; i++) {
      buffer[offset + i] = _buffer[_position++];
    }
    return readCount;
  }

  @override
  void seek(int count, [SeekOrigin origin = SeekOrigin.current]) {
    switch (origin) {
      case SeekOrigin.begin:
        _position = min(count, _buffer.length);
        break;
      case SeekOrigin.current:
        _position = min(_position + count, _buffer.length);
        break;
      case SeekOrigin.end:
        if (length != null) {
          _position = min(length! + count, _buffer.length);
        } else {
          throw UnimplementedError();
        }
    }
  }
}
