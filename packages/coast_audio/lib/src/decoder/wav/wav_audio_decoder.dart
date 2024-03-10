import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/experimental.dart';
import 'package:coast_audio/src/ffi_extension.dart';
import 'package:coast_audio/src/codec/wav/wav_chunk.dart';

/// An audio decoder for WAV format.
///
/// This decoder supports linear PCM with 8, 16, 24, and 32 bits per sample.
/// AIFF, A-law and μ-law are not supported.
class WavAudioDecoder extends AudioDecoder {
  WavAudioDecoder._fromInfo({
    required this.dataSource,
    required this.outputFormat,
    required this.dataChunkOffset,
    required this.dataChunkLength,
    required this.bytesPerSample,
    required this.channels,
    AudioSampleConverter? converter,
  })  : _converterConfig = converter != null ? (converter, Uint8List(converter.inputBytes)) : null,
        bytesPerFrame = bytesPerSample * channels;

  /// Creates an audio decoder for WAV format.
  factory WavAudioDecoder({
    required AudioInputDataSource dataSource,
  }) {
    final memory = Memory();
    if (dataSource.canSeek) {
      dataSource.position = 0;
    }

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
        throw WavFormatException('unsupported format found in riff chunk: ${pRiffData.ref}');
      }

      while (true) {
        final byteCount = dataSource.readBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));
        if (byteCount < chunkLength) {
          throw WavFormatException('could not find the fmt chunk. invalid audio file format.');
        }

        if (pChunk.ref.id.getAsciiString(4) == 'fmt ') {
          break;
        } else if (dataSource.canSeek) {
          dataSource.position += pChunk.ref.size;
        } else {
          throw WavFormatException('could not find the fmt chunk. invalid audio file format.');
        }
      }

      dataSource.readBytes(pFmtData.cast<ffi.Uint8>().asTypedList(fmtLength));

      final fmtChunk = pFmtData.ref;
      if (fmtChunk.encodingFormat != 1 && fmtChunk.encodingFormat != 3) {
        // Linear PCM is supported.
        throw WavFormatException('unsupported encoding format found in fmt chunk: $fmtChunk');
      }

      final SampleFormat sampleFormat;
      final int bytesPerFrame;
      final AudioSampleConverter? converter;
      switch (fmtChunk.bitsPerSample) {
        case 8:
          sampleFormat = SampleFormat.uint8;
          bytesPerFrame = 1;
          converter = null;
        case 16:
          sampleFormat = SampleFormat.int16;
          bytesPerFrame = 2;
          converter = null;
        case 24:
          sampleFormat = SampleFormat.int32;
          bytesPerFrame = 3;
          converter = AudioSampleConverterInt24ToInt32();
        case 32:
          sampleFormat = SampleFormat.int32;
          bytesPerFrame = 4;
          converter = null;
        default:
          throw WavFormatException('unsupported bits per sample found in fmt chunk: $fmtChunk');
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

      return WavAudioDecoder._fromInfo(
        dataSource: dataSource,
        outputFormat: AudioFormat(
          sampleRate: fmtChunk.sampleRate,
          channels: fmtChunk.channels,
          sampleFormat: sampleFormat,
        ),
        dataChunkOffset: dataSource.position,
        dataChunkLength: pChunk.ref.size,
        bytesPerSample: bytesPerFrame,
        channels: fmtChunk.channels,
        converter: converter,
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
  final int bytesPerSample;
  final int channels;
  final int bytesPerFrame;

  final (AudioSampleConverter, Uint8List)? _converterConfig;

  @override
  final AudioFormat outputFormat;

  @override
  int get cursorInFrames {
    return (dataSource.position - dataChunkOffset) ~/ bytesPerFrame;
  }

  @override
  set cursorInFrames(int value) {
    final position = value * bytesPerFrame;
    dataSource.position = dataChunkOffset + position;
  }

  @override
  int? get lengthInFrames {
    return dataChunkLength ~/ bytesPerFrame;
  }

  @override
  bool get canSeek => true;

  @override
  AudioDecodeResult decode({required AudioBuffer destination}) {
    final converterConfig = _converterConfig;
    int totalReadBytes;
    if (converterConfig != null) {
      final (converter, converterInputBuffer) = converterConfig;
      totalReadBytes = 0;

      final sampleCount = destination.sizeInBytes ~/ converter.outputBytes;
      final outList = destination.asUint8ListViewBytes();
      for (var i = 0; i < sampleCount; i++) {
        final readBytes = dataSource.readBytes(converterInputBuffer);
        if (readBytes < converter.inputBytes) {
          break;
        }
        totalReadBytes += readBytes;
        converter.convertSample(converterInputBuffer, outList, 0, i * converter.outputBytes);
      }
    } else {
      totalReadBytes = dataSource.readBytes(destination.asUint8ListViewBytes());
    }

    return AudioDecodeResult(
      frameCount: totalReadBytes ~/ bytesPerFrame,
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
