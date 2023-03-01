import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';

typedef AudioOutputCallback = void Function(RawFrameBuffer buffer);

/// Periodically read audio data to the buffer and fires [onOutput] callback.
class AudioOutput extends Disposable {
  factory AudioOutput.latency({
    required AudioOutputBus outputBus,
    required AudioFormat format,
    required Duration latency,
    double timeScale = 1,
    AudioOutputCallback? onOutput,
  }) {
    final bufferFrames = (format.sampleRate * latency.inMilliseconds) / 1000;
    return AudioOutput(
      outputBus: outputBus,
      format: format,
      bufferFrames: bufferFrames.toInt(),
      timeScale: timeScale,
      onOutput: onOutput,
    );
  }

  AudioOutput({
    required this.outputBus,
    required this.format,
    required this.bufferFrames,
    this.reservedBufferFrames = 1024,
    this.timeScale = 1,
    this.onOutput,
  })  : _buffer = AllocatedFrameBuffer(frames: bufferFrames + reservedBufferFrames, format: format),
        _ringBuffer = FrameRingBuffer(frames: (bufferFrames + reservedBufferFrames) * 2, format: format),
        _clock = IntervalAudioClock(Duration(milliseconds: ((bufferFrames / format.sampleRate) / timeScale * 1000).toInt())) {
    _clock.callbacks.add(_onTick);
  }

  final AudioFormat format;
  final AudioOutputBus outputBus;
  final double timeScale;
  final int bufferFrames;
  final int reservedBufferFrames;

  AudioOutputCallback? onOutput;

  final IntervalAudioClock _clock;
  final AllocatedFrameBuffer _buffer;
  late final _rawBuffer = _buffer.lock();
  final FrameRingBuffer _ringBuffer;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  void start() => _clock.start();

  void stop() => _clock.stop();

  Duration get interval => _clock.interval;

  AudioTime get elapsed => _clock.elapsedTime;

  bool get isStarted => _clock.isStarted;

  void _onTick(AudioClock clock) {
    var readableFrames = min(_ringBuffer.capacity - _ringBuffer.length, bufferFrames);

    while ((_ringBuffer.capacity - _ringBuffer.length) > 0) {
      final framesRead = outputBus.read(_rawBuffer.limit(readableFrames));
      assert(framesRead >= 0);
      _ringBuffer.write(_rawBuffer.limit(framesRead));
      readableFrames -= framesRead;

      if (framesRead == 0) {
        break;
      }
    }

    if (_ringBuffer.length >= bufferFrames) {
      final limitedBuffer = _rawBuffer.limit(bufferFrames);
      _ringBuffer.read(limitedBuffer);
      onOutput?.call(limitedBuffer);
    }
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    stop();
    _clock.callbacks.remove(_onTick);
    _buffer.unlock();
    _buffer.dispose();
  }
}
