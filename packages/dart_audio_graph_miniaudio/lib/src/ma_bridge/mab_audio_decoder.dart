import 'dart:ffi';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:dart_audio_graph_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:dart_audio_graph_miniaudio/src/ma_result_extension.dart';
import 'package:ffi/ffi.dart';

class MabAudioDecoderResult {
  const MabAudioDecoderResult.success(this.maResult, this.framesRead);
  const MabAudioDecoderResult.atEnd(this.maResult, this.framesRead);
  const MabAudioDecoderResult.failed(this.maResult) : framesRead = null;

  bool get isError => framesRead == null;

  bool get isEnd => maResult.name == MaResultName.atEnd;

  final MaResult maResult;
  final int? framesRead;
}

class MabAudioDecoder extends MabBase {
  MabAudioDecoder.file({
    required this.filePath,
    required this.format,
  }) {
    final config = library.audio_decoder_config_init(format.sampleRate, format.channels);
    addPtrToDisposableBag(_pFilePath);
    library.audio_decoder_init_file(_pDecoder, _pFilePath, config).throwMaResultIfNeeded();
  }

  final String filePath;
  final AudioFormat format;

  late final _pDecoder = allocate<audio_decoder>(sizeOf<audio_decoder>());
  late final _pFilePath = filePath.toNativeUtf8().cast<Char>();
  late final _pFramesRead = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());
  late final _pCursor = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());
  late final _pLength = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());

  int get cursor {
    library.audio_decoder_get_cursor(_pDecoder, _pCursor).throwMaResultIfNeeded();
    return _pCursor.value;
  }

  set cursor(int value) {
    library.audio_decoder_set_cursor(_pDecoder, value).throwMaResultIfNeeded();
  }

  int get length {
    library.audio_decoder_get_length(_pDecoder, _pLength);
    return _pLength.value;
  }

  MabAudioDecoderResult decode(FrameBuffer buffer) {
    final result = library.audio_decoder_decode(_pDecoder, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesRead).toMaResult();
    switch (result.name) {
      case MaResultName.success:
        return MabAudioDecoderResult.success(result, _pFramesRead.value);
      case MaResultName.atEnd:
        return MabAudioDecoderResult.atEnd(result, _pFramesRead.value);
      default:
        return MabAudioDecoderResult.failed(result);
    }
  }

  @override
  void uninit() {
    library.audio_decoder_uninit(_pDecoder).throwMaResultIfNeeded();
  }
}
