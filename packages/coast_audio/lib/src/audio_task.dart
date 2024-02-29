import 'package:coast_audio/coast_audio.dart';

/// A task that reads audio data from [endpoint].
class AudioTask {
  AudioTask({
    required AudioClock clock,
    required this.format,
    required this.readFrameSize,
    required this.endpoint,
    this.onRead,
  })  : _clock = clock,
        assert(readFrameSize > 0) {
    _clock.stop();
    _clock.callbacks.add(_onTick);
  }

  final AudioClock _clock;

  /// The size of the buffer to read audio data.
  final int readFrameSize;

  /// The format of the audio data.
  final AudioFormat format;

  /// The endpoint to read audio data from.
  final AudioOutputBus endpoint;

  /// The callback that is called when audio data is read.
  void Function(AudioBuffer buffer, bool isEnd)? onRead;

  /// Whether the task is started.
  bool get isStarted => _clock.isStarted;

  AllocatedAudioFrames? _buffer;

  /// Starts the task.
  void start() {
    // clean up the buffer if it exists
    stop();

    _buffer = AllocatedAudioFrames(length: readFrameSize, format: format);
    _clock.start();
  }

  /// Stops the task.
  void stop() {
    _clock.stop();
    _buffer?.dispose();
    _buffer = null;
  }

  void _onTick(AudioClock clock) {
    final buffer = _buffer;
    if (buffer == null) {
      throw StateError('AudioClock has started unexpectedly. Please do not call clock\'s start method directly.');
    }

    var totalRead = 0;
    var isEnd = false;

    buffer.acquireBuffer(
      (rawBuffer) {
        AudioReadResult? read;
        var buffer = rawBuffer;

        // read audio data until the buffer is full or the endpoint is ended
        while (buffer.sizeInFrames > 0 && !(read?.isEnd ?? false)) {
          read = endpoint.read(buffer);
          buffer = buffer.offset(read.frameCount);
          totalRead += read.frameCount;
        }

        isEnd = read?.isEnd ?? false;
        onRead?.call(rawBuffer.limit(totalRead), isEnd);
      },
    );

    if (isEnd) {
      stop();
    }
  }
}
