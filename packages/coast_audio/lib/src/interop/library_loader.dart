import 'dart:ffi';
import 'dart:io';

DynamicLibrary loadLibrary(String name) {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$name.framework/$name');
  }

  return DynamicLibrary.open('lib$name.so');
}
