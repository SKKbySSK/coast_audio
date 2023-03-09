import 'dart:math';

import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/material.dart';

double logBase(num x, num base) => log(x) / log(base);

class FftPainter extends CustomPainter {
  const FftPainter(
    this.result,
    this.minFreq,
    this.maxFreq,
    this.palette, [
    this.count = 20,
  ]);

  final double minFreq;
  final double maxFreq;
  final FftResult result;
  final List<Color> palette;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final minIndex = result.getIndex(minFreq);
    final maxIndex = result.getIndex(maxFreq);
    final data = result.complexArray.discardConjugates().magnitudes().sublist(minIndex, maxIndex);

    if (maxIndex - minIndex <= count) {
      return;
    }

    final spectrum = <double>[];

    final step = data.length ~/ count;
    for (var index = 0; data.length > index; index += step) {
      final nextIndex = min(index + step, data.length);

      var sum = 0.0;
      for (var i = index; nextIndex > i; i++) {
        sum += (20 * logBase(data[i], 10));
      }

      final freq = result.getFrequency(index);
      final nextFreq = result.getFrequency(nextIndex);
      final db = sum / (nextFreq - freq);
      final normalized = max(min(db, 1), 0).toDouble() * 1.5;
      spectrum.add(normalized);
    }

    final sWidth = size.width / spectrum.length;

    for (var i = 0; spectrum.length > i; i++) {
      final x = sWidth * i + (sWidth / 2);
      final paint = Paint()
        ..color = palette[i % palette.length].withOpacity(0.9)
        ..strokeWidth = sWidth - 2;
      canvas.drawLine(Offset(x, (1 - spectrum[i]) * size.height), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
