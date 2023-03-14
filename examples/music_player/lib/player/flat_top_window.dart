import 'dart:math';
import 'dart:typed_data';

Float64List getFlatTopWindow(int chunkSize) {
  final window = Float64List(chunkSize);
  final coef = 2 * pi / chunkSize;
  for (var i = 0; chunkSize > i; i++) {
    window[i] = 0.21557895 - (0.41663158 * cos(coef * i)) + (0.277263158 * sin(2 * coef * i)) - (0.083578947 * cos(3 * coef * i)) + (0.006947368 * sin(4 * coef * i));
  }
  return window;
}
