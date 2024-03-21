import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/interop/ca_device.dart';

/// The audio device context that is used to create audio devices for the specified backends.
class AudioDeviceContext with AudioResourceMixin {
  AudioDeviceContext({required List<AudioDeviceBackend> backends}) : _context = CaDeviceContext(backends: backends) {
    final captured = _context;
    setResourceFinalizer(() {
      captured.dispose();
    });
  }

  final CaDeviceContext _context;

  /// The active backend of the context.
  AudioDeviceBackend get activeBackend => _context.activeBackend;

  /// Get the available devices for the specified device type.
  List<AudioDeviceInfo> getDevices(AudioDeviceType type) => _context.getDevices(type);

  /// Create a playback device.
  ///
  /// Please note that the device will be disposed and no longer available when the context is disposed.
  PlaybackDevice createPlaybackDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
    AudioFormatConverterConfig converter = const AudioFormatConverterConfig(),
  }) {
    return PlaybackDevice._initWithContext(
      context: this,
      device: _context.createDevice(
        format: format,
        bufferFrameSize: bufferFrameSize,
        type: AudioDeviceType.playback,
        deviceId: deviceId,
        noFixedSizedProcess: noFixedSizedProcess,
        performanceProfile: performanceProfile,
        converter: converter,
      ),
    );
  }

  /// Create a capture device.
  ///
  /// Please note that the device will be disposed and no longer available when the context is disposed.
  CaptureDevice createCaptureDevice({
    required AudioFormat format,
    required int bufferFrameSize,
    AudioDeviceId? deviceId,
    bool noFixedSizedProcess = true,
    AudioDevicePerformanceProfile performanceProfile = AudioDevicePerformanceProfile.lowLatency,
    AudioFormatConverterConfig converter = const AudioFormatConverterConfig(),
  }) {
    return CaptureDevice._initWithContext(
      context: this,
      device: _context.createDevice(
        format: format,
        bufferFrameSize: bufferFrameSize,
        type: AudioDeviceType.capture,
        deviceId: deviceId,
        noFixedSizedProcess: noFixedSizedProcess,
        performanceProfile: performanceProfile,
        converter: converter,
      ),
    );
  }
}

/// A base class for audio devices.
///
/// You can instantiate a [PlaybackDevice] or [CaptureDevice] using the [AudioDeviceContext].
abstract class AudioDevice with AudioResourceMixin {
  /// Initialize the device.
  AudioDevice({
    required this.context,
    required CaDevice device,
  }) : _native = device {
    setResourceFinalizer(() {
      device.dispose();
    });
  }

  final CaDevice _native;

  /// Current device context for this instance.
  final AudioDeviceContext context;

  /// The device's type.
  late final AudioDeviceType type = _native.type;

  /// The device's internal buffer frame size.
  ///
  /// When playing audio, the buffer frame size should be large enough to prevent audio stuttering.
  late final int bufferFrameSize = _native.bufferFrameSize;

  /// The device's format.
  /// If the device supports format natively, no conversion will occurs.
  /// Otherwise, miniaudio will try to convert the format.
  late final AudioFormat format = _native.format;

  /// The device's notification stream.
  /// Use this stream to detecting route and lifecycle changes.
  late final notification = _native.notification;

  /// A flag indicates the device is started or not.
  bool get isStarted => _native.isStarted;

  /// Available buffered frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableReadFrames => _native.availableReadFrames;

  /// Available writable frame count of the device.
  /// This value can be changed when [isStarted] flag is true.
  int get availableWriteFrames => _native.availableWriteFrames;

  /// The current volume of the device.
  double get volume => _native.volume;

  /// Set the volume of the device.
  set volume(double value) => _native.volume = value;

  /// The current state of the device.
  AudioDeviceState get state => _native.state;

  /// Get the current device information.
  /// You can listen the [notificationStream] to detect device changes.
  /// When no device is specified while constructing the instance, this method returns null.
  AudioDeviceInfo? get deviceInfo => _native.deviceInfo;

  /// Start the audio device.
  void start() => _native.start();

  /// Stop the audio device.
  /// When [clearBuffer] is set to true, internal buffer will be cleared automatically (true by default).
  void stop({bool clearBuffer = true}) => _native.stop(clearBuffer: clearBuffer);

  /// Clear the internal buffer.
  void clearBuffer() => _native.clearBuffer();
}

/// A playback device.
class PlaybackDevice extends AudioDevice {
  PlaybackDevice._initWithContext({
    required super.context,
    required super.device,
  });

  /// Write the [buffer] data to device's internal buffer.
  /// If you write frames greater than [availableWriteFrames], overflowed frames will be ignored and not written.
  PlaybackDeviceWriteResult write(AudioBuffer buffer) => _native.write(buffer);
}

/// The result of the write operation.
class PlaybackDeviceWriteResult {
  const PlaybackDeviceWriteResult(this.maResult, this.framesWrite);

  /// The miniaudio result of the write operation.
  ///
  /// When the result is [MaResult.success], the write operation is successful and the requested frames are written.
  /// When the result is [MaResult.atEnd], the write operation is successful but the requested frames are not fully written.
  final MaResult maResult;

  /// The number of frames written to the device's internal buffer.
  final int framesWrite;
}

/// A capture device.
class CaptureDevice extends AudioDevice {
  CaptureDevice._initWithContext({
    required super.context,
    required super.device,
  });

  /// Read device's internal buffer into [buffer].
  CaptureDeviceReadResult read(AudioBuffer buffer) => _native.read(buffer);
}

/// The result of the read operation.
class CaptureDeviceReadResult {
  const CaptureDeviceReadResult(this.maResult, this.framesRead);

  /// The miniaudio result of the read operation.
  ///
  /// When the result is [MaResult.success], the read operation is successful and the requested frames are read.
  /// When the result is [MaResult.atEnd], the read operation is successful but the requested frames are not fully read.
  final MaResult maResult;

  /// The number of frames read from the device's internal buffer.
  final int framesRead;
}
