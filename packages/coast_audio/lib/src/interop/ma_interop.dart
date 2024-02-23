import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/generated/bindings.dart';
import 'package:coast_audio/src/interop/library_loader.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

class MaInterop extends NativeInterop {
  static final _bindings = NativeBindings(loadLibrary('miniaudio'))..ca_device_dart_configure(NativeApi.postCObject.cast());

  MaInterop({super.memory});
}

extension MaInteropExtension on MaInterop {
  NativeBindings get bindings => MaInterop._bindings;
}

extension MaIntExtension on int {
  void throwMaResultIfNeeded() {
    toMaResult().throwIfNeeded();
  }

  MaResult toMaResult() {
    return MaResult.values.firstWhere((r) => r.code == this);
  }

  bool toBool() {
    return this == 1;
  }
}

extension MaBoolExtension on bool {
  int toMaBool() {
    return this ? 1 : 0;
  }
}

extension MaFormatExtension on SampleFormat {
  int get maFormat {
    switch (this) {
      case SampleFormat.uint8:
        return ca_format.ca_format_u8;
      case SampleFormat.int16:
        return ca_format.ca_format_s16;
      case SampleFormat.int32:
        return ca_format.ca_format_s32;
      case SampleFormat.float32:
        return ca_format.ca_format_f32;
    }
  }
}
