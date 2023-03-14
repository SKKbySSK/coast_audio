import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';
import 'package:ffi/ffi.dart';

class MabAudioDecoderInfo {
  const MabAudioDecoderInfo(
    this.format,
    this.sampleRate,
    this.channels,
    this.length,
  );
  final MabFormat format;
  final int sampleRate;
  final int channels;
  final int length;

  /// Convert the decoder info to coast_audio's [AudioFormat].
  AudioFormat? toAudioFormat() {
    final sampleFormat = format.sampleFormat;
    if (sampleFormat == null) {
      return null;
    }

    return AudioFormat(
      sampleRate: sampleRate,
      channels: channels,
      sampleFormat: sampleFormat,
    );
  }
}

class MabAudioDecoder extends MabBase implements AudioDecoder {
  /// Get the information of the audio file.
  static MabAudioDecoderInfo getInfo(String filePath) {
    final pFilePath = filePath.toNativeUtf8();
    final pFormat = malloc.allocate<mab_audio_decoder_info>(sizeOf<mab_audio_decoder_info>());
    try {
      MabLibrary.library.mab_audio_decoder_get_info(pFilePath.cast(), pFormat).throwMaResultIfNeeded();
      return MabAudioDecoderInfo(
        MabFormat.values.firstWhere((f) => f.value == pFormat.ref.format),
        pFormat.ref.sampleRate,
        pFormat.ref.channels,
        pFormat.ref.length,
      );
    } finally {
      malloc.free(pFilePath);
      malloc.free(pFormat);
    }
  }

  /// Initialize the [MabAudioDecoder] instance by opening [filePath].
  /// If an opened file's format is not same as [format], miniaudio will convert it automatically.
  MabAudioDecoder.file({
    required this.filePath,
    required this.format,
    Memory? memory,
    MabDitherMode ditherMode = MabDitherMode.none,
    MabChannelMixMode channelMixMode = MabChannelMixMode.rectangular,
  }) : super(memory: memory) {
    final config = library.mab_audio_decoder_config_init(
      format.sampleFormat.mabFormat.value,
      format.sampleRate,
      format.channels,
    );
    config.ditherMode = ditherMode.value;
    config.channelMixMode = channelMixMode.value;

    addPtrToDisposableBag(_pFilePath);
    library.mab_audio_decoder_init_file(_pDecoder, _pFilePath, config).throwMaResultIfNeeded();
  }

  final String filePath;

  @override
  final AudioFormat format;

  late final _pDecoder = allocate<mab_audio_decoder>(sizeOf<mab_audio_decoder>());
  late final _pFilePath = filePath.toNativeUtf8(allocator: memory.allocator).cast<Char>();
  late final _pFramesRead = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());

  var _cachedCursor = 0;
  int? _cachedLength;
  var _cursorChanged = false;

  @override
  int get cursor => _cachedCursor;

  @override
  set cursor(int value) {
    _cachedCursor = value;
    _cursorChanged = true;
  }

  @override
  int get length {
    if (_cachedLength != null) {
      return _cachedLength!;
    }

    final pLength = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());
    library.mab_audio_decoder_get_length(_pDecoder, pLength).throwMaResultIfNeeded();
    _cachedLength = pLength.value;
    return pLength.value;
  }

  void flushCursor() {
    if (_cursorChanged) {
      library.mab_audio_decoder_set_cursor(_pDecoder, cursor).throwMaResultIfNeeded();
      _cursorChanged = false;
    }
  }

  @override
  AudioDecodeResult decode({required RawFrameBuffer destination}) {
    flushCursor();
    final result = library.mab_audio_decoder_decode(_pDecoder, destination.pBuffer.cast(), destination.sizeInFrames, _pFramesRead).toMaResult();
    switch (result.name) {
      case MaResultName.success:
        _cachedCursor += _pFramesRead.value;
        return AudioDecodeResult(frames: _pFramesRead.value, isEnd: false);
      case MaResultName.atEnd:
        _cachedCursor += _pFramesRead.value;
        return AudioDecodeResult(frames: _pFramesRead.value, isEnd: true);
      default:
        throw MaResultException(result);
    }
  }

  @override
  void uninit() {
    library.mab_audio_decoder_uninit(_pDecoder).throwMaResultIfNeeded();
  }
}
