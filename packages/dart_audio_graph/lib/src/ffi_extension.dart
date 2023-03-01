import 'dart:ffi';

extension ArrayCharExtension on Array<Char> {
  String getString(int length) {
    var value = '';
    for (var i = 0; length > i; i++) {
      value += String.fromCharCode(this[i]);
    }
    return value;
  }

  void setString(String value) {
    for (var i = 0; value.codeUnits.length > i; i++) {
      this[i] = value.codeUnits[i];
    }
  }
}
