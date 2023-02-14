import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:flutter/material.dart';

class FftPainter extends CustomPainter {
  const FftPainter(this.result, this.minFreq, this.maxFreq);

  final double minFreq;
  final double maxFreq;
  final FftResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    final minIndex = result.getIndex(minFreq);
    final maxIndex = result.getIndex(maxFreq);
    final data = result.complexArray.discardConjugates().magnitudes().sublist(minIndex, maxIndex);

    var max = 0.0;
    var peakFreq = 0.0;
    for (var i = 0; data.length > i; i++) {
      final value = data[i];
      if (value > max) {
        max = value;
        peakFreq = result.getFrequency(i);
      }
    }

    if (max <= 0) {
      return;
    }

    final painter = TextPainter(
      text: TextSpan(
        text: '${peakFreq.toStringAsPrecision(5)} Hz\n${result.complexArray.length} Samples',
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    )
      ..textDirection = TextDirection.ltr
      ..layout();
    painter.paint(canvas, const Offset(8, 8));

    final points = <Offset>[];
    for (var i = 0; data.length > i; i++) {
      points.add(Offset(size.width / data.length * i, size.height * (1 - (data[i] / max))));
    }

    for (var i = 0; points.length - 1 > i; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
