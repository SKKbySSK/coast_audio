import 'dart:ffi';

import 'package:coast_audio/ca_device/bindings.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/library_loader.dart';
import 'package:coast_audio/src/interop/native_wrapper.dart';

class CaDeviceInterop extends NativeInterop {
  static final _bindings = CaDeviceBindings(loadLibrary('ca_device'))..ca_device_dart_configure(NativeApi.postCObject.cast());

  CaDeviceInterop({super.memory});
}

extension CaDeviceInteropExtension on CaDeviceInterop {
  CaDeviceBindings get bindings => CaDeviceInterop._bindings;
}

extension CaDeviceInteropIntExtension on int {
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

extension CaBoolExtension on bool {
  int toCaBool() {
    return this ? 1 : 0;
  }
}

extension CaFormatExtension on SampleFormat {
  int get caFormat {
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
