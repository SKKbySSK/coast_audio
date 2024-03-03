import 'dart:ffi' as ffi;

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio/src/codec/wav/wav_chunk.dart';

/// An audio decoder for WAV format.
class WavAudioDecoder extends AudioDecoder {
  WavAudioDecoder.fromInfo({
    required this.dataSource,
    required this.outputFormat,
    required this.dataChunkOffset,
    required this.dataChunkLength,
  });

  /// Creates an audio decoder for WAV format.
  factory WavAudioDecoder({
    required AudioInputDataSource dataSource,
  }) {
    final memory = Memory();
    dataSource.position = 0;

    final chunkLength = ffi.sizeOf<WavChunk>();
    final pChunk = memory.allocator.allocate<WavChunk>(chunkLength);

    final riffLength = ffi.sizeOf<WavRiffData>();
    final pRiffData = memory.allocator.allocate<WavRiffData>(riffLength);

    final fmtLength = ffi.sizeOf<WavFmtData>();
    final pFmtData = memory.allocator.allocate<WavFmtData>(fmtLength);

    try {
      dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));
      dataSource.readBytes(pRiffData.cast<ffi.Uint8>().asTypedList(riffLength));

      final riffFormat = pRiffData.ref.format.getAsciiString(4);
      if (riffFormat != 'WAVE') {
        throw WavFormatException('unsupported format found in riff chunk: $riffFormat');
      }

      dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));
      dataSource.readBytes(pFmtData.cast<ffi.Uint8>().asTypedList(fmtLength));

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
        final read = dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));
        if (read < 4) {
          throw WavFormatException('could not find the data chunk');
        }

        if (pChunk.ref.id.getAsciiString(4) == 'data') {
          break;
        } else {
          dataSource.position += pChunk.ref.size;
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
      );
    } finally {
      memory.allocator.free(pChunk);
      memory.allocator.free(pRiffData);
      memory.allocator.free(pFmtData);
    }
  }

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
    dataSource.position = dataChunkOffset + position;
  }

  @override
  int? get lengthInFrames {
    return dataChunkLength ~/ outputFormat.bytesPerFrame;
  }

  @override
  bool get canSeek => true;

  @override
  AudioDecodeResult decode({required AudioBuffer destination}) {
    final readBytes = dataSource.readBytes(destination.asUint8ListViewBytes());
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
