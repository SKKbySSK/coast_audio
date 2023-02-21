import 'dart:ffi' as ffi;

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:ffi/ffi.dart';

class _WavInfo {
  const _WavInfo(this.dataSource, this.format, this.offset, this.length);
  final AudioDataSource dataSource;
  final AudioFormat format;
  final int offset;
  final int length;
}

class WavAudioDecoder extends AudioDecoder {
  WavAudioDecoder({
    Memory? memory,
  }) : memory = memory ?? Memory();

  final Memory memory;

  _WavInfo? _info;

  @override
  bool get isReady => _info != null;

  @override
  AudioFormat? get format => _info?.format;

  @override
  int? get position {
    if (!isReady) {
      return null;
    }

    return (_info!.dataSource.position - _info!.offset) ~/ _info!.format.bytesPerFrame;
  }

  @override
  int? get length {
    if (!isReady) {
      return null;
    }

    return _info!.length ~/ _info!.format.bytesPerFrame;
  }

  @override
  Future<void> open({required AudioDataSource dataSource}) async {
    await dataSource.seek(0, SeekOrigin.begin);

    final riffLength = ffi.sizeOf<WavRiffChunk>();
    final pRiffChunk = memory.allocator.allocate<WavRiffChunk>(riffLength);

    final fmtLength = ffi.sizeOf<WavFmtChunk>();
    final pFmtChunk = memory.allocator.allocate<WavFmtChunk>(fmtLength);

    final dataLength = ffi.sizeOf<WavCommonChunk>();
    final pDataChunk = memory.allocator.allocate<WavCommonChunk>(dataLength);

    try {
      await dataSource.readBytes(pRiffChunk.cast<ffi.Uint8>().asTypedList(riffLength), 0, riffLength);
      await dataSource.readBytes(pFmtChunk.cast<ffi.Uint8>().asTypedList(fmtLength), 0, fmtLength);

      final riffFormat = pRiffChunk.cast<ffi.Char>().elementAt(8).cast<Utf8>().toDartString(length: 4);
      if (riffFormat != 'WAVE') {
        throw WavFormatException('unsupported format found in riff chunk: $riffFormat');
      }

      final fmtChunk = pFmtChunk.ref;
      if (fmtChunk.encodingFormat != 1 && fmtChunk.encodingFormat != 3) {
        // Linear PCM & IEEE Float PCM is supported.
        throw WavFormatException('unsupported encoding format found in fmt chunk: ${fmtChunk.encodingFormat}');
      }

      final SampleFormat sampleFormat;
      switch (fmtChunk.bitsPerSample) {
        case 8:
          sampleFormat = SampleFormat.uint8;
          break;
        case 16:
          sampleFormat = SampleFormat.int16;
          break;
        case 32:
          sampleFormat = SampleFormat.float32;
          break;
        default:
          throw WavFormatException('unsupported bits per sample found in fmt chunk: ${fmtChunk.bitsPerSample}');
      }

      while (true) {
        final read = await dataSource.readBytes(pDataChunk.cast<ffi.Uint8>().asTypedList(dataLength), 0, dataLength);
        if (read < 4) {
          throw WavFormatException('could not find the data chunk');
        }

        if (pDataChunk.cast<Utf8>().toDartString(length: 4) == 'data') {
          break;
        } else {
          await dataSource.seek(pDataChunk.ref.size);
        }
      }

      _info = _WavInfo(
        dataSource,
        AudioFormat(
          sampleRate: fmtChunk.sampleRate,
          channels: fmtChunk.channels,
          sampleFormat: sampleFormat,
        ),
        dataSource.position,
        pDataChunk.ref.size,
      );
    } finally {
      memory.allocator.free(pRiffChunk);
      memory.allocator.free(pFmtChunk);
      memory.allocator.free(pDataChunk);
    }
  }

  @override
  Future<void> close() async {
    _info = null;
  }

  @override
  int decode(RawFrameBuffer buffer) {
    final readBytes = _info!.dataSource.readBytesSync(buffer.asUint8ListViewBytes(), 0, buffer.sizeInBytes);
    return readBytes ~/ _info!.format.bytesPerFrame;
  }
}

class WavFormatException implements Exception {
  const WavFormatException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

class WavRiffChunk extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> id;

  @ffi.Int32()
  external int size;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> format;
}

class WavFmtChunk extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> id;

  @ffi.Int32()
  external int size;

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

class WavCommonChunk extends ffi.Struct {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> id;

  @ffi.Int32()
  external int size;
}
