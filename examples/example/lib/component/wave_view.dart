import 'package:coast_audio/coast_audio.dart';
import 'package:example/painter/wave_painter.dart';
import 'package:flutter/material.dart';

class WaveView extends StatelessWidget {
  const WaveView({
    Key? key,
    required this.buffer,
  }) : super(key: key);
  final FrameBuffer buffer;

  @override
  Widget build(BuildContext context) {
    final deinterleaved = buffer.acquireBuffer((buffer) => buffer.copyFloat32List(deinterleave: true));
    final lengthPerChannel = deinterleaved.length ~/ buffer.format.channels;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var ch = 0; buffer.format.channels > ch; ch++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: WavePainter(
                        deinterleaved.skip(lengthPerChannel * ch).take(lengthPerChannel).toList(growable: false),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text('${ch + 1}ch'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
