import 'dart:ffi';
import 'dart:io';

import 'package:coast_audio/coast_audio.dart';

import '../internal/generated/bindings.dart';

/// A wrapper around the native coast_audio library.
class CoastAudioNative {
  const CoastAudioNative._();

  static NativeBindings? _bindings;

  /// Returns the native bindings for the native coast_audio library.
  static NativeBindings get bindings {
    final bindings = _bindings ?? initialize();
    _bindings ??= bindings;
    return bindings;
  }

  /// Initializes the native coast_audio library.
  ///
  /// If [library] is not provided, the library will be loaded from the default location for the current platform.
  /// If [ignoreVersionVerification] is `true`, the version of the loaded library will not be verified.
  static NativeBindings initialize({
    DynamicLibrary? library,
    bool ignoreVersionVerification = false,
  }) {
    final DynamicLibrary lib;
    if (library != null) {
      lib = library;
    } else if (Platform.isMacOS || Platform.isIOS) {
      lib = DynamicLibrary.process();
    } else if (Platform.isAndroid) {
      lib = DynamicLibrary.open('libcoast_audio.so');
    } else if (Platform.isLinux) {
      lib = DynamicLibrary.open('libcoast_audio.so');
    } else {
      throw const CoastAudioNativeInitializationException.unsupportedPlatform();
    }

    final bindings = NativeBindings(lib);

    final currentVersion = bindings.version;
    if (!ignoreVersionVerification && !MaVersion.supportedVersion.isSupported(currentVersion)) {
      throw CoastAudioNativeInitializationException.versionMismatch(currentVersion);
    }

    bindings.ca_dart_configure(NativeApi.postCObject.cast());
    _bindings = bindings;

    return bindings;
  }
}

/// An exception thrown when the native coast_audio library fails to initialize.
class CoastAudioNativeInitializationException implements Exception {
  const CoastAudioNativeInitializationException.unsupportedPlatform() : message = 'Unsupported platform.';
  const CoastAudioNativeInitializationException.versionMismatch(MaVersion version)
      : message = 'Unsupported version of miniaudio detected. Expected ${MaVersion.supportedVersion}^, but got $version.';
  final String message;

  @override
  String toString() {
    return 'CoastAudioNativeInitializationException: $message';
  }
}

extension NativeBindingsExtension on NativeBindings {
  MaVersion get version {
    final memory = Memory();
    final pMajor = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());
    final pMinor = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());
    final pRevision = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());

    try {
      ma_version(pMajor, pMinor, pRevision);
      return MaVersion(
        pMajor.value,
        pMinor.value,
        pRevision.value,
      );
    } finally {
      memory.allocator.free(pMajor);
      memory.allocator.free(pMinor);
      memory.allocator.free(pRevision);
    }
  }
}
