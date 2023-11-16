import 'dart:io';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';

/// An audio data source for a file.
///
/// This class implements both [AudioInputDataSource] and [AudioOutputDataSource].
class AudioFileDataSource extends SyncDisposable implements AudioInputDataSource, AudioOutputDataSource {
  /// Creates an audio data source for a file.
  ///
  /// If [cacheLength] is true, the length of the file will be cached as soon as instantiated.
  /// If [cachePosition] is true, the position of the file will be cached as soon as instantiated.
  factory AudioFileDataSource({
    required File file,
    required FileMode mode,
    bool cacheLength = true,
    bool cachePosition = true,
  }) {
    return AudioFileDataSource.fromRandomAccessFile(
      file: file.openSync(mode: mode),
      cacheLength: cacheLength,
      cachePosition: cachePosition,
    );
  }

  /// Creates an audio data source for a random access file.
  ///
  /// If [cacheLength] is true, the length of the file will be cached as soon as instantiated.
  /// If [cachePosition] is true, the position of the file will be cached as soon as instantiated.
  AudioFileDataSource.fromRandomAccessFile({
    required this.file,
    bool cacheLength = true,
    bool cachePosition = true,
  })  : _cachedLength = cacheLength ? file.lengthSync() : null,
        _cachedPosition = cachePosition ? file.positionSync() : null;
  final RandomAccessFile file;
  int? _cachedLength;
  int? _cachedPosition;

  @override
  int get length => _cachedLength ?? file.lengthSync();

  @override
  int get position => _cachedPosition ?? file.positionSync();

  @override
  set position(int newPosition) {
    file.setPositionSync(newPosition);
    if (_cachedPosition != null) {
      _cachedPosition = newPosition;
    }
  }

  @override
  bool get canSeek => true;

  var _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  int readBytes(Uint8List buffer) {
    final readCount = file.readIntoSync(buffer);
    if (_cachedPosition != null) {
      _cachedPosition = _cachedPosition! + readCount;
    }
    return readCount;
  }

  @override
  int writeBytes(Uint8List buffer) {
    file.writeFromSync(buffer);
    if (_cachedPosition != null) {
      _cachedPosition = _cachedPosition! + buffer.length;
    }
    if (_cachedLength != null) {
      _cachedLength = _cachedLength! + buffer.length;
    }
    return buffer.length;
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    file.closeSync();
  }
}
