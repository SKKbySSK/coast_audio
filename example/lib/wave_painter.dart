import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  const WavePainter(this.buffer);

  final List<double> buffer;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    final halfHeight = size.height / 2;
    final points = <Offset>[];
    for (var i = 0; buffer.length > i; i++) {
      points.add(Offset(size.width / buffer.length * i, halfHeight * buffer[i] + halfHeight));
    }

    for (var i = 0; points.length - 1 > i; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
