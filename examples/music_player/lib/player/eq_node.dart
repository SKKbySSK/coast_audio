import 'dart:math';

import 'package:coast_audio/coast_audio.dart';

class ParametricEQNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin, BypassNodeMixin {
  ParametricEQNode({
    required this.format,
    required this.centerFreq,
    required this.dbGain,
    required this.qFactor,
  });

  final AudioFormat format;
  double centerFreq;
  double dbGain;
  double qFactor;

  double _x1 = 0;
  double _x2 = 0;
  double _y1 = 0;
  double _y2 = 0;

  @override
  List<SampleFormat> get supportedSampleFormats => const [SampleFormat.float32];

  @override
  int process(AudioBuffer buffer) {
    final inputData = buffer.asFloat32ListView();

    // Following Coefficients and Transfer Functions are adapted from Audio-EQ-Cookbook.
    // more at https://www.w3.org/TR/audio-eq-cookbook/

    // Calculate filter coefficients
    double w0 = 2 * pi * centerFreq / format.sampleRate;
    double alpha = sin(w0) / (2 * qFactor);
    double A = pow(10.0, (dbGain / 40)).toDouble();

    double b0 = 1 + (alpha * A);
    double b1 = -2 * cos(w0);
    double b2 = 1 - (alpha * A);
    double a0 = 1 + (alpha / A);
    double a1 = b1;
    double a2 = 1 - (alpha / A);

    // Process each sample
    for (int frame = 0; frame < buffer.sizeInFrames; frame++) {
      for (var channel = 0; format.channels > channel; channel++) {
        final inputBufferIndex = (frame * format.channels) + channel;

        double x = inputData[inputBufferIndex];

        // Calculate output sample
        double y = (b0 / a0) * x + (b1 / a0) * _x1 + (b2 / a0) * _x2 - (a1 / a0) * _y1 - (a2 / a0) * _y2;

        // Update the state variables
        _x2 = _x1;
        _x1 = x;
        _y2 = _y1;
        _y1 = y;

        // Update the buffer data
        inputData[inputBufferIndex] = y;
      }
    }

    return buffer.sizeInFrames;
  }
}
