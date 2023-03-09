import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

extension MaResultExtension on int {
  void throwMaResultIfNeeded() {
    MaResult(this).throwIfNeeded();
  }

  MaResult toMaResult() {
    return MaResult(this);
  }

  bool toBool() {
    return this == 1;
  }
}

extension MabBoolExtension on bool {
  int toMabBool() {
    return this ? 1 : 0;
  }
}

extension MabFormatExtension on SampleFormat {
  MabFormat get mabFormat {
    switch (this) {
      case SampleFormat.uint8:
        return MabFormat.uint8;
      case SampleFormat.int16:
        return MabFormat.int16;
      case SampleFormat.int32:
        return MabFormat.int32;
      case SampleFormat.float32:
        return MabFormat.float32;
    }
  }
}
