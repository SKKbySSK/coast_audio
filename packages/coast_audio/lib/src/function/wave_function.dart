import 'dart:math' as math;

import 'package:coast_audio/coast_audio.dart';

/// The abstract class of a wave generator function.
/// You can implement custom waves by extending this class.
abstract class WaveFunction {
  const WaveFunction();

  /// Compute 1Hz wave data at the [time].
  double compute(AudioTime time);
}

/// A wave generator function that returns a constant value.
class OffsetFunction extends WaveFunction {
  OffsetFunction(this.offset);
  double offset;

  @override
  double compute(AudioTime time) {
    return offset;
  }
}

/// A wave generator function that returns a sine wave.
class SineFunction extends WaveFunction {
  const SineFunction();

  @override
  double compute(AudioTime time) {
    return math.sin(2 * math.pi * time.seconds);
  }
}

/// A wave generator function that returns a cosine wave.
class CosineFunction extends WaveFunction {
  const CosineFunction();

  @override
  double compute(AudioTime time) {
    return math.cos(2 * math.pi * time.seconds);
  }
}

/// A wave generator function that returns a square wave.
class SquareFunction extends WaveFunction {
  const SquareFunction();

  @override
  double compute(AudioTime time) {
    final t = time.seconds - time.seconds.floorToDouble();
    if (t <= 0.5) {
      return 1;
    } else {
      return -1;
    }
  }
}

/// A wave generator function that returns a triangle wave.
class TriangleFunction extends WaveFunction {
  const TriangleFunction();

  @override
  double compute(AudioTime time) {
    final t = time.seconds - time.seconds.floorToDouble();
    return 2 * (2 * (t - 0.5)).abs() - 1;
  }
}

/// A wave generator function that returns a sawtooth wave.
class SawtoothFunction extends WaveFunction {
  const SawtoothFunction();

  @override
  double compute(AudioTime time) {
    final f = time.seconds - time.seconds.floorToDouble();
    return 2 * (f - 0.5);
  }
}
