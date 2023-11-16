import 'dart:ffi' as ffi;

final class WavChunk extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> id;

  @ffi.Int32()
  external int size;
}

final class WavRiffData extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> format;
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
}
