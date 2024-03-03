import 'dart:ffi' as ffi;

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/ffi_extension.dart';
import 'package:coast_audio/src/codec/wav/wav_chunk.dart';

class WavAudioEncoder extends AudioEncoder {
  WavAudioEncoder({
    required this.dataSource,
    required this.inputFormat,
    Memory? memory,
  }) : memory = memory ?? Memory();
  final AudioOutputDataSource dataSource;

  final Memory memory;

  @override
  final AudioFormat inputFormat;

  int get _riffSizeOffset => 4;

  int get _dataSizeOffset {
    final chunkLength = ffi.sizeOf<WavChunk>();
    final riffLength = ffi.sizeOf<WavRiffData>();
    final fmtLength = ffi.sizeOf<WavFmtData>();

    return (chunkLength * 2) + riffLength + fmtLength + 4;
  }

  @override
  void start() {
    final chunkLength = ffi.sizeOf<WavChunk>();
    final pChunk = memory.allocator.allocate<WavChunk>(chunkLength);

    final riffLength = ffi.sizeOf<WavRiffData>();
    final pRiffData = memory.allocator.allocate<WavRiffData>(riffLength);

    final fmtLength = ffi.sizeOf<WavFmtData>();
    final pFmtData = memory.allocator.allocate<WavFmtData>(fmtLength);

    try {
      dataSource.position = 0;

      {
        pChunk.ref.id.setAsciiString('RIFF');
        pChunk.ref.size = 0;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));

        pRiffData.ref.format.setAsciiString('WAVE');
        dataSource.writeBytes(pRiffData.cast<ffi.Uint8>().asTypedList(riffLength));
      }

      {
        pChunk.ref.id.setAsciiString('fmt ');
        pChunk.ref.size = fmtLength;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));

        switch (inputFormat.sampleFormat) {
          case SampleFormat.uint8:
          case SampleFormat.int16:
            pFmtData.ref.encodingFormat = 1;
            break;
          default:
            throw WavFormatException('unsupported sample format');
        }

        pFmtData.ref.channels = inputFormat.channels;
        pFmtData.ref.sampleRate = inputFormat.sampleRate;
        pFmtData.ref.bytesPerSecond = inputFormat.sampleRate * inputFormat.channels * inputFormat.sampleFormat.size;
        pFmtData.ref.bytesPerFrame = inputFormat.bytesPerFrame;
        pFmtData.ref.bitsPerSample = inputFormat.sampleFormat.size * 8;
        dataSource.writeBytes(pFmtData.cast<ffi.Uint8>().asTypedList(fmtLength));
      }

      {
        pChunk.ref.id.setAsciiString('data');
        pChunk.ref.size = 0;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength));
      }
    } finally {
      memory.allocator.free(pChunk);
      memory.allocator.free(pRiffData);
      memory.allocator.free(pFmtData);
    }
  }

  @override
  AudioEncodeResult encode(AudioBuffer buffer) {
    final list = buffer.asUint8ListViewBytes();
    return AudioEncodeResult(
      frames: dataSource.writeBytes(list) ~/ inputFormat.bytesPerFrame,
    );
  }

  @override
  void finalize() {
    final pInt = memory.allocator.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    try {
      dataSource.position = _riffSizeOffset;
      pInt.value = dataSource.length - _riffSizeOffset;
      dataSource.writeBytes(pInt.cast<ffi.Uint8>().asTypedList(4));

      dataSource.position = _dataSizeOffset;
      pInt.value = dataSource.length - _dataSizeOffset;
      dataSource.writeBytes(pInt.cast<ffi.Uint8>().asTypedList(4));
    } finally {
      memory.allocator.free(pInt);
    }
  }
}
