import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';

class MabAudioDecoderCallback {
  MabAudioDecoderCallback(
    this.onRead,
    this.onSeek,
    this.pUserData,
    this.dataSource,
  );
  final mab_audio_decoder_read_proc onRead;
  final mab_audio_decoder_seek_proc onSeek;
  final Pointer<Void> pUserData;
  final AudioInputDataSource dataSource;
}

class MabAudioDecoderCallbackRegistry {
  MabAudioDecoderCallbackRegistry._();

  static int _onRead(Pointer<mab_audio_decoder> pDecoder, Pointer<Void> pBufferOut, int bytesToRead, Pointer<Size> pBytesRead) {
    final cb = _callbacks[pDecoder.ref.pUserData.address];
    if (cb == null) {
      return MaResultName.invalidOperation.code;
    }

    pBytesRead.value = cb.dataSource.readBytes(pBufferOut.cast<Uint8>().asTypedList(bytesToRead), 0, bytesToRead);
    return MaResultName.success.code;
  }

  static int _onSeek(Pointer<mab_audio_decoder> pDecoder, int byteOffset, int origin) {
    final cb = _callbacks[pDecoder.ref.pUserData.address];
    if (cb == null) {
      return MaResultName.invalidOperation.code;
    }

    if (!cb.dataSource.canSeek) {
      return MaResultName.notImplemented.code;
    }

    final SeekOrigin dsOrigin;
    switch (origin) {
      case mab_seek_origin.mab_seek_origin_start:
        dsOrigin = SeekOrigin.begin;
        break;
      case mab_seek_origin.mab_seek_origin_current:
        dsOrigin = SeekOrigin.current;
        break;
      case mab_seek_origin.mab_seek_origin_end:
        dsOrigin = SeekOrigin.end;
        break;
      default:
        return MaResultName.invalidOperation.code;
    }

    cb.dataSource.seek(byteOffset, dsOrigin);
    return MaResultName.success.code;
  }

  static final Map<int, MabAudioDecoderCallback> _callbacks = {};

  static MabAudioDecoderCallback registerDataSource(Pointer<mab_audio_decoder> pDecoder, AudioInputDataSource dataSource) {
    final cb = MabAudioDecoderCallback(
      Pointer.fromFunction(_onRead, 0),
      Pointer.fromFunction(_onSeek, 0),
      pDecoder.cast(),
      dataSource,
    );

    _callbacks[pDecoder.address] = cb;
    return cb;
  }

  static void unregister(Pointer<mab_audio_decoder> pDecoder) {
    _callbacks.remove(pDecoder.address);
  }
}
