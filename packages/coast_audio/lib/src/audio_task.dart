import 'package:coast_audio/coast_audio.dart';
import 'package:meta/meta.dart';

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

  var _canDisposeBuffer = false;

  /// Starts the task.
  @mustCallSuper
  void start() {
    // clean up the buffer if it exists
    if (_buffer != null) {
      stop();
    }

    _buffer = AllocatedAudioFrames(length: readFrameSize, format: format);
    _clock.start();
  }

  /// Stops the task.
  @mustCallSuper
  void stop() {
    _clock.stop();
    if (_canDisposeBuffer) {
      _buffer?.dispose();
      _buffer = null;
    }
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
        _canDisposeBuffer = false;
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
    _canDisposeBuffer = true;

    // whether the task is stopped inside the onRead callback
    final isStopCalledWhileOnReadCb = !_clock.isStarted;

    if (isEnd || isStopCalledWhileOnReadCb) {
      stop();
    }
  }
}

/// A task that encodes audio data from [endpoint].
class AudioEncodeTask extends AudioTask {
  AudioEncodeTask._init({
    required super.clock,
    required super.format,
    required super.endpoint,
    required this.encoder,
    super.readFrameSize = 4096,
    this.onEncoded,
  }) {
    onRead = (buffer, isEnd) {
      final result = encoder.encode(buffer);
      onEncoded?.call(buffer.limit(result.frames), isEnd);
    };
  }

  factory AudioEncodeTask({
    required AudioFormat format,
    required AudioOutputBus endpoint,
    required AudioEncoder encoder,
    int readFrameSize = 4096,
    void Function(AudioBuffer buffer, bool isEnd)? onEncoded,
  }) {
    return AudioEncodeTask._init(
      clock: AudioLoopClock(),
      format: format,
      endpoint: endpoint,
      encoder: encoder,
      readFrameSize: readFrameSize,
      onEncoded: onEncoded,
    );
  }

  /// The encoder used to encode audio data.
  final AudioEncoder encoder;

  var _isEncoderStarted = false;

  void Function(AudioBuffer buffer, bool isEnd)? onEncoded;

  @override
  void start() {
    encoder.start();
    _isEncoderStarted = true;
    super.start();
  }

  @override
  void stop() {
    super.stop();
    if (_isEncoderStarted) {
      encoder.finalize();
      _isEncoderStarted = false;
    }
  }
}
