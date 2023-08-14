import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';
import 'package:coast_audio_miniaudio/src/ma_bridge/mab_audio_encoder_callback.dart';
import 'package:coast_audio_miniaudio/src/ma_extension.dart';
import 'package:ffi/ffi.dart';

class MabAudioEncoder extends AudioEncoder {
  MabAudioEncoder({
    required AudioOutputDataSource dataSource,
    required this.encodingFormat,
    required this.inputFormat,
    Memory? memory,
  })  : memory = memory ?? FfiMemory(),
        _filePath = null,
        _dataSource = dataSource;

  MabAudioEncoder.file({
    required String filePath,
    required this.encodingFormat,
    required this.inputFormat,
    Memory? memory,
  })  : memory = memory ?? FfiMemory(),
        _filePath = filePath,
        _dataSource = null;

  final MabEncodingFormat encodingFormat;

  final Memory memory;

  @override
  final AudioFormat inputFormat;

  final String? _filePath;
  final AudioOutputDataSource? _dataSource;
  _MabAudioEncoder? _encoder;

  @override
  void start() {
    finalize();

    final filePath = _filePath;
    if (filePath == null) {
      _encoder = _MabAudioEncoder(dataSource: _dataSource!, encodingFormat: encodingFormat, inputFormat: inputFormat, memory: memory);
    } else {
      _encoder = _MabAudioEncoder.file(filePath: filePath, encodingFormat: encodingFormat, inputFormat: inputFormat, memory: memory);
    }
  }

  @override
  AudioEncodeResult encode(AudioBuffer buffer) {
    return _encoder!.encode(buffer);
  }

  @override
  void finalize() {
    _encoder?.dispose();
    _encoder = null;
  }
}

class _MabAudioEncoder extends MabBase {
  _MabAudioEncoder({
    required AudioOutputDataSource dataSource,
    required this.encodingFormat,
    required this.inputFormat,
    super.memory,
  }) {
    final config = library.mab_audio_encoder_config_init(
      encodingFormat.value,
      inputFormat.sampleFormat.mabFormat.value,
      inputFormat.sampleRate,
      inputFormat.channels,
    );

    final callback = MabAudioEncoderCallbackRegistry.registerDataSource(_pEncoder, dataSource);
    library.mab_audio_encoder_init(_pEncoder, config, callback.onWrite, callback.onSeek, callback.pUserData).throwMaResultIfNeeded();
  }

  _MabAudioEncoder.file({
    required String filePath,
    required this.encodingFormat,
    required this.inputFormat,
    super.memory,
  }) {
    final config = library.mab_audio_encoder_config_init(
      encodingFormat.value,
      inputFormat.sampleFormat.mabFormat.value,
      inputFormat.sampleRate,
      inputFormat.channels,
    );

    final pFilePath = filePath.toNativeUtf8(allocator: memory.allocator).cast<Char>();
    addPtrToDisposableBag(pFilePath);
    library.mab_audio_encoder_init_file(_pEncoder, pFilePath, config).throwMaResultIfNeeded();
  }

  @override
  final AudioFormat inputFormat;

  final MabEncodingFormat encodingFormat;

  late final _pEncoder = allocate<mab_audio_encoder>(sizeOf<mab_audio_encoder>());
  late final _pFramesWrite = allocate<UnsignedLongLong>(sizeOf<UnsignedLongLong>());

  AudioEncodeResult encode(AudioBuffer buffer) {
    _pFramesWrite.value = buffer.sizeInFrames;
    library.mab_audio_encoder_encode(_pEncoder, buffer.pBuffer.cast(), buffer.sizeInFrames, _pFramesWrite).throwMaResultIfNeeded();
    return AudioEncodeResult(frames: _pFramesWrite.value);
  }

  @override
  void uninit() {
    library.mab_audio_encoder_uninit(_pEncoder);
    MabAudioEncoderCallbackRegistry.unregister(_pEncoder);
  }
}
