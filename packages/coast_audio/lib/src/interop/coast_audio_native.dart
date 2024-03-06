import 'dart:ffi';
import 'dart:io';

import 'package:coast_audio/coast_audio.dart';

import 'generated/bindings.dart';

const _maMajor = 0;
const _maMinor = 11;
const _maRevision = 21;

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
      lib = DynamicLibrary.open('coast_audio.framework/coast_audio');
    } else if (Platform.isAndroid || Platform.isLinux) {
      lib = DynamicLibrary.open('libcoast_audio.so');
    } else {
      throw const CoastAudioNativeInitializationException.unsupportedPlatform();
    }

    return _initializeBindings(
      library: lib,
      ignoreVersionVerification: ignoreVersionVerification,
    );
  }

  static NativeBindings _initializeBindings({
    required DynamicLibrary library,
    required bool ignoreVersionVerification,
  }) {
    final bindings = NativeBindings(library);
    if (!ignoreVersionVerification && !bindings.isSupportedVersion) {
      final (major, minor, revision) = bindings.version;
      throw CoastAudioNativeInitializationException.versionMismatch(major, minor, revision);
    }

    bindings.ca_device_dart_configure(NativeApi.postCObject.cast());
    return bindings;
  }
}

/// An exception thrown when the native coast_audio library fails to initialize.
class CoastAudioNativeInitializationException implements Exception {
  const CoastAudioNativeInitializationException.unsupportedPlatform() : message = 'Unsupported platform.';
  const CoastAudioNativeInitializationException.versionMismatch(int major, int minor, int revision) : message = 'Unsupported version of miniaudio. Expected $_maMajor.$_maMinor.$_maRevision^, but got $major.$minor.$revision.';
  final String message;

  @override
  String toString() {
    return 'CoastAudioNativeInitializationException: $message';
  }
}

extension _NativeBindings on NativeBindings {
  bool get isSupportedVersion {
    final (major, minor, revision) = version;
    return major == _maMajor && minor >= _maMinor && revision >= _maRevision;
  }

  (int, int, int) get version {
    final memory = Memory();
    final pMajor = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());
    final pMinor = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());
    final pRevision = memory.allocator.allocate<UnsignedInt>(sizeOf<UnsignedInt>());

    try {
      ma_version(pMajor, pMinor, pRevision);
      return (pMajor.value, pMinor.value, pRevision.value);
    } finally {
      memory.allocator.free(pMajor);
      memory.allocator.free(pMinor);
      memory.allocator.free(pRevision);
    }
  }
}
