import 'package:coast_audio/coast_audio.dart';

class AudioTask extends SyncDisposable {
  AudioTask({
    required AudioClock clock,
    required AudioFormat format,
    required int readFrameSize,
    required this.endpoint,
    this.onRead,
  })  : _clock = clock,
        _buffer = AllocatedFrameBuffer(frames: readFrameSize, format: format) {
    _clock.stop();
    _clock.callbacks.add(_onTick);
  }

  final AudioClock _clock;
  final AllocatedFrameBuffer _buffer;

  AudioOutputBus? endpoint;

  void Function(RawFrameBuffer buffer)? onRead;

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
      var read = 0;
      var buffer = rawBuffer;
      while (totalRead <= rawBuffer.sizeInFrames) {
        read = endpoint.read(buffer);
        if (read == 0) {
          break;
        }

        totalRead += read;
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
