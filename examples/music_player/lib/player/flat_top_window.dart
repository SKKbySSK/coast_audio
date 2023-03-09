import 'dart:math';
import 'dart:typed_data';

Float64List getFlatTopWindow(int chunkSize) {
  final window = Float64List(chunkSize);
  final coef = 2 * pi / chunkSize;
  for (var i = 0; chunkSize > i; i++) {
    window[i] = 0.2156 - (0.4166 * cos(coef * i)) + (0.2773 * sin(2 * coef * i)) - (0.0836 * cos(3 * coef * i)) + (0.0069 * sin(4 * coef * i));
  }
  return window;
}
