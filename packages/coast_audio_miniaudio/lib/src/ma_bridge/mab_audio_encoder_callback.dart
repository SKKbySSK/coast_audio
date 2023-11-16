import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:coast_audio_miniaudio/generated/ma_bridge_bindings.dart';

class MabAudioEncoderCallback {
  MabAudioEncoderCallback(
    this.onWrite,
    this.onSeek,
    this.pUserData,
    this.dataSource,
  );
  final mab_audio_encoder_write_proc onWrite;
  final mab_audio_encoder_seek_proc onSeek;
  final Pointer<Void> pUserData;
  final AudioOutputDataSource dataSource;
}

class MabAudioEncoderCallbackRegistry {
  MabAudioEncoderCallbackRegistry._();

  static int _onWrite(Pointer<mab_audio_encoder> pEncoder, Pointer<Void> pBufferIn, int bytesToWrite, Pointer<Size> pBytesWritten) {
    final cb = _callbacks[pEncoder.ref.pUserData.address];
    if (cb == null) {
      return MaResultName.invalidOperation.code;
    }

    pBytesWritten.value = cb.dataSource.writeBytes(pBufferIn.cast<Uint8>().asTypedList(bytesToWrite));
    return MaResultName.success.code;
  }

  static int _onSeek(Pointer<mab_audio_encoder> pEncoder, int byteOffset, int origin) {
    final cb = _callbacks[pEncoder.ref.pUserData.address];
    if (cb == null) {
      return MaResultName.invalidOperation.code;
    }

    if (!cb.dataSource.canSeek) {
      return MaResultName.notImplemented.code;
    }

    final int position;
    switch (origin) {
      case mab_seek_origin.mab_seek_origin_start:
        position = byteOffset;
      case mab_seek_origin.mab_seek_origin_current:
        position = cb.dataSource.position + byteOffset;
      case mab_seek_origin.mab_seek_origin_end:
        position = cb.dataSource.length + byteOffset;
      default:
        return MaResultName.invalidOperation.code;
    }

    cb.dataSource.position = position;
    return MaResultName.success.code;
  }

  static final Map<int, MabAudioEncoderCallback> _callbacks = {};

  static MabAudioEncoderCallback registerDataSource(Pointer<mab_audio_encoder> pEncoder, AudioOutputDataSource dataSource) {
    final cb = MabAudioEncoderCallback(
      Pointer.fromFunction(_onWrite, 0),
      dataSource.canSeek ? Pointer.fromFunction(_onSeek, 0) : nullptr,
      pEncoder.cast(),
      dataSource,
    );

    _callbacks[pEncoder.address] = cb;
    return cb;
  }

  static void unregister(Pointer<mab_audio_encoder> pEncoder) {
    _callbacks.remove(pEncoder.address);
  }
}
