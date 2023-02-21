import 'dart:ffi' as ffi;

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph/src/decoder/wav/wav_chunk.dart';
import 'package:ffi/ffi.dart';

class WavAudioDecoder extends AudioDecoder {
  WavAudioDecoder({
    Memory? memory,
    required this.dataSource,
    required this.format,
    required this.dataChunkOffset,
    required this.dataChunkLength,
  }) : memory = memory ?? Memory();

  final Memory memory;
  final AudioDataSource dataSource;
  final int dataChunkOffset;
  final int dataChunkLength;

  @override
  final AudioFormat format;

  @override
  int get position {
    return (dataSource.position - dataChunkOffset) ~/ format.bytesPerFrame;
  }

  @override
  set position(int value) {
    final position = value * format.bytesPerFrame;
    dataSource.seekSync(dataChunkOffset + position, SeekOrigin.begin);
  }

  @override
  int get length {
    return dataChunkLength ~/ format.bytesPerFrame;
  }

  static Future<WavAudioDecoder> open({
    required AudioDataSource dataSource,
    Memory? memory,
  }) async {
    final mem = memory ?? Memory();
    await dataSource.seek(0, SeekOrigin.begin);

    final riffLength = ffi.sizeOf<WavRiffChunk>();
    final pRiffChunk = mem.allocator.allocate<WavRiffChunk>(riffLength);

    final fmtLength = ffi.sizeOf<WavFmtChunk>();
    final pFmtChunk = mem.allocator.allocate<WavFmtChunk>(fmtLength);

    final dataLength = ffi.sizeOf<WavCommonChunk>();
    final pDataChunk = mem.allocator.allocate<WavCommonChunk>(dataLength);

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

      return WavAudioDecoder(
        dataSource: dataSource,
        format: AudioFormat(
          sampleRate: fmtChunk.sampleRate,
          channels: fmtChunk.channels,
          sampleFormat: sampleFormat,
        ),
        dataChunkOffset: dataSource.position,
        dataChunkLength: pDataChunk.ref.size,
      );
    } finally {
      mem.allocator.free(pRiffChunk);
      mem.allocator.free(pFmtChunk);
      mem.allocator.free(pDataChunk);
    }
  }

  @override
  int decode(RawFrameBuffer buffer) {
    final readBytes = dataSource.readBytesSync(buffer.asUint8ListViewBytes(), 0, buffer.sizeInBytes);
    return readBytes ~/ format.bytesPerFrame;
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
