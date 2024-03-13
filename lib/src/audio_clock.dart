import 'dart:async';

import 'audio_time.dart';

typedef AudioClockCallback = void Function(AudioClock clock);

/// An audio clock that provides a time reference for audio tasks.
abstract class AudioClock {
  AudioClock();

  /// Whether the clock is started.
  bool get isStarted;

  /// The elapsed time of the clock.
  AudioTime get elapsedTime;

  /// The callbacks that are called when the clock ticks.
  final callbacks = <AudioClockCallback>[];

  /// Starts the clock.
  void start();

  /// Stops the clock.
  void stop();

  /// Resets the clock.
  ///
  /// Please note that the clock is not stopped after reset.
  /// You should call [stop] if you want to stop the clock.
  void reset();
}

/// An audio clock that ticks at a fixed interval.
///
/// This clock is useful for running audio task without blocking the isolate.
class AudioIntervalClock extends AudioClock {
  AudioIntervalClock(this.interval);

  Timer? _timer;
  double _elapsedTime = 0;

  /// The interval of the clock.
  final Duration interval;

  @override
  bool get isStarted => _timer != null;

  @override
  AudioTime get elapsedTime => AudioTime(_elapsedTime);

  @override
  void start() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(interval, (timer) {
      _elapsedTime += interval.inMicroseconds / 1000 / 1000;
      for (var f in callbacks) {
        f(this);
      }
    });
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void reset() {
    _elapsedTime = 0;
  }
}

/// An audio clock that ticks in a loop.
///
/// This clock is useful for running audio task as fast as possible like converting audio data.
/// You should stop the clock inside the callback to prevent the isolate from being blocked.
class AudioLoopClock extends AudioClock {
  AudioLoopClock();

  final _stopwatch = Stopwatch();

  @override
  bool get isStarted => _stopwatch.isRunning;

  @override
  AudioTime get elapsedTime => AudioTime(_stopwatch.elapsedMicroseconds / 1000 / 1000);

  @override
  void start() {
    _stopwatch.start();
    while (_stopwatch.isRunning) {
      if (callbacks.isEmpty) {
        stop();
        throw AssertionError('No callback is registered to the clock');
      }

      for (var f in callbacks) {
        f(this);
      }
    }
  }

  @override
  void stop() {
    _stopwatch.stop();
  }

  @override
  void reset() {
    _stopwatch.reset();
  }
}
