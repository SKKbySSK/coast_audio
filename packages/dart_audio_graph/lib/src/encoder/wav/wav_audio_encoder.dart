import 'dart:ffi' as ffi;

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph/src/codec/wav/wav_chunk.dart';
import 'package:dart_audio_graph/ffi_extension.dart';

class WavAudioEncoder extends AudioEncoder {
  WavAudioEncoder({
    required this.dataSource,
    required this.format,
    Memory? memory,
  }) : memory = memory ?? Memory();
  final AudioOutputDataSource dataSource;
  final AudioFormat format;
  final Memory memory;

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
      dataSource.seek(0, SeekOrigin.begin);

      {
        pChunk.ref.id.setString('RIFF');
        pChunk.ref.size = 0;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);

        pRiffData.ref.format.setString('WAVE');
        dataSource.writeBytes(pRiffData.cast<ffi.Uint8>().asTypedList(riffLength), 0, riffLength);
      }

      {
        pChunk.ref.id.setString('fmt ');
        pChunk.ref.size = fmtLength;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);

        switch (format.sampleFormat) {
          case SampleFormat.uint8:
          case SampleFormat.int16:
          case SampleFormat.int32:
            pFmtData.ref.encodingFormat = 1;
            break;
          case SampleFormat.float32:
            pFmtData.ref.encodingFormat = 3;
            break;
        }
        pFmtData.ref.channels = format.channels;
        pFmtData.ref.sampleRate = format.sampleRate;
        pFmtData.ref.bytesPerSecond = format.sampleRate * format.channels * format.sampleFormat.size;
        pFmtData.ref.bytesPerFrame = format.bytesPerFrame;
        pFmtData.ref.bitsPerSample = format.sampleFormat.size * 8;
        dataSource.writeBytes(pFmtData.cast<ffi.Uint8>().asTypedList(fmtLength), 0, fmtLength);
      }

      {
        pChunk.ref.id.setString('data');
        pChunk.ref.size = 0;
        dataSource.writeBytes(pChunk.cast<ffi.Uint8>().asTypedList(chunkLength), 0, chunkLength);
      }
    } finally {
      memory.allocator.free(pChunk);
      memory.allocator.free(pRiffData);
      memory.allocator.free(pFmtData);
    }
  }

  @override
  int encode(RawFrameBuffer buffer) {
    final list = buffer.asUint8ListViewBytes();
    return dataSource.writeBytes(list, 0, list.length) ~/ format.bytesPerFrame;
  }

  @override
  void stop() {
    final pInt = memory.allocator.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    try {
      dataSource.seek(_riffSizeOffset, SeekOrigin.begin);
      pInt.value = dataSource.length - _riffSizeOffset;
      dataSource.writeBytes(pInt.cast<ffi.Uint8>().asTypedList(4), 0, 4);

      dataSource.seek(_dataSizeOffset, SeekOrigin.begin);
      pInt.value = dataSource.length - _dataSizeOffset;
      dataSource.writeBytes(pInt.cast<ffi.Uint8>().asTypedList(4), 0, 4);
    } finally {
      memory.allocator.free(pInt);
    }
  }
}
