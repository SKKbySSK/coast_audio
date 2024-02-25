import 'package:coast_audio/coast_audio.dart';

class AudioTask extends SyncDisposable {
  AudioTask({
    required AudioClock clock,
    required AudioFormat format,
    required int readFrameSize,
    required this.endpoint,
    this.onRead,
    this.onEnd,
  })  : _clock = clock,
        _buffer = AllocatedAudioFrames(length: readFrameSize, format: format) {
    _clock.stop();
    _clock.callbacks.add(_onTick);
  }

  final AudioClock _clock;
  final AllocatedAudioFrames _buffer;

  AudioOutputBus? endpoint;

  void Function(AudioBuffer buffer)? onRead;

  void Function()? onEnd;

  bool get isStarted => _clock.isStarted;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  void start() => _clock.start();

  void stop() => _clock.stop();

  void _onTick(AudioClock clock) {
    final endpoint = this.endpoint;
    if (endpoint == null) {
      return;
    }

    _buffer.acquireBuffer((rawBuffer) {
      var totalRead = 0;
      AudioReadResult? read;
      var buffer = rawBuffer;
      while (totalRead <= rawBuffer.sizeInFrames && !(read?.isEnd ?? false)) {
        read = endpoint.read(buffer);
        if (read.isEnd) {
          onEnd?.call();
          break;
        }

        totalRead += read.frameCount;
        buffer = rawBuffer.offset(totalRead);
      }
      onRead?.call(rawBuffer.limit(totalRead));
    });
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = false;

    _clock.stop();
    _clock.callbacks.remove(_onTick);
    _buffer.dispose();
  }
}
