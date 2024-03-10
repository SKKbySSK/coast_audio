import 'dart:ffi' as ffi;

import 'package:coast_audio/ffi_extension.dart';

final class WavChunk extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> id;

  @ffi.Int32()
  external int size;

  @override
  String toString() {
    return 'WavChunk{id: ${id.getAsciiString(4)}, size: $size}';
  }
}

final class WavRiffData extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> format;

  @override
  String toString() {
    return 'WavRiffData{format: ${format.getAsciiString(4)}}';
  }
}

final class WavFmtData extends ffi.Struct {
  @ffi.Int16()
  external int encodingFormat;

  @ffi.Int16()
  external int channels;

  @ffi.Int32()
  external int sampleRate;

  @ffi.Int32()
  external int bytesPerSecond;

  @ffi.Int16()
  external int bytesPerFrame;

  @ffi.Int16()
  external int bitsPerSample;

  @override
  String toString() {
    return 'WavFmtData{encodingFormat: $encodingFormat, channels: $channels, sampleRate: $sampleRate, bytesPerSecond: $bytesPerSecond, bytesPerFrame: $bytesPerFrame, bitsPerSample: $bitsPerSample}';
  }
}
