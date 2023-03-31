import 'dart:async';

import 'audio_time.dart';

typedef AudioClockCallback = void Function(AudioClock clock);

abstract class AudioClock {
  AudioClock();

  bool get isStarted;

  AudioTime get elapsedTime;

  final callbacks = <AudioClockCallback>[];

  void start();

  void stop();
}

class AudioIntervalClock extends AudioClock {
  AudioIntervalClock(this.interval);

  Timer? _timer;
  double _elapsedTime = 0;

  final Duration interval;

  @override
  bool get isStarted => _timer != null;

  @override
  AudioTime get elapsedTime => AudioTime(_elapsedTime);

  @override
  void start() {
    if (_timer != null) {
      stop();
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
}
