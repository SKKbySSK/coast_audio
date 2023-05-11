import 'dart:math' as math;

import 'package:coast_audio/coast_audio.dart';

/// The abstract class of a wave generator function.
/// You can implement custom waves by extending this class.
abstract class WaveFunction {
  const WaveFunction();

  /// Compute 1Hz wave data at the [time].
  double compute(AudioTime time);
}

class OffsetFunction extends WaveFunction {
  OffsetFunction(this.offset);
  double offset;

  @override
  double compute(AudioTime time) {
    return offset;
  }
}

class SineFunction extends WaveFunction {
  const SineFunction();

  @override
  double compute(AudioTime time) {
    return math.sin(2 * math.pi * time.seconds);
  }
}

class CosineFunction extends WaveFunction {
  const CosineFunction();

  @override
  double compute(AudioTime time) {
    return math.cos(2 * math.pi * time.seconds);
  }
}

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

class TriangleFunction extends WaveFunction {
  const TriangleFunction();

  @override
  double compute(AudioTime time) {
    final t = time.seconds - time.seconds.floorToDouble();
    return 2 * (2 * (t - 0.5)).abs() - 1;
  }
}

class SawtoothFunction extends WaveFunction {
  const SawtoothFunction();

  @override
  double compute(AudioTime time) {
    final f = time.seconds - time.seconds.floorToDouble();
    return 2 * (f - 0.5);
  }
}
