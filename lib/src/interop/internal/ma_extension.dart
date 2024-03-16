import 'package:coast_audio/coast_audio.dart';

import 'generated/bindings.dart';

extension IntExtension on int {
  void throwMaResultIfNeeded() {
    asMaResult().throwIfNeeded();
  }

  MaResult asMaResult() {
    return MaResult.values.firstWhere((r) => r.code == this);
  }

  bool asMaBool() {
    return this == 1;
  }

  SampleFormat asSampleFormat() {
    return SampleFormat.values.firstWhere((r) => r.maFormat == this, orElse: () => throw Exception('Unsupported ma_format: $this'));
  }

  T whenSeekOrigin<T>({
    required T Function() current,
    required T Function() start,
    required T Function() end,
  }) {
    switch (this) {
      case ma_seek_origin.ma_seek_origin_current:
        return current();
      case ma_seek_origin.ma_seek_origin_start:
        return start();
      case ma_seek_origin.ma_seek_origin_end:
        return end();
      default:
        throw ArgumentError.value(this, 'seekOrigin');
    }
  }
}

extension BoolExtension on bool {
  int toMaBool() {
    return this ? 1 : 0;
  }
}

extension SampleFormatExtension on SampleFormat {
  int get maFormat {
    switch (this) {
      case SampleFormat.uint8:
        return ma_format.ma_format_u8;
      case SampleFormat.int16:
        return ma_format.ma_format_s16;
      case SampleFormat.int32:
        return ma_format.ma_format_s32;
      case SampleFormat.float32:
        return ma_format.ma_format_f32;
    }
  }
}
