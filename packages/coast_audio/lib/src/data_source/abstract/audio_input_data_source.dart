import 'dart:typed_data';

/// An abstract class for audio input data sources.
abstract class AudioInputDataSource {
  const AudioInputDataSource();

  /// The current position of the data source.
  int get position;

  /// Sets the current position of the data source.
  set position(int newPosition);

  /// The length of the data source.
  ///
  /// If the length is unknown, returns null.
  int? get length;

  /// Whether the data source supports seeking.
  ///
  /// If false, [position] cannot be set.
  bool get canSeek;

  /// Read bytes from the data source into the buffer.
  ///
  /// Returns the number of bytes read.
  int readBytes(Uint8List buffer);
}
