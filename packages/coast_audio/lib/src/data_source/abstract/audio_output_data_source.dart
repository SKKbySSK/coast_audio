import 'dart:typed_data';

/// An abstract class for audio output data sources.
abstract class AudioOutputDataSource {
  const AudioOutputDataSource();

  /// The current position of the data source.
  int get position;

  /// Sets the current position of the data source.
  set position(int newPosition);

  /// The length of the data source.
  int get length;

  /// Whether the data source supports seeking.
  ///
  /// If false, [position] cannot be set.
  bool get canSeek;

  /// Write bytes from the buffer into the data source.
  ///
  /// Returns the number of bytes written.
  int writeBytes(Uint8List buffer);
}
