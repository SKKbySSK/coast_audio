import 'dart:ffi';
import 'dart:io';

DynamicLibrary resolveNativeLib() {
  final libPath = Platform.environment['COAST_AUDIO_LIBRARY_PATH'];
  if (libPath == null) {
    throw Exception(
      'In order to run the tests, set the COAST_AUDIO_LIBRARY_PATH environment variable to the path of the native coast_audio library.',
    );
  }
  return DynamicLibrary.open(libPath);
}
