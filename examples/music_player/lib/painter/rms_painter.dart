import 'package:flutter/material.dart';

class RmsPainter extends CustomPainter {
  RmsPainter(
    this.rmsList,
    this.maxLength,
  );
  final List<double> rmsList;
  final int maxLength;

  @override
  void paint(Canvas canvas, Size size) {
    if (rmsList.length < 2) {
      return;
    }

    final width = size.width / maxLength;
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    final offset = (maxLength - rmsList.length) * width;

    for (var i = 0; rmsList.length - 1 > i; i++) {
      const scale = 1000;
      final a = rmsList[i] * scale;
      final b = rmsList[i + 1] * scale;
      canvas.drawLine(
        Offset(offset + i * width, size.height - a),
        Offset(offset + (i + 1) * width, size.height - b),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
