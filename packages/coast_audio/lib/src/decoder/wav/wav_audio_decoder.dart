import 'dart:ffi' as ffi;

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio/src/codec/wav/wav_chunk.dart';

class WavAudioDecoder extends AudioDecoder {
  WavAudioDecoder.fromInfo({
    required this.dataSource,
    required this.outputFormat,
    required this.dataChunkOffset,
    required this.dataChunkLength,
    Memory? memory,
  }) : memory = memory ?? Memory();

  factory WavAudioDecoder({
    required AudioInputDataSource dataSource,
    Memory? memory,
  }) {
    final mem = memory ?? Memory();
    dataSource.seek(0, SeekOrigin.begin);

    final chunkLength = ffi.sizeOf<WavChunk>();
    final pChunk = mem.allocator.allocate<WavChunk>(chunkLength);

    final riffLength = ffi.sizeOf<WavRiffData>();
    final pRiffData = mem.allocator.allocate<WavRiffData>(riffLength);

    final fmtLength = ffi.sizeOf<WavFmtData>();
    final pFmtData = mem.allocator.allocate<WavFmtData>(fmtLength);

    try {
      dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);
      dataSource.readBytes(pRiffData.cast<ffi.Uint8>().asTypedList(riffLength), 0, riffLength);

      final riffFormat = pRiffData.ref.format.getString(4);
      if (riffFormat != 'WAVE') {
        throw WavFormatException('unsupported format found in riff chunk: $riffFormat');
      }

      dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);
      dataSource.readBytes(pFmtData.cast<ffi.Uint8>().asTypedList(fmtLength), 0, fmtLength);

      final fmtChunk = pFmtData.ref;
      if (fmtChunk.encodingFormat != 1 && fmtChunk.encodingFormat != 3) {
        // Linear PCM is supported.
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
        default:
          throw WavFormatException('unsupported bits per sample found in fmt chunk: ${fmtChunk.bitsPerSample}');
      }

      while (true) {
        final read = dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);
        if (read < 4) {
          throw WavFormatException('could not find the data chunk');
        }

        if (pChunk.ref.id.getString(4) == 'data') {
          break;
        } else {
          dataSource.seek(pChunk.ref.size);
        }
      }

      return WavAudioDecoder.fromInfo(
        dataSource: dataSource,
        outputFormat: AudioFormat(
          sampleRate: fmtChunk.sampleRate,
          channels: fmtChunk.channels,
          sampleFormat: sampleFormat,
        ),
        dataChunkOffset: dataSource.position,
        dataChunkLength: pChunk.ref.size,
        memory: mem,
      );
    } finally {
      mem.allocator.free(pChunk);
      mem.allocator.free(pRiffData);
      mem.allocator.free(pFmtData);
    }
  }

  final Memory memory;
  final AudioInputDataSource dataSource;
  final int dataChunkOffset;
  final int dataChunkLength;

  @override
  final AudioFormat outputFormat;

  @override
  int get cursorInFrames {
    return (dataSource.position - dataChunkOffset) ~/ outputFormat.bytesPerFrame;
  }

  @override
  set cursorInFrames(int value) {
    final position = value * outputFormat.bytesPerFrame;
    dataSource.seek(dataChunkOffset + position, SeekOrigin.begin);
  }

  @override
  int? get lengthInFrames {
    return dataChunkLength ~/ outputFormat.bytesPerFrame;
  }

  @override
  bool get canSeek => true;

  @override
  AudioDecodeResult decode({required AudioBuffer destination}) {
    final readBytes = dataSource.readBytes(destination.asUint8ListViewBytes(), 0, destination.sizeInBytes);
    return AudioDecodeResult(
      frames: readBytes ~/ outputFormat.bytesPerFrame,
      isEnd: cursorInFrames == lengthInFrames,
    );
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
